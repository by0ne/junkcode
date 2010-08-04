
/* 
   This program avoids a sign error by checking of the variable len is
   negative. It complements signedness_1.c, where an attacker can create
   a buffer overflow by specifying a negative number for len. 

   A scanner should not report a buffer overflow on line 11. 
*/

void func(int fd)
{
 char *buf;
 int i, len;

 read(fd, &len, sizeof(len));

 if (len < 0 || len > 7999) { error("too large length"); return; }

 buf = malloc(8000);
 read(fd, buf, len);                // line 11
}

