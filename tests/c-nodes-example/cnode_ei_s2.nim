##  #include <erl_format.h>
import strutils
import sugar 

import erts_include/ei 

const
  BUFSIZE* = 1000

proc new_ei_x_size*(x: ptr ei_x_buff; size: clong): cint
proc set_node_reply*(x_out: ptr ei_x_buff; val: clong)
proc ei_malloc*(size: clong): pointer

proc main*(argc: cint; argv: cstringArray): cint =
  let arguments = commandLineParams()
  var port: cint = argv[1].parseInt
  ei_init()
  var `addr`: in_addr
  ##  32-bit IP number of host
  `addr`.s_addr = inet_addr("127.0.0.1")
  var ec: ei_cnode
  if ei_connect_xinit(addr(ec), "alpha", "cnode", "cnode@127.0.0.1", addr(`addr`),
                     "secretcookie", 0) < 0:
    fprintf(stderr, "ERROR: when initializing: %d\n", h_errno)
    exit(-1)
  var listen: cint
  ##  Listen socket
  if (listen = my_listen(port)) <= 0:
    fprintf(stderr, "ERROR: listening: %d on port %d\n", listen, port)
    exit(-1)
  if ei_publish(addr(ec), port) == -1:
    fprintf(stderr, "ERROR: publishing on port %d\n", port)
    exit(-1)
  var fd: cint
  var conn: ErlConnect
  ##  Connection data
  if (fd = ei_accept(addr(ec), listen, addr(conn))) == ERL_ERROR:
    fprintf(stderr, "ERROR: erl_accept on listen socket %d\n", listen)
    exit(-1)
  fprintf(stdout, "listening on port: %d\n\c", port)
  fprintf(stdout, "Connected to %s\n\c", conn.nodename)
  var info: erlang_msg
  var emsg: ei_x_buff
  var x_out: ei_x_buff
  new_ei_x_size(addr(emsg), 128)
  var loop: cint = 1
  ##  Lopp flag
  while loop:
    var got: cint = ei_receive_msg(fd, addr(info), addr(emsg))
    if got == ERL_TICK:
      fprintf(stdout, "tick: %d\n", got)
      ##  ignore
    elif got == ERL_ERROR:
      fprintf(stdout, "erl_error: %d\n", got)
      loop = 0
    else:
      ##  ETERM *fromp, *tuplep, *fnp, *argp, *resp;
      fprintf(stdout, "message: %d\n", got)
      if info.msgtype == ERL_REG_SEND:
        var res: cint = 0
        var version: cint
        var arity: cint
        var msg_atom: array[MAXATOMLEN + 1, char] = [0]
        var msg_print: cstring = malloc(1024)
        var msg_arg: clong
        var pid: erlang_pid
        fprintf(stdout,
                "erl_reg_send: msgtype: %ld buff: %p idx: %d bufsz: %d \n",
                info.msgtype, emsg.buff, emsg.index, emsg.buffsz)
        emsg.index = 0
        ei_s_print_term(addr(msg_print), emsg.buff, addr(emsg.index))
        fprintf(stdout, "term: `%s`\n", msg_print)
        emsg.index = 0
        if ei_decode_version(emsg.buff, addr(emsg.index), addr(version)) < 0:
          fprintf(stderr, "ignoring malformed message (bad version: %d)\n",
                  version)
          return -1
        if ei_decode_tuple_header(emsg.buff, addr(emsg.index), addr(arity)) < 0:
          fprintf(stderr, "ignoring malformed message (not tuple)\n")
          return -1
        if arity != 3:
          fprintf(stderr,
                  "ignoring malformed message (must be a 3-arity tuple)\n")
          return -1
        if ei_decode_atom(emsg.buff, addr(emsg.index), msg_atom) < 0:
          fprintf(stderr,
                  "ignoring malformed message (first tuple element not atom)\n")
          return -1
        if ei_decode_pid(emsg.buff, addr(emsg.index), addr(pid)) < 0:
          fprintf(stderr, "ignoring malformed message (first tuple element of second tuple element not pid)\n")
          return -1
        if ei_decode_tuple_header(emsg.buff, addr(emsg.index), addr(arity)) < 0 or
            arity != 2:
          fprintf(stderr, "ignoring malformed message (second tuple element not 2-arity tuple)\n")
          return -1
        if ei_decode_atom(emsg.buff, addr(emsg.index), msg_atom) < 0:
          fprintf(stderr, "ignoring malformed message (first message tuple element not atom)\n")
          return -1
        if ei_decode_long(emsg.buff, addr(emsg.index), addr(msg_arg)) < 0:
          fprintf(stderr, "ignoring malformed message (second message tuple element not an int)\n")
          return -1
        if strncmp(msg_atom, "foo", 3) == 0:
          fprintf(stderr, "foo: %ld\n", msg_arg)
          res = foo(msg_arg)
        elif strncmp(msg_atom, "bar", 3) == 0:
          fprintf(stderr, "bar: %ld\n", msg_arg)
          res = bar(msg_arg)
        else:
          fprintf(stderr, "other: %ld\n", msg_arg)
          fprintf(stderr, "other message: %s\n", msg_atom)
        ##  set_node_reply(&x_out, msg_arg);
        x_out.index = 0
        ei_x_format(addr(x_out), "{cnode,~i}", msg_arg)
        ei_send(fd, addr(info.`from`), x_out.buff, x_out.index)
        ##  erl_free_term(argp);

proc my_listen*(port: cint): cint =
  var listen_fd: cint
  var `addr`: sockaddr_in
  var on: cint = 1
  if (listen_fd = socket(AF_INET, SOCK_STREAM, 0)) < 0:
    return -1
  setsockopt(listen_fd, SOL_SOCKET, SO_REUSEADDR, addr(on), sizeof((on)))
  memset(cast[pointer](addr(`addr`)), 0, cast[csize](sizeof((`addr`))))
  `addr`.sin_family = AF_INET
  `addr`.sin_port = htons(port)
  `addr`.sin_addr.s_addr = htonl(INADDR_ANY)
  if `bind`(listen_fd, cast[ptr sockaddr](addr(`addr`)), sizeof((`addr`))) < 0:
    return -1
  listen(listen_fd, 5)
  return listen_fd

proc set_node_reply*(x_out: ptr ei_x_buff; val: clong) =
  x_out.index = 0
  cast[nil](ei_x_encode_version(x_out))
  cast[nil](ei_x_encode_tuple_header(x_out, 2))
  cast[nil](ei_x_encode_atom(x_out, "cnode"))
  cast[nil](ei_x_encode_long(x_out, val))

proc new_ei_x_size*(x: ptr ei_x_buff; size: clong): cint =
  x.buff = cast[cstring](ei_malloc(size))
  x.buffsz = size
  x.index = 0
  return if x.buff != nil: 0 else: -1
