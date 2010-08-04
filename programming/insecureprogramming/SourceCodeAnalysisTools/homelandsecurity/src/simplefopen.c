
/* This is a simple resource-spoofing vulnerability where the characteristics
   of a fopened file are completely unchecked. (Often this would be called a
   race condition as well, but technically it isn't since the necessary checks
   are missing entirely.) First-generation scanners would be expected to 
   generate warnings on this file because of the fopen(). This test is meant
   for scanners that don't warn about anything un ex2_unex.c; it checks whether
   they just ignore open() calls altogether (ignoring open() isn't what
   ex2_unex is testing for, needless to say).
*/

#include <stdio.h>

void func()
{
  FILE *aFile = fopen("/tmp/tmpfile", "w");
  fprintf(aFile, "%s", "hello world");
  fclose(aFile);
}

