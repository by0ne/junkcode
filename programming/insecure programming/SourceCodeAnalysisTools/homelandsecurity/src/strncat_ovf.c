
/* forgot to null-terminate the strncpy */
/* strncpy doesn't automatically null-terminate the string being copied
   into. In this example, the attacker supplies an argv[1] of length ten
   or more. In the subsequent strncat, data is copied not to buffer[10]
   as the code suggests, but to the first location to the left of buffer[0] 
   that happens to contain a zero byte.
*/

main(int argc, char **argv)
{
  char *buffer = (char *)malloc(101);

  strncpy(buffer, argv[1], 10);
  strncat(buffer, argv[2], 90);
}

