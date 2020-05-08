#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>

#include "ei.h"

#ifndef __SAMPLING_H
#define __SAMPLING_H

extern pthread_t sampling_thread;
extern pthread_mutex_t mutex;

typedef void* (*thread_func)(void*);

typedef struct {
    ei_cnode* ec;
    int fd;
    char* server_name;
    erlang_pid pid;
} sender_info;

typedef struct {
    char* node_name;
    char* ip;
    int port;
    char* hostname;
    char* cookie;
    struct in_addr *addr;
} node_s;

void start_sampling(node_s* node_info);
int continue_sampling(void);
void stop_sampling(void);
void* sample_values(void* in);


#endif  // _SAMPLING_H
