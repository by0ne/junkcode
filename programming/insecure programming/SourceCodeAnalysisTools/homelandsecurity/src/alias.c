
/*

This file is meant to test whether a scanner can perform pointer
alias analysis. Since that capability is generally only useful if the
scanner provides some dataflow analysis capabilities, dataflow
analysis is needed too. 

The variable that determines the size of a string copy is untainted,
but alias analysis is needed to determine this.

*/

int main(int argc, char **argv)
{
  int len = atoi(argv[1]);
  int *lenptr_1 = &len;
  int *lenptr_2 = lenptr_1;
  char buffer[24];

  *lenptr_2 = 23;
  strncpy(buffer, argv[2], *lenptr_1);
}

