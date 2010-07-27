
/* This program tests the scanner's ability to handle preprocessor
   directives.
*/

#include <stdio.h>

#define SAFESTRCPY(a,b,c) strncpy(a, b, c)
#define FASTSTRCPY(a,b,c) strcpy(a, b)

main(int argc, char **argv)
{
  size_t size = strlen(argv[3]);
  char *buffer = (char *)malloc(1024);

#ifdef PARANOID
  SAFESTRCPY(buffer, argv[3], size+sizeof(char));
#else
  FASTSTRCPY(buffer, argv[3], size+sizeof(char));
#endif  
}

