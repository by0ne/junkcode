
/* variable-sized buffer that syntactically looks like fixed-sized buffer #1 */

/* Many security scanners generate a warning when they see a fixed-sized
   buffer. This test program declares a variable-sized buffer based on
   the length of the string that's going to be copied into it, but it
   uses a syntax more commonly associated with fixed-sized buffers. It's
   meant to determine whether a scanner detects fixed-sized buffers by looking 
   for square brackets after the variable name or whether it actually parses 
   the declaration.

   A scanner should not complain about a fixed-sized buffer being used
   in this program.
*/

#include <string.h>

void func(char *src)
{
  char dst[(strlen(src) + 1) * sizeof(char)];
  strncpy(dst, src, strlen(src) + sizeof(char));
  dst[strlen(dst)] = 0;
}

