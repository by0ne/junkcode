
/* believed unexploitable open/write */

/* This program ensures that stdin, stdout and stderr are accounted for,
   and then opens a file, ensuring that access checks are performed on
   the actual object being opened. The program doesn't set the umask, but that
   isn't necessary because the umask only affects the permissions of newly
   created files, and in this program open is called without the O_CREAT
   flag and therefore will only open a pre-existing file.

   A scanner should not report TOCTOU vulnerabilities, file descriptor
   vulnerabilities or umask-related vulnerabilities.
*/

/* ex_02.c */
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/types.h>

int
main (int argc, char * argv [])
{
    struct stat st;
    int fd;
    FILE * fp;
    

    while((fd = open("/dev/null", O_RDWR)) == 0 || fd == 1 || fd == 2) ;
    if (fd > 2)
      close(fd);

    if (argc != 3) {
        fprintf (stderr, "usage : %s file message\n", argv [0]);
        exit(EXIT_FAILURE);
    }
    if ((fd = open (argv [1], O_WRONLY, 0)) < 0) {
        fprintf (stderr, "Can't open %s\n", argv [1]);
        exit(EXIT_FAILURE);
    }
    fstat (fd, & st);
    if (st . st_uid != getuid ()) {
        fprintf (stderr, "%s not owner !\n", argv [1]);
        exit(EXIT_FAILURE);
    }
    if (! S_ISREG (st . st_mode)) {
        fprintf (stderr, "%s not a normal file\n", argv[1]);
        exit(EXIT_FAILURE);
    }
    if ((fp = fdopen (fd, "w")) == NULL) {
        fprintf (stderr, "Can't open\n");
        exit(EXIT_FAILURE);
    }
    fprintf (fp, "%s", argv [2]);
    fclose (fp);
    fprintf (stderr, "Write Ok\n");
    exit(EXIT_SUCCESS);
}

