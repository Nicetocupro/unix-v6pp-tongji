#include <stdio.h>
#include <sys.h>

int main1()
{
    int i, j, k, pid, ppid;
    if (fork())
    {
        // 2#
        sleep(2);
        for (k = 1; k < 6; k++)
        {
            printf("%d,%d; ", k, getppid(k));
        }
        printf("\n");
    }
    else
    {
        // 3#
        if (fork())
        {
            if (fork())
            {
                // 3#
                pid = getpid();
                ppid = getppid(pid);
                sleep(1); // Ìí¼Ó sleep ²Ù×÷
                printf("Process %d# finished: My father is %d\n", pid, ppid);
                exit(ppid);
            }
            else
            {
                // 5#
                pid = getpid();
                ppid = getppid(pid);
                printf("Process %d# finished: My father is %d\n", pid, ppid);
                exit(ppid);
            }
        }
        else
        {
            // 4#
            pid = getpid();
            ppid = getppid(pid);
            printf("Process %d# finished: My father is %d\n", pid, ppid);
            exit(ppid);
        }
    }
}