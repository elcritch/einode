#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <sys/eventfd.h>
#include <sys/select.h>
#include <sys/epoll.h>
#include <unistd.h>
#include <pthread.h>
#include <assert.h>

// #include "erl_interface.h"
#include "ei.h"

#include "erl_test/io.h"
#include "erl_test/spawn.h"
#include "erl_test/utils.h"
#include "erl_test/sampling.h"
#include "erl_test/dispatchers.h"

#define BUFSIZE 1000
#define MAX_EVENTS 10


int main(int argc, char **argv)
{
  (void)argc;

  const char *epmd_argv[64] = {"epmd", "-daemon", NULL}; /* EPMD args */

  // char *epmd_argv[] = { "epmd", "-daemon", NULL };


  int loop = 1; /* Lopp flag */
  int got;      /* Result of receive */
  // unsigned char buf[BUFSIZE]; /* Buffer for incoming message */

  // ETERM *fromp, *tuplep, *fnp, *argp, *resp;
  int res;

  register_handlers();

  int port = atoi(argv[1]);
  int sampling_port = atoi(argv[2]);

  ei_init();

  // Starting EPMD before starting node
  // int rc = spawn_epmd();

  struct in_addr addr; /* 32-bit IP number of host */
  addr.s_addr = inet_addr("127.0.0.1");

  node_s sampling_info;
  sampling_info.addr = &addr;
  sampling_info.cookie = "secretcookie";
  sampling_info.hostname = "localhost";
  sampling_info.ip = "127.0.0.1";
  sampling_info.node_name = "sampling";
  sampling_info.port = sampling_port;

  start_sampling(&sampling_info);

  ei_cnode ec;     /* C node information */
  // ErlConnect conn; /* Connection data */
  int fd = start_socket(&ec, &addr, port, "cmd", "localhost", "127.0.0.1", "secretcookie");

  // Initialize eventfd signaling
  int efd = eventfd(0, 0);
  int max_fd = efd;

  int n_bytes = sizeof(msg_struct);

  struct epoll_event event, events[MAX_EVENTS];

  int epollfd = epoll_create1(0);
  if (epollfd == -1)
  {
    perror("epoll_create1");
    exit(EXIT_FAILURE);
  }

  event.events = EPOLLIN; // | EPOLLOUT;
  event.data.fd = fd;

  if (epoll_ctl(epollfd, EPOLL_CTL_ADD, fd, &event) == -1)
  {
    perror("epoll_ctl: listen_sock");
    exit(EXIT_FAILURE);
  }

  while (loop)
  {
    fprintf(stderr, "Waiting for events!\n");
    int nfds = epoll_wait(epollfd, events, MAX_EVENTS, -1);
    fprintf(stderr, "%d available events!\n", nfds);
    for (int n = 0; n < nfds; n++)
    {
      if (events[n].events & EPOLLIN)
      {
        ei_x_buff buf;   /* Buffer for incoming message */
        erlang_msg emsg; /* Incoming message */
        ei_x_new_with_version(&buf);
        fprintf(stderr, "Waiting for a message to come?\n");
        // got = ei_xreceive_msg(fd, &emsg, &buf);
        got = receive_msg(fd, &emsg, &buf);
        fprintf(stderr, "Got message %d\n", got);
        if (got == ERL_TICK)
        {
          /* ignore */
        }
        else if (got == ERL_ERROR)
        {
          if (erl_errno != ERL_TIMEOUT)
          {
            loop = 0;
            fprintf(stderr, "Unexpected disconnection\n");
          }
        }
        else
        {

          if (emsg.msgtype == ERL_REG_SEND)
          {
            fprintf(stderr, "Some call goes here\n");
            int index = 1; // Set to 1 due to version byte
            ei_term term;
            int size;
            int type;
            char *buff = buf.buff;
            res = ei_decode_ei_term(buff, &index, &term);
            char term_type = term.ei_type;
            switch (term_type)
            {
            case ERL_SMALL_TUPLE_EXT:
              process_tuple(buff, &index, term.arity, ec, efd);
              break;

            default:
              break;
            }
          }
        }
        ei_x_free(&buf);
      }
      if (events[n].events & EPOLLOUT) {
        fprintf(stderr, "Available to write\n");
      }
    }

  }
}