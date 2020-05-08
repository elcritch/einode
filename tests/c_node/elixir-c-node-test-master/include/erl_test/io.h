#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>

#include "ei.h"

#ifndef __IO_H
#define __IO_H

extern pthread_mutex_t io_mutex;


typedef struct {
    erlang_pid *recipient;
    ei_x_buff* buff;
} msg_struct;

int my_listen(int port);
int start_socket(ei_cnode *ec, struct in_addr *addr, int port, char* node_name, char* hostname, char* ip, char* cookie);
int send_msg(int fd, erlang_pid *to, ei_x_buff *buff);
int receive_msg(int fd, erlang_msg *emsg, ei_x_buff *buf);

#endif