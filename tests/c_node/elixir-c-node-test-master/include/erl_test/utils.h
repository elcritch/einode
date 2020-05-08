
#include <stdio.h>
#include <stdlib.h>

#include "ei.h"

#ifndef __UTILS_H
#define __UTILS_H

void dispatch_message(char *msg_type, char *buff, int *index, int size,
                      ei_cnode cnode, erlang_pid pid, int fd);
void process_tuple(char* buff, int *index, int size, ei_cnode cnode, int fd);

#endif  // _UTILS_H