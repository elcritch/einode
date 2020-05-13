
import strutils
import os
import posix
import net
import options

import einode/codec
import einode/ei

export codec
export ei

type
  EiNode* = ref object
    name: string
    ip: string
    cookie: string
    alivename: string 
    ec*: EiCnode
    port*: Port
    listen*: Option[Socket]
    conn*: ErlConnect
    fd*: cint
    loop*: bool
    # info: ErlangMsg
    # emsg: EiBuff


proc newEiNode*(
    name: string,
    ip: string,
    cookie: string;
    port: Port = Port(0);
    alivename: string = "alpha"): EiNode =

  new(result)
  result.name = name
  result.alivename = alivename
  result.cookie = cookie
  result.ip = ip
  result.port = port
  result.loop = true

proc initialize*(einode: var EiNode) =
  # creates a new EiNode 
  echo "start server"
  discard ei_init()

  var node_addr: InAddr
  var alive: string = einode.alivename
  ##  32-bit IP number of host
  node_addr.s_addr = inet_addr(einode.ip)

  if ei_connect_xinit(einode.ec.addr,
                      cstring(alive),
                      einode.name,
                      einode.name & "@" & einode.ip,
                      node_addr.addr,
                      "secretcookie", 0) < 0:
    raise newException(LibraryError, "ERROR: when initializing ei_connect_xinit ")



proc publishServer*(einode: var EiNode; address: string = "") =

  var listen = newSocket()
  listen.bindAddr(einode.port, address=address) # bind all
  listen.setSockOpt(OptReuseAddr, true)
  listen.setSockOpt(OptKeepAlive, true)
  listen.listen()

  einode.listen = some(listen)
  if ei_publish(einode.ec.addr, einode.port.cint) == -1:
    raise newException(LibraryError, "ERROR: publishing on port $1" % [$(einode.port)])

  var fd = ei_accept(einode.ec.addr,
                     listen.getFd().cint,
                     einode.conn.addr)

  if fd == ERL_ERROR:
    raise newException(LibraryError, "ERROR: erl_accept on listen socket $1" % [repr(listen)])

template connectServer*(einode: var EiNode, server_node: string, body: untyped) =
  # var server_node = "$1@$2" % [ toNode, ip ]
  ##  Listen socket
  var connected = false
  while not connected:
    einode.fd = ei_connect(einode.ec.addr, server_node.cstring)
    if einode.fd < 0:
      body
    else:
      echo "connected with fd: " & $einode.fd
      connected = true

proc new_ei_x_size(x: ptr EiBuff; size: int): cint =
  # x.buff = cast[cstring](ei_malloc(size))
  x.buff = cast[cstring](alloc(size))
  x.buffsz = size.cint
  x.index = 0
  return if x.buff != nil: 0 else: -1

iterator receive*(einode: var EiNode;
                  size: int = 128;
                  ignoreTick = true;
                  raiseOnError = true):
            tuple[mtype: cint, info: ErlangMsg, eterm: ErlTerm] =

  var fd = einode.fd
  var info = ErlangMsg()
  var emsg = EiBuff()

  # discard new_ei_x_size(emsg.addr, 128)

  emsg.buff = cast[cstring](alloc(size))
  emsg.buffsz = size.cint
  emsg.index = 0

  while einode.loop:
    var mtype = ei_xreceive_msg(fd, addr(info), addr(emsg))

    echo("erl_reg_send: msgtype: $1 buff: $2 idx: $3 bufsz: $4 " %
          [ $info.msgtype, $(repr(emsg.buff)), $emsg.index, $emsg.buffsz])

    if mtype == ERL_TICK:
      if ignoreTick:
        continue
    elif mtype == ERL_ERROR:
      if raiseOnError:
        raise newException(LibraryError, "erl_error: " & $mtype)
      else:
        yield (mtype, info, binaryToTerms(emsg))
    else:
        # ERL_REG_SEND
      yield (mtype, info, binaryToTerms(emsg))


proc send*(einode: var EiNode, to: ErlangPid, msg: var ErlTerm) =
  var pid = to
  var ssout = termToBinary(msg)
  discard ei_send(einode.fd,
                  addr(pid),
                  ssout.data,
                  ssout.pos)

proc send*(einode: var EiNode, to: ErlangMsg, msg: var ErlTerm) =
  send(einode, to.`from`, msg)

