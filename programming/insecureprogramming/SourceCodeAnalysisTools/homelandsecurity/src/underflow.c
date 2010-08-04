
/* Here, the developer is getting a pathname as an argument and wants
   to find the first path component. The error is that the path 
   in str might start with a '/', in which case len is zero and 
   len-1 is the largest value possible for a size_t. In that particular
   case the strncpy in the else clause is no safer than a strcpy.
*/


#include <stdlib.h>

void func(char *str)
{
  char buf[1024];

  size_t len;
  char *firstslash = strchr(str, '/');

  if (!firstslash)
    strncpy(buf, str, 1023);  /* leave room for the zero */
    buf[1023] = 0;
  else
  {
    len = firstslash - str;     /* length of the first path component */

    if (len > 1023)
      len = 1023;

    strncpy(buf, str, len-1);   /* cut the slash off. Only copy len-1
				   characters to avoid zero padding.  */
    buf[len] = 0;
  }
}

