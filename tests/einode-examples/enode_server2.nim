##  #include <erl_format.h>
import strutils
import os
import posix
import segfaults
import net
import einode
# import einode/publish 

const
  BUFSIZE* = 1000

# proc ei_malloc(size: clong): pointer
proc new_ei_x_size*(x: ptr EiBuff; size: clong): cint

proc foo*(x: int): int =
    return x + 1
proc bar*(y: int): int =
    return y * 2

proc main*() =
  let arguments = commandLineParams()
  var port: Port = Port(parseInt($(arguments[0])))
  var node_name =
    if len(arguments) == 2:
      arguments[1]
    else:
      "cnode2"

  echo("starting: " )
  var einode = newEiNode(node_name, "127.0.0.1", cookie = "secretcookie", port = port)
  einode.initialize()

  ##  Listen socket
  # var listen: Socket = my_listen(port)
  # if ei_publish(ec.addr, port.cint) == -1:
    # raise newException(LibraryError, "ERROR: publishing on port $1" % [$port])
  einode.serverStart(on_address="")
  einode.serverPublish()

  einode.serverAccept()
  var emsg: EiBuff

  echo("connected on port: " & $einode.port)
  ##  Lopp flag
  echo("receiving messages: " )
  for (msgtype, info, eterm) in receiveMessages(einode):
    case msgtype
    of REG_SEND:
      var res: cint = 0

      echo("erl_reg_send: msgtype: $1 " %
              [ $info.msgtype, ])

      var main_msg: seq[ErlTerm] = eterm.getTuple()

      var rpc_msg = main_msg[2].getTuple()
      var msg_atom = rpc_msg[0].getAtom()
      var msg_arg = rpc_msg[1].getInt32()

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

      einode.send(to = info.`from`, msg = rmsg)
    else:
      echo("unhandled message: " & $msgtype)


proc new_ei_x_size(x: ptr EiBuff; size: int): cint =
  # x.buff = cast[cstring](ei_malloc(size))
  x.buff = cast[cstring](alloc(size))
  x.buffsz = size.cint
  x.index = 0
  return if x.buff != nil: 0 else: -1

when isMainModule:
  main()
