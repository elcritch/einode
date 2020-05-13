##  #include <erl_format.h>
import strutils
import os
import posix
import segfaults
import net
import einode

const
  BUFSIZE* = 1000

# proc ei_malloc(size: clong): pointer
proc foo*(x: int): int =
    return x + 1
proc bar*(y: int): int =
    return y * 2

proc main*() =
  let arguments = commandLineParams()
  var node_name = arguments[0]
  echo("starting: " )
  var einode = newEiNode(node_name, "127.0.0.1", cookie = "secretcookie")

  ##  Listen socket
  var server_node = "e1@127.0.0.1"
  connect_server(einode, server_node):
    echo("Warning: unable to connect to node: " & server_node)
    os.sleep(1_000)
    
  echo("Connected to: " & server_node);

  ##  Lopp flag
  for (mtype, info, eterm) in einode.receive():
    echo("message: " & $mtype)
    if info.msgtype == ERL_REG_SEND:
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


when isMainModule:
  main()
