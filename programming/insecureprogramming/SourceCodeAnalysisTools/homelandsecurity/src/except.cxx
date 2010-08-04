
/*
   The catch block in this program contains an exploitable format-string
   vulnerability. The idea of this test to see whether the scanner can track 
   taint through the exception-handler. Ideally, the scanner should report
   a format string vulnerability on line 32, but not report the unexploitable
   format string vulnerability in the complementary program unexcept.c.
*/

#include <stdio.h>
#include <ctype.h>
#include <string.h>

void func()
{
  char buffer[1024];
  printf("Please enter your user id :");
  fgets(buffer, 1024, stdin);

  if (!isalpha(buffer[0]))
  {
    char errormsg[1044];

    strncpy(errormsg, buffer, 1024);         // guaranteed to be terminated
    strcat(errormsg, " is not a valid ID");  // we have room for this
    throw errormsg;
  }

}


main()
{
  try
  {
    func();
  }
  catch(char * message)
  {
    fprintf(stderr, message);                // line 32
  }
}

