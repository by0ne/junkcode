
/* based on the incorrect statement: "umask sets the umask to mask & 0777."
   in the umask man page.
*/

/* In reality umask sets the mask to 0777 & ~mask, which is also 
   contrary to the convention for chmod that most people are accustomed to. 
   (However, the correct usage is given lower down on the umask man page).
   Below, the programmer uses umask to give the rest of the world full access 
   to the newly created file while denying access to him or herself, which 
   can safely be assumed to be a programming error.

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


  umask(700);  /* set permissions to ----rwxrwx */

  /* file is in user-unwritable directory */

  fp = fopen("/etc/importantFile", "w");   
  
  fclose(fp);
}

