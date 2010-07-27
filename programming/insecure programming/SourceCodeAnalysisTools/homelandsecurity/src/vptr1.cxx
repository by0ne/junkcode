
/* The principle here is that incorrectly casting a pointer to a C++ 
   object potentially breaks the abstraction represented by that object, 
   since the (non-virtual) methods called on that object are determined
   at compile-time, while the actual type of the object might not be
   known until runtime. In this example, a seemingly safe strncpy causes
   a buffer overflow. (In gcc the buffer overflows into object itself 
   and then onto the stack, for this particular program. With some compilers 
   the overflow might modify the object's virtual table.)

   It's hard to say what a scanner should flag in this test file. In my
   opinion the only casts allowed should be virtual member functions that
   cast the this pointer to the class that owns them (e.g., As() 
   functions) and I think that prevents this type of vulnerability.
*/

#include <stdio.h>
#include <string.h>


class Stringg
{

};

class LongString: public Stringg
{
private:
  
  static const int maxLength = 1023;
  char contents[1024];

public:

  void AddString(char *str)
  {
    strncpy(contents, str, maxLength);
    contents[strlen(contents)] = 0;
  }
};


class ShortString: public Stringg
{
private:
  
  static const int maxLength = 5;
  char contents[6];

public:

  void AddString(char *str)
  {
    strncpy(contents, str, maxLength);
    contents[strlen(contents)] = 0;
  }
};

void func(Stringg *str)
{
  LongString *lstr = (LongString *)str;
  lstr->AddString("hello world");
}

main(int argc, char **argv)
{
  ShortString str;

  func(&str);
}

