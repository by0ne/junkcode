
/* Analyzer must resolve typedef to determine the data type of an array. */

typedef char gchar;

void func()
{
  gchar buf[10];
}

