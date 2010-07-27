
/* If this is a setuid program, the attacker can exec() it after closing
   file descriptor 2. The next time the program opens a file, the file
   is associated with file descriptor 2, which is stderr. All output
   directed to stderr will go to the newly opened file. In this example, the 
   attacker creates a symbolic link to the file that is to be overwritten.
   The name of the link contains the data to be written. When the 
   program detects the symbolic link, it prints an error message and exits,
   but the error message, which contains the symbolic link name supplied by
   the attacker, is written into the targeted file. This isn't much different 
   from ex_02.c, but the latter program was found on the web claiming to 
   be a secure way of opening files. This program is somewhat simpler
   and, for some scanners, might make it easier to tell what the scanner
   is printing warnings about.
*/

#include <stdio.h>
#define DATAFILE "/etc/aDataFile.data"


main(int argc, char **argv)
{
  FILE *sensitiveData = NULL;
  FILE *logFile = NULL;

  /* Forgot to account for files 0-2, could be opening stderr. */

  sensitiveData = fopen(DATAFILE, "w");

  if (!sensitiveData)
  {
    fprintf(stderr, "%s: failed to open %s\n",
	    argv[0], DATAFILE);
    exit(1);
  }

  logFile = fopen(argv[1], "w");

  if (!logFile)
  {
    fprintf(stderr, "%s: failed to open %s\n",
	    argv[0], argv[1]);
    exit(1);
  }
}

