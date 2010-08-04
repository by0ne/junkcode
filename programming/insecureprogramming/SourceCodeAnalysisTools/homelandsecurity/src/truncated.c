
/* Secure-Programs-HOWTO/dangers-c.html */

/* This program contains an integer truncation error. Superficially it looks
   like a safe program even though the variable len is tainted and 
   len is used to determine the number of bytes read on line 18. It seems
   as though the buffer is large enough to accomodate whatever data ends
   up being placed there by the read statment. However, the program has
   a customized malloc function that takes an int argument, so in reality
   the malloc on line 3 doesn't always see the same argument as the read on 
   line 18. A value of len larger than 2*MAXINT allows a buffer overflow on 
   line 18.

   This example is somewhat contrived because of the large amount of memory
   that would have to be allocated for an exploit to succeed. On many
   architectures, len cannot be greater than 2*MAXINT.
*/

#include <stdlib.h>

void *mymalloc(unsigned int size) { return malloc(size); }   // line 3
 
void func(int fd)
{

/* An example of an ERROR for some 64-bit architectures,
    if "unsigned int" is 32 bits and "size_t" is 64 bits: */
 
  char *buf;
  size_t len;
  
  read(fd, &len, sizeof(len));
  
  /* we forgot to check the maximum length */
  
  /* 64-bit size_t gets truncated to 32-bit unsigned int */
  buf = mymalloc(len);
  read(fd, buf, len);                                         // line 18
}

