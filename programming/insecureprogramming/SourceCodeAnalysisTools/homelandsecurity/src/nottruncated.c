
/* This program complements truncated.c, which is taken from the linux
   secure programming HOWTO. It avoids the integer truncation problem of
   truncated.c, and it's meant to test whether a scanner that reports a
   buffer overflow for truncated.c is doing so vacuously or whether it
   actually noticed the possible integer truncation.

   In this program, the developer has defined a custom
   version of the malloc function which takes an int argument, and
   thereby creates the possibility of an integer truncation vulnerability,
   but bounds-checking prevents the malloc on line 1 from seeing
   a different length value than the read on line 16.

   This program differs from nottruncated2.c because both
   mymalloc and read take the original user-controlled size_t len as an
   argument, but those calls are unreachable for values of len that would
   cause truncation problems.

   Ideally, a security scanner should not report a possible bounds
   violation on line 15 or a buffer overflow on line 16.
*/


#include <values.h>
#include <stdlib.h>

void *mymalloc(unsigned int size) { return malloc(size); } // line 1
 
void func(int fd)
{

  char *buf;
  size_t len;

  read(fd, &len, sizeof(len));

  
  if (len > MAXINT)
    return;

  buf = mymalloc(len);                           // line 15
  read(fd, buf, len);                            // line 16
}

