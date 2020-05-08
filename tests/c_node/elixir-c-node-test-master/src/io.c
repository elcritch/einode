
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#include "ei.h"
#include "erl_test/io.h"


pthread_mutex_t io_mutex = PTHREAD_MUTEX_INITIALIZER;


int my_listen(int port)
{
  int listen_fd;
  struct sockaddr_in addr;
  int on = 1;

  if ((listen_fd = socket(AF_INET, SOCK_STREAM, 0)) < 0)
    return (-1);

  setsockopt(listen_fd, SOL_SOCKET, SO_REUSEADDR, &on, sizeof(on));

  memset((void *)&addr, 0, (size_t)sizeof(addr));
  addr.sin_family = AF_INET;
  addr.sin_port = htons(port);
  addr.sin_addr.s_addr = htonl(INADDR_ANY);

  if (bind(listen_fd, (struct sockaddr *)&addr, sizeof(addr)) < 0)
    return (-1);

  listen(listen_fd, 5);
  return listen_fd;
}


int start_socket(ei_cnode *ec, struct in_addr *addr, int port, char* node_name, char* hostname, char* ip, char* cookie)
{
    int fd;
    int listen;
    ErlConnect conn;
    int n = 0;
    char full_name[30];

    sprintf(full_name, "%s@%s", node_name, ip);
    if (ei_connect_xinit(ec,
                         hostname,
                         node_name,
                         full_name,
                         addr,
                         cookie,
                         n++) < 0)
    {
        fprintf(stderr, "ERROR when initializing: %d", erl_errno);
        exit(-1);
    }

    /* Make a listen socket */
    if ((listen = my_listen(port)) <= 0)
    {
        fprintf(stderr, "ERROR when initializing socket");
        exit(-1);
        // erl_err_quit("my_listen");
    }

    if (ei_publish(ec, port) == -1)
    {
        fprintf(stderr, "ERROR when trying to publish on the port %d: %d", port, erl_errno);
        exit(-1);
    }
    // erl_err_quit("erl_publish");

    if ((fd = ei_accept(ec, listen, &conn)) == ERL_ERROR)
    {
        fprintf(stderr, "ERROR when accepting a connection: %d", erl_errno);
        exit(-1);
        // erl_err_quit("erl_accept");
    }
    fprintf(stderr, "Connected to %s\n\r", conn.nodename);
    return fd;
}

int receive_msg(int fd, erlang_msg *emsg, ei_x_buff *buf) {
    int got;
    // pthread_mutex_lock(&io_mutex);
    got = ei_xreceive_msg(fd, emsg, buf);
    // pthread_mutex_unlock(&io_mutex);
    return got;
}

int send_msg(int fd, erlang_pid *to, ei_x_buff *buff) {
    int got;
    // pthread_mutex_lock(&io_mutex);
    got = ei_send(fd, to, buff -> buff, buff -> index);
    // got = write(fd, msg, sizeof(msg_struct));
    // pthread_mutex_unlock(&io_mutex);
    return got;
}
