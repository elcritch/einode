
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

#include "ei.h"
#include "erl_test/dispatchers.h"
#include "erl_test/sampling.h"
#include "erl_test/uthash.h"

func_dispatcher *functions;

void register_handler(char *name, message_handler func)
{
    func_dispatcher *s = malloc(sizeof(func_dispatcher));
    strcpy(s->func_name, name);
    s->func = func;
    HASH_ADD_STR(functions, func_name, s);
}

void kill_process(char *buff, int *index, ei_cnode cnode, erlang_pid pid, int fd)
{
    (void) cnode;
    fprintf(stderr, "Kill should be called here\n");
    ei_term term;
    int res = ei_decode_ei_term(buff, index, &term);
}

void sampling(char *buff, int *index, ei_cnode cnode, erlang_pid pid, int fd) {
    fprintf(stderr, "Sampling should start here");
    sender_info info;
    info.ec = &cnode;
    info.fd = fd;
    info.pid = pid;
    // start_sampling(&info);
}

void register_handlers(void)
{
    fprintf(stderr, "Registering functions\n");
    register_handler("kill", &kill_process);
    register_handler("start_sampling", &sampling);
}
