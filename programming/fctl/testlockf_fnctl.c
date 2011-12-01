#include <unistd.h>
#include <fcntl.h>
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

    {
        struct flock lock_opts;
        lock_opts.l_type = F_WRLCK;
        lock_opts.l_whence = SEEK_SET;
        lock_opts.l_start = 0;
        lock_opts.l_len = 0;

        printf("Trying to lock...\n");

        result = fcntl(fd, F_SETLKW, &lock_opts);
        if(result == -1)
        {
            printf("fcntl() failed\n");
            return 1;
        }
    }

    printf("Lock acquired\n");

while(1)
        sleep(1);
}

