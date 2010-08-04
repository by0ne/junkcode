
/* unexploitable strcpy #3 */

/*
  This is another buffer overflow using a non-user-defined. Here, the
  constant string is placed into a variable rather than being passed as
  a function argument like in const_str2.c. However, taint analysis should
  still be enough to let the scanner recognize that the overflowing string
  is not user-controlled.

  A scanner should either not report a buffer overflow associated with 
  this strcpy, or report a problem with lower severity than a strcpy whose 
  argument is attacker-controlled.
*/

main()
{
  char *foo = "fooooooooooooooooooooooooooooooooooooooooooooooooooo";
  char *buffer = (char *)malloc(10 * sizeof(char));
  strcpy(buffer, foo);
}

