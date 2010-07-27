
/* unexploitable strcpy #1 */

/* This program contains a buffer overflow, but the overflowing data
   isn't controlled by the attacker. Ideally, a scanner should either not
   report a buffer overflow associated with this strcpy, or at most report
   a problem with lower severity than a strcpy whose argument is attacker-
   controlled.
*/


main()
{
  char *buffer = (char *)malloc(10 * sizeof(char));

  strcpy(buffer, "fooooooooooooooooooooooooooooooooooooooooooooooooooo");
}

