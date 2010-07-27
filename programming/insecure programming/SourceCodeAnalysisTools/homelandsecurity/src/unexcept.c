
/*
   The catch block in this program contains an unexploitable format-string
   vulnerability. The idea of this test to see whether the scanner can track 
   taint through the exception-handling mechanism. Ideally, the warning given
   by the scanner for line 31 should have lower severity than the 
   corresponding (exploitable) format-string vulnerability in except.c
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

    strcpy(errormsg, "that isn't a valid ID");
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
    fprintf(stderr, message);                // line 31
  }
}
