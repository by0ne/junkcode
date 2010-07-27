
/* believed safe invocation of strcpy */

/* This use of strcpy ensures that the buffer is large enough to
   accomodate the string being copied. The dataflow analysis needed
   to verify this mey be too complex to be accomplished with simple
   taint checking.

   A scanner should not warn of a buffer overflow error on line 9
*/

#include <string.h>

char *strsave(char *src)
{
  size_t len = strlen(src);
  char *result = (char *)malloc((len+1) * sizeof(char));

  if (result)
    strcpy(result, src);                               // line 9

  return result;
}

