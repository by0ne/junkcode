/* didn't check for file descriptor tricks */
/* If this is a setuid program, the attacker can exec() it after closing
   file descriptor 2. The next time the program opens a file, the file
   is associated with file descriptor 2, which is stderr. All output
   directed to stderr will go to the newly opened file. In this example, the 
   attacker creates a symbolic link to the file that is to be overwritten.
   The name of the link contains the data to be written. When the 
   program detects the symbolic link, it prints an error message and exits
   (line 32), but the error message, which contains the symbolic-link name 
   supplied by the attacker, is written into the targeted file.
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
      fprintf (stderr, "%s not a normal file\n", argv[1]); // line 32
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
