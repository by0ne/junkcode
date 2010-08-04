
/*
  This program uses strncpy and strncat safely, without introducing a 
  buffer overflow. It's meant to check whether a scanner warns vacuously
  about strncpy and strncat, or if it actually checks whether the sizes are
  OK and whether the buffer is terminated after the strncpy.

  A scanner should not report a buffer overflow on line 5 or line 7.
*/


main(int argc, char **argv)
{
  char *buffer = (char *)malloc(25);

  strncpy(buffer, argv[1], 10);         // line 5
  buffer[10] = 0;
  strncat(buffer, argv[2], 10);         // line 7
}

