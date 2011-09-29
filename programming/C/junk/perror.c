#include <stdio.h>
#include <errno.h>


int main ()
{
    errno=122;
    perror ("The following error occurred");
    printf( "Value of errno: %d\n", errno );
  return 0;
}

