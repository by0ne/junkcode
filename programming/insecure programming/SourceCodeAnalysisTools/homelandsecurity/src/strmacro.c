
/* does the scanner understand preprocessor directives? */

/* This file tries to fool the scanner by making "strcpy" look like a variable
   instead of a function.
*/

#define STRINGCOPY strcpy

int main(int argc, char **argv)
{
  char *buffer = (char *)malloc(1024);
  STRINGCOPY(buffer, argv[3]);
}

void func()
{
  /* ideally this should not generate a warning because "strcpy" is
     just being used as the name of a variable (and in fact it's dead
     code).
  */
  
  int strcpy = 0;
  strcpy = strcpy + 1;
}

