
/* This program complements truncated.c, which is taken from the linux
   secure programming HOWTO. It avoids the integer truncation problem of
   truncated.c, and it's meant to test whether a scanner that reports a
   buffer overflow for truncated.c is doing so vacuously or whether it
   actually noticed the possible integer truncation.

   In this file, we read a tainted integer and use it to determine the size
   of a subsequent read of a tainted string. But the buffer recieving the
   data during the second read is allocated according to user provided length,
   and read will only put that many bytes in the buffer, so there should
   be no overflow.

   In this particular variant of the program, the user has defined his 
   own version of the malloc function which takes an int argument and
   thereby creates the possibility of an integer truncation vulnerability.
   However, the program casts "len" to an integer and thereby ensures that the 
   second argument to read (line 18) is the same number as the argument of
   mymalloc on line 17.

   Ideally, a security scanner should not report a possible bounds
   violation on line 17 or a buffer overflow on line 18.
*/


#include <values.h>
#include <stdlib.h>

void *mymalloc(unsigned int size) { return malloc(size); }
 
void func(int fd)
{

  char *buf;
  size_t len;
  int actual_len;

  read(fd, &len, sizeof(len));

  
  actual_len = len;

  buf = mymalloc(actual_len);                    // line 17
  read(fd, buf, actual_len);                     // line 18
}

