/*3. Linux program to open a file and lock it with flock():
=============================================*/
#include <sys/file.h>
#include <unistd.h>
#include <stdio.h>

main(int argc, char** argv)
{
        int result;
        int fd = -1;
        char* filename = NULL;

        if(argc < 2)
        {
                printf("No argument\n");
                return 2;
        }
        else
        {
                filename = argv[1];
        }

        fd = open(filename, O_RDWR);
        if(-1 == fd)
        {
                printf("open() failed\n");
                return 1;
        }

        printf("Trying to lock...\n");

        result = flock(fd, LOCK_EX);
        if(result != 0)
        {
                printf("flock() failed\n");
                return 1;
        }

        printf("Lock acquired\n");

        while(1)
                sleep(1);
