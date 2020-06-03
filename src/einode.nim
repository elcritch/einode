
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
    port: Port = Port(4370);
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


proc serverStart*(einode: var EiNode; on_address: string = "") =
  var sock = newSocket()
  sock.bindAddr(einode.port, address=on_address) # bind all
  sock.setSockOpt(OptReuseAddr, true)
  sock.setSockOpt(OptKeepAlive, true)
  sock.listen()

  einode.listen = some(sock)

proc serverPublish*(einode: var EiNode) =
  if ei_publish(einode.ec.addr, einode.port.cint) == -1:
    raise newException(LibraryError, "ERROR: publishing on port $1" % [$(einode.port)])

proc serverAccept*(einode: var EiNode) =
  if einode.listen.isNone():
    raise newException(LibraryError, "ERROR: socket must be started " )

  var sock: Socket = einode.listen.get()

  var fd = ei_accept(einode.ec.addr,
                     sock.getFd().cint,
                     einode.conn.addr)

  if fd == ERL_ERROR:
    var fd_id = repr(sock.getFd())
    raise newException(LibraryError, "ERROR: erl_accept on listen socket $1" & fd_id)

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

# proc new_ei_x_size(x: ptr EiBuff; size: int): cint =
#   # x.buff = cast[cstring](ei_malloc(size))
#   x.buff = cast[cstring](alloc(size))
#   x.buffsz = size.cint
#   x.index = 0
#   return if x.buff != nil: 0 else: -1

iterator receiveMessages*(einode: var EiNode;
                  size: int = 128;
                  ignoreTick = true;
                  raiseOnError = true):
            tuple[mtype: ErlMessageType, info: ErlangMsg, eterm: ErlTerm] =

  var fd = einode.fd
  var info = ErlangMsg()
  var emsg = EiBuff()

  # discard new_ei_x_size(emsg.addr, 128)

  emsg.buff = cast[cstring](alloc(size))
  emsg.buffsz = size.cint
  emsg.index = 0

  while einode.loop:
    var mtype = ErlApiType(ei_xreceive_msg(fd, addr(info), addr(emsg)))
    var msgtype = ErlMessageType(info.msgtype)

    echo("ei_xreceive_msg: mtype: $1 msgtype: $2 " % [$mtype, $info.msgtype])

    echo("erl_reg_send: msgtype: $1 buff: $2 idx: $3 bufsz: $4 " %
          [ $info.msgtype, $(repr(emsg.buff)), $emsg.index, $emsg.buffsz])

    if mtype == ApiTick:
      if ignoreTick:
        continue
    elif mtype == ApiError:
      if raiseOnError:
        raise newException(LibraryError, "erl_error: " & $mtype)
      else:
        yield (msgtype, info, binaryToTerms(emsg))
    elif mtype == ApiMsg:
        # ERL_REG_SEND
      yield (msgtype, info, binaryToTerms(emsg))
    else:
      raise newException(LibraryError, "unhandle message type: " & $mtype)


proc send*(einode: var EiNode, to: ErlangPid, msg: var ErlTerm) =
  var pid = to
  var ssout = termToBinary(msg)
  discard ei_send(einode.fd,
                  addr(pid),
                  ssout.data,
                  ssout.pos)

proc send*(einode: var EiNode, to: ErlangMsg, msg: var ErlTerm) =
  send(einode, to.`from`, msg)

