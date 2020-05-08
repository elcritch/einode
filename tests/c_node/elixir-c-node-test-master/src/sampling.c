
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>

#include "ei.h"
#include "erl_test/sampling.h"
#include "erl_test/io.h"

pthread_t sampling_thread;
pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
int sample_flag;

void start_sampling(node_s *conn_info)
{
    int res;
    if ((res = pthread_create(&sampling_thread, NULL, (thread_func)&sample_values, (void *)conn_info)))
    {
        fprintf(stderr, "Thread creation failed: %d\n", res);
    }
}

int continue_sampling(void)
{
    pthread_mutex_lock(&mutex);
    int continue_s = sample_flag == 1;
    pthread_mutex_unlock(&mutex);
    return continue_s;
}

void stop_sampling(void)
{
    pthread_mutex_lock(&mutex);
    sample_flag = 0;
    pthread_mutex_unlock(&mutex);
    pthread_join(sampling_thread, NULL);
}

void *sample_values(void *in)
{
    // sender_info *conn_info;
    // conn_info = (sender_info *)in;
    sample_flag = 1;
    // erlang_pid *self = ei_self(conn_info->ec);
    // int fd = conn_info->fd;
    // erlang_pid *to = &(conn_info->pid);

    // int port;            /* Listen port number */
    int fd;          /* fd to Erlang node */
    ei_cnode ec;     /* C node information */
    ErlConnect conn; /* Connection data */
    int got;

    node_s *node;
    node = (node_s *)in;

    fd = start_socket(&ec, node->addr, node->port, node->node_name,
                      node->hostname, node->ip, node->cookie);

    while (continue_sampling())
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
                fprintf(stderr, "Unexpected disconnection\n");
                stop_sampling();
            }
        }
        else
        {

            if (emsg.msgtype == ERL_REG_SEND)
            {
                fprintf(stderr, "Time to sample\n");
                int index = 1; // Set to 1 due to version byte
                ei_term term;
                int size;
                int type;
                char *buff = buf.buff;
                int res = ei_decode_ei_term(buff, &index, &term);

                ei_x_buff tuple_buff;
                ei_x_new_with_version(&tuple_buff);
                ei_x_encode_tuple_header(&tuple_buff, 3);
                ei_x_encode_atom(&tuple_buff, "samples");
                ei_x_encode_atom(&tuple_buff, node->node_name);
                ei_x_encode_map_header(&tuple_buff, 1);
                ei_x_encode_atom(&tuple_buff, "value");
                ei_x_encode_long(&tuple_buff, (long) 2);
                // ei_send(fd, to, tuple_buff.buff, tuple_buff.index);
                send_msg(fd, &term.value.pid, &tuple_buff);
                // fprintf(stderr, "Waiting for 5 secs\n");
                // sleep(5);
                ei_x_free(&tuple_buff);
            }
        }
        ei_x_free(&buf);
    }
}

