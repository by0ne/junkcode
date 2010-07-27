
/* 
   In this example, the attacker controls the third argument of strncpy,
   making it unsafe.
*/


#include <stdio.h>

main(int argc, char **argv)
{
  int incorrectSize = atoi(argv[1]);
  int correctSize = atoi(argv[2]);
  char *buffer = (char *)malloc(correctSize+1);


  /* number of characters copied is based on user-supplied value */

  strncpy(buffer, argv[3], incorrectSize);
}

