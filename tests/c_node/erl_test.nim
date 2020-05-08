##  #include "erl_interface.h"

import
  ei, erl_test/io, erl_test/spawn, erl_test/utils, erl_test/sampling,
  erl_test/dispatchers

const
  BUFSIZE* = 1000
  MAX_EVENTS* = 10

proc main*(argc: cint; argv: cstringArray): cint =
  cast[nil](argc)
  var epmd_argv: array[64, cstring] = ["epmd", "-daemon", nil]
  ##  EPMD args
  ##  char *epmd_argv[] = { "epmd", "-daemon", NULL };
  var `addr`: in_addr
  ##  32-bit IP number of host
  var port: cint
  ##  Listen port number
  var listen: cint
  ##  Listen socket
  var fd: cint
  ##  fd to Erlang node
  var efd: cint
  var max_fd: cint
  var n_bytes: cint
  var nfds: cint
  var outgoing: msg_struct
  var n: cint = 0
  var ec: ei_cnode
  ##  C node information
  var conn: ErlConnect
  ##  Connection data
  var loop: cint = 1
  ##  Lopp flag
  var got: cint
  ##  Result of receive
  ##  unsigned char buf[BUFSIZE]; /* Buffer for incoming message */
  ##  ETERM *fromp, *tuplep, *fnp, *argp, *resp;
  var res: cint
  register_handlers()
  port = atoi(argv[1])
  var sampling_port: cint = atoi(argv[2])
  ei_init()
  ##  Starting EPMD before starting node
  var rc: cint = spawn_epmd()
  `addr`.s_addr = inet_addr("127.0.0.1")
  var sampling_info: node_s
  sampling_info.`addr` = addr(`addr`)
  sampling_info.cookie = "secretcookie"
  sampling_info.hostname = "localhost"
  sampling_info.ip = "127.0.0.1"
  sampling_info.node_name = "sampling"
  sampling_info.port = sampling_port
  ##  if (ei_connect_xinit("localhost", "testc", "test@127.0.0.1",
  ##    &addr, "secretcookie", 0) == -1)
  ##      erl_err_quit("erl_connect_xinit");
  start_sampling(addr(sampling_info))
  fd = start_socket(
        addr(ec),
        addr(`addr`),
        port,
        "cmd",
        "localhost",
        "127.0.0.1",
        "secretcookie")
  ##  Initialize eventfd signaling
  efd = eventfd(0, 0)
  max_fd = efd
  ##  fd_set master;
  ##  FD_ZERO(&master);
  ##  safe_fd_set(efd, &master, &max_fd);
  ##  safe_fd_set(fd, &master, &max_fd);
  n_bytes = sizeof((msg_struct))
  var
    event: epoll_event
    events: array[MAX_EVENTS, epoll_event]
  var epollfd: cint = epoll_create1(0)
  if epollfd == -1:
    perror("epoll_create1")
    exit(EXIT_FAILURE)
  event.events = EPOLLIN
  ##  | EPOLLOUT;
  event.data.fd = fd
  if epoll_ctl(epollfd, EPOLL_CTL_ADD, fd, addr(event)) == -1:
    perror("epoll_ctl: listen_sock")
    exit(EXIT_FAILURE)
  while loop:
    fprintf(stderr, "Waiting for events!\n")
    nfds = epoll_wait(epollfd, events, MAX_EVENTS, -1)
    fprintf(stderr, "%d available events!\n", nfds)
    var n: cint = 0
    while n < nfds:
      if events[n].events and EPOLLIN:
        var buf: ei_x_buff
        ##  Buffer for incoming message
        var emsg: erlang_msg
        ##  Incoming message
        ei_x_new_with_version(addr(buf))
        fprintf(stderr, "Waiting for a message to come?\n")
        ##  got = ei_xreceive_msg(fd, &emsg, &buf);
        got = receive_msg(fd, addr(emsg), addr(buf))
        fprintf(stderr, "Got message %d\n", got)
        if got == ERL_TICK:
          ##  ignore
        elif got == ERL_ERROR:
          if erl_errno != ERL_TIMEOUT:
            loop = 0
            fprintf(stderr, "Unexpected disconnection\n")
        else:
          if emsg.msgtype == ERL_REG_SEND:
            fprintf(stderr, "Some call goes here\n")
            var index: cint = 1
            ##  Set to 1 due to version byte
            var term: ei_term
            var size: cint
            var `type`: cint
            var buff: cstring = buf.buff
            res = ei_decode_ei_term(buff, addr(index), addr(term))
            var term_type: char = term.ei_type
            case term_type
            of ERL_SMALL_TUPLE_EXT:
              process_tuple(buff, addr(index), term.arity, ec, efd)
            else:
              nil
        ei_x_free(addr(buf))
      if events[n].events and EPOLLOUT:
        fprintf(stderr, "Available to write\n")
      inc(n)
