
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>

#include "erl_test/spawn.h"


int spawn_epmd(void)
{
    pid_t my_pid;
    int status, timeout /* unused ifdef WAIT_FOR_COMPLETION */;

    // char *env_args[] = {
    //     "PATH=/bin:/usr/bin",
    //     NULL
    // };

    char *argv[] = { "/usr/bin/epmd", "-daemon", NULL };
    char *envp[] =
    {
        "HOME=/",
        "PATH=/bin:/usr/bin",
        NULL
    };

    if (0 == (my_pid = fork()))
    {
        if (-1 == execve(argv[0], &argv[0], envp))
        {
            // fprintf(stderr, "Error spawning EPMD");
            perror("child process execve failed [%m]");
            return -1;
        }
    }
    sleep(1);
    return 0;
}
