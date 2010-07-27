
/*
   In this program, the target string is properly terminated but
   the terminating null is added before the strncpy(), which might
   fool a scanner into thinking that the buffer is unterminated.

   A scanner should not complain about an unterminated strncpy().
*/

void func(char *str)
{
  char target[(strlen(str) + 1) * sizeof(char)];
  target[strlen(str)] = 0;
  strncpy(target, str, strlen(str));
}

