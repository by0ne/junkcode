
/* 
   This use of strcpy ensures that the buffer is large enough to
   accomodate the string being copied. The dataflow analysis needed to
   determine whether the strcpy is safe is somewhat more complex that
   in strsave.c

   A scanner should not warn of a buffer overflow error on line 5.
*/


#include <string.h>

static void copyString(char *dst, char *src)
{
  strcpy(dst, src);                           // line 5
}

char *strsave(char *src)
{
  size_t len = strlen(src);
  char *result = (char *)malloc((len + 1) * sizeof(char));

  if (result)
    copyString(result, src);

  return result;
}

