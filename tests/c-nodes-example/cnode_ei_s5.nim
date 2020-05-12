##  #include <erl_format.h>
import strutils
import sugar 
import os
import posix
import segfaults
import net
import erts_include/codec
import erts_include/ei 

const
  BUFSIZE* = 1000

# proc ei_malloc(size: clong): pointer
proc new_ei_x_size*(x: ptr EiBuff; size: clong): cint

proc foo*(x: int): int =
    return x + 1
proc bar*(y: int): int =
    return y * 2

proc my_listen*(port: Port): Socket =
  var socket = newSocket()
  socket.bindAddr(port, address="")
  socket.setSockOpt(OptReuseAddr, true)
  socket.setSockOpt(OptKeepAlive, true)
  socket.listen()
  return socket

proc main*() =
  let arguments = commandLineParams()
  var port: Port = Port(parseInt($(arguments[0])))

  echo("starting: " )

  discard ei_init()

  var node_addr: InAddr
  ##  32-bit IP number of host
  node_addr.s_addr = inet_addr("127.0.0.1")

  var ec: EiCnode

  if ei_connect_xinit(ec.addr, "alpha", "cnode", "cnode@127.0.0.1", node_addr.addr,
                     "secretcookie", 0) < 0:
    raise newException(LibraryError, "ERROR: when initializing ei_connect_xinit ")

  ##  Listen socket
  var server_node = "e1@127.0.0.1"

  var fd: cint
  var connected = false
  while not connected:
    fd = ei_connect(ec.addr, server_node.cstring)
    if fd < 0:
      echo("ERROR: connecting to node: " & server_node)
      os.sleep(1_000)
    else:
      connected = true
    
  echo("Connected to: " & server_node);

  var info: ErlangMsg
  var emsg: EiBuff

  discard new_ei_x_size(emsg.addr, 128)

  ##  Lopp flag
  var loop: bool = true
  while loop:
    var mtype = ei_xreceive_msg(fd, addr(info), addr(emsg))
    if mtype == ERL_TICK:
      echo("tick: " & $mtype)
    elif mtype == ERL_ERROR:
      echo("err: " )
      loop = false
      raise newException(LibraryError, "erl_error: " & $mtype)
    else:
      ##  ETERM *fromp, *tuplep, *fnp, *argp, *resp;
      echo("message: " & $mtype)
      if info.msgtype == ERL_REG_SEND:
        var res: cint = 0

        echo("erl_reg_send: msgtype: $1 buff: $2 idx: $3 bufsz: $4 " %
                [ $info.msgtype, $emsg.buff, $emsg.index, $emsg.buffsz])

        var eterms: ErlTerm = binaryToTerms(emsg)

        # echo "eterms: " & repr(eterms)

        var main_msg: seq[ErlTerm] = eterms.getTuple()
        # echo "main_msg:len: " & $len(main_msg)
        # echo "main_msg:repr: " & repr(main_msg)

        var rpc_msg = main_msg[2].getTuple()
        var msg_atom = rpc_msg[0].getAtom()
        var msg_arg = rpc_msg[1].getInt32()

        # echo "rpc_msg:repr: " & repr(rpc_msg)
        # echo "msg_atom:repr: " & repr(msg_atom)
        # echo "msg_arg:repr: " & repr(msg_arg)

        if msg_atom.n == "foo":
          echo( "foo: " & $msg_arg)
          res = foo(msg_arg).cint
        elif msg_atom.n == "bar":
          echo( "bar: " & $msg_arg)
          res = bar(msg_arg).cint
        else:
          echo("other: " & $msg_arg)
          echo("other message: " & $msg_atom)

        var rmsg = newETuple(@[newEAtom("cnode"), newETerm(res)])
        var ssout = termToBinary(rmsg)

        # echo "ssout:len: " & $(ssout.pos)
        # echo "ssout:repr: " & repr(ssout)
        # echo "ssout:done: " 
        # discard ei_x_format(addr(x_out), "{cnode,~i}", res)
        # discard ei_send(fd, addr(info.`from`), x_out.buff, x_out.index)
        discard ei_send(fd, addr(info.`from`), ssout.data, ssout.pos)
        ##  erl_free_term(argp);


proc new_ei_x_size(x: ptr EiBuff; size: int): cint =
  # x.buff = cast[cstring](ei_malloc(size))
  x.buff = cast[cstring](alloc(size))
  x.buffsz = size.cint
  x.index = 0
  return if x.buff != nil: 0 else: -1

when isMainModule:
  main()
