
/* variable-sized buffer that syntactically looks like fixed-sized buffer #2 */

/* This is another variant of a variable-sized buffer being made to
   syntactically resemble a fixed-sized buffer. It has the added twist 
   the buffer might be to small if useString is called incorrectly, in spite 
   of which there is no buffer overflow here because useString -is- called 
   correctly (and is inaccesible from other source files).

   A scanner should not complain about a fixed-sized buffer or a potential
   buffer overflow.
*/

#include <string.h>

static void useString(size_t len, char *src)
{
  char dst[(len+1) * sizeof(char)];
  strncpy(dst, src, strlen(src));
  dst[strlen(src)] = 0;
}

void func(char *src)
{
  size_t len = strlen(src);

  useString(len, src);
}

