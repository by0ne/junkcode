
/* forgot to set umask */
/* umask() controls the permissions of created by the open call, but the
   permission mask is passed to the child process in an exec(). If this
   is a setuid program, the attacker can set a permission mask that makes
   these files world-writable, but the new file may be a system-critical
   one. In this program, the programmer uses the umask that existed when
   the program was exec()ed, but that umask might be controlled by an
   attacker.
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


  /* file is in user-unwritable directory */

  fp = fopen("/etc/importantFile", "w");   
  
  fclose(fp);
}

