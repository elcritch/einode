#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ei.h"
#include "erl_test/utils.h"
#include "erl_test/uthash.h"
#include "erl_test/dispatchers.h"


void process_tuple(char *buff, int *index, int size, ei_cnode cnode, int fd)
{
  // ei_term term;
  // int res = ei_decode_ei_term(buff, index, &term);
  // if(res) {
  // for (int i = 0; i < size; i++)
  // {
  ei_term term;
  char *msg_type;
  int res = ei_decode_ei_term(buff, index, &term);
  fprintf(stderr, "Term decoding result: %d\n", res);
  fprintf(stderr, "Current index: %d\n", *index);

  char term_type = term.ei_type;
  switch (term_type)
  {
  case ERL_SMALL_TUPLE_EXT:
    process_tuple(buff, index, term.arity, cnode, fd);
    break;
  case ERL_SMALL_ATOM_UTF8_EXT:
    msg_type = term.value.atom_name;
    // erlang_pid pid = term.value.pid;
    ei_term pid_term;
    res = ei_decode_ei_term(buff, index, &pid_term);
    erlang_pid pid = pid_term.value.pid;
    dispatch_message(msg_type, buff, index, size, cnode, pid, fd);
    break;
  default:
    break;
  }
  // }
  // }
}

void dispatch_message(char *msg_type, char *buff, int *index, int size,
                      ei_cnode cnode, erlang_pid pid, int fd)
{
  (void) size;
  func_dispatcher *s;
  HASH_FIND_STR(functions, msg_type, s);
  if (s)
  {
    message_handler func = s->func;
    func(buff, index, cnode, pid, fd);
  }
}
