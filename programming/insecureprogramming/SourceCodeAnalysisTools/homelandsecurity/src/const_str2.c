
/* unexploitable strcpy #2 */
/* This program contains a buffer overflow, but the overflowing data
   isn't controlled by the attacker. Ideally, a scanner should either not
   report a buffer overflow associated with this strcpy, or at most report
   a problem with lower severity than a strcpy whose argument is attacker-
   controlled.

   The program is similar to const_str1.c, but it presents a slightly
   harder problem for the scanner. In const_str1.c, and scanner could
   notice that the argument to strcpy is a constant string by looking for the 
   quote symbol that follows the open parenthesis after the name of the
   function. In this program, some sort of dataflow analysis is needed
   (taint checking should be enough).
*/


void func(char *foo)
{
  char *buffer = (char *)malloc(10 * sizeof(char));

  strcpy(buffer, foo);
}

main()
{
  func ("fooooooooooooooooooooooooooooooooooooooooooooooooooo");
}


