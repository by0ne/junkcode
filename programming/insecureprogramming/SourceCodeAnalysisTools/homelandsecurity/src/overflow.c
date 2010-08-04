
/* Secure-Programs-HOWTO/dangers-c.html */

/* In this program, an attacker can supply a large value of len which 
   overflows to zero on line 14. Since the subsequent read on line 15
   uses the original value of len, the read can overflow the buffer.

   Many scanners will flag the read no matter what, which is useful but
   doesn't reflect what this program is trying to test. The complementary
   program notoverflow.c is meant to check whether a scanner is actually
   detecting the possible overflow.
*/

#include <stdlib.h>

void func(int fd)
{

/* 3) integer overflow */
 char *buf;
 size_t len;
 
 read(fd, &len, sizeof(len));
 
 /* we forgot to check the maximum length */
 
 buf = malloc(len+1);                        // line 14
 read(fd, buf, len);                         // line 15
 buf[len] = '\0';
}

