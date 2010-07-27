
/* This program opens a file with a fixed name in a directory that
   shouldn't normally be accessible to an attacker. If, for some reason,
   the attacker has gained write access to /etc, this program could be used
   to overwrite files in other places, but the vulnerability is less 
   serious than it would be if it opened a file in a directory that's normally
   writable.
*/

#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

main()
{
  int fd;
  FILE *fp;

  /* no file descriptor confusion */

  while((fd = open("/dev/null", O_RDWR)) == 0 || fd == 1 || fd == 2) ;
  if (fd > 2)
    close(fd);


  /* set umask */

  umask(022);

  /* file is in user-unwritable directory */

  fp = fopen("/etc/importantFile", "w");   
  
  fclose(fp);
}

