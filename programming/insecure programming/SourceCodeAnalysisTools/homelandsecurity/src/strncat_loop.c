
/* Technically the buffer in this program has enough room for all the
   strncats, but the programmer forgot to terminate the buffer before
   the strncats start. Therefore line 7 contains a potential buffer
   overflow.
*/


main(int argc, char **argv)
{
  char *buffer = (char *)malloc(101);
  int i;

  for (i = 0; i < 10; i++)
    strncat(buffer, argv[i], 10);    // line 7
}

