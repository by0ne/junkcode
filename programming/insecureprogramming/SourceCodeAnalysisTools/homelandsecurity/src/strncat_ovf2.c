
/* another strncat to into an unterminated buffer. */

main(int argc, char **argv)
{
  char *buffer = (char *)malloc(101);

  strncat(buffer, argv[2], 90);
}

