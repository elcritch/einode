
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
    ec*: EiCnode
    port*: Port
    listen*: Option[Socket]
    conn*: ErlConnect
    fd*: cint
    loop*: bool


proc newEiNode*(name: string, ip: string, port: Port, cookie: string; alivename: string = "alpha"): EiNode =

  result.port = port

  # creates a new EiNode 
  discard ei_init()

  var node_addr: InAddr
  ##  32-bit IP number of host
  node_addr.s_addr = inet_addr(ip)

  if ei_connect_xinit(result.ec.addr,
                      cstring(alivename),
                      name,
                      name & "@" & ip,
                      node_addr.addr,
                      "secretcookie", 0) < 0:
    raise newException(LibraryError, "ERROR: when initializing ei_connect_xinit ")



proc publish*(einode: var EiNode; address: string = "") =

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

template accept*(einode: var EiNode, toNode: string, ip: string, body: untyped) =
  var server_node = "$1@$2" % [ toNode, ip ]
  ##  Listen socket
  var connected = false
  while not connected:
    einode.fd = ei_connect(einode.ec.addr, server_node.cstring)
    if einode.fd < 0:
      body
    else:
      connected = true

iterator messages*(einode: EiNode; size: int = 128; ignoreTick = true; raiseOnError = true):
                  tuple[mtype: cint, info: ErlangMsg, eterm: ErlTerm] =
  var info: ErlangMsg
  var emsg: EiBuff

  emsg.buff = cast[cstring](alloc(size))
  emsg.buffsz = size.cint
  emsg.index = 0

  # echo("erl_reg_send: msgtype: $1 buff: $2 idx: $3 bufsz: $4 " %
  #     [ $info.msgtype, $(cast[seq[byte]](emsg.buff)), $emsg.index, $emsg.buffsz])

  while einode.loop:
    var mtype = ei_xreceive_msg(einode.fd, addr(info), addr(emsg))

    if mtype == ERL_TICK:
      if ignoreTick:
        continue
    elif mtype == ERL_ERROR:
      if raiseOnError:
        raise newException(LibraryError, "erl_error: " & $mtype)
      else:
        yield (mtype, info, binaryToTerms(emsg))
    elif mtype == ERL_ERROR:
      yield (mtype, info, binaryToTerms(emsg))

