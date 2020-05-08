#include <stdio.h>
#include <stdlib.h>

#include "ei.h"
#include "erl_test/uthash.h"

#ifndef __DISPATCHERS_H
#define __DISPATCHERS_H

typedef void (*message_handler)(char *, int *, ei_cnode, erlang_pid, int);

void kill_process(char *buff, int *index, ei_cnode cnode, erlang_pid pid, int fd);
void sampling(char *buff, int *index, ei_cnode cnode, erlang_pid pid, int fd);
void register_handler(char *name, message_handler func);
void register_handlers(void);

typedef struct
{
    char func_name[15];
    message_handler func;
    UT_hash_handle hh;
} func_dispatcher;

extern func_dispatcher *functions;

#endif // _DISPATCHERS_H