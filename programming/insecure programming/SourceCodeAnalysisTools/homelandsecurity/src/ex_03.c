/* stat called on filename */
/* This is a simple race condition, allowing the attacker to change the file
   named in argv[1] to a symbolic link after it's tested but before the file 
   is opened. 

   Many scanners detect the call to stat() on line 23, and while stat() is
   almost certainly a sign of trouble in this particular context, it
   needn't always be. A better scanner would actually detect the race
   condition between the open on line line 14 and the stat on line 23.
*/

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
    
    while((fd = open("/dev/null", O_RDWR)) == 0 || fd == 1 || fd == 2); //ln 14
    if (fd > 2)
      close(fd);

    if (argc != 3) {
        fprintf (stderr, "usage : %s file message\n", argv [0]);
        exit(EXIT_FAILURE);
    }
    stat (argv[1], & st);                                       // line 23
    if (st . st_uid != getuid ()) {
        fprintf (stderr, "%s not owner !\n", argv [1]);
        exit(EXIT_FAILURE);
    }
    if (! S_ISREG (st . st_mode)) {
        fprintf (stderr, "%s not a normal file\n", argv[1]);
        exit(EXIT_FAILURE);
    }
    if ((fd = open (argv [1], O_WRONLY, 0)) < 0) {
        fprintf (stderr, "Can't open %s\n", argv [1]);
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
