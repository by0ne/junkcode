
/* from Secure-Programs-HOWTO/dangers-c.html */
/* In this example, the attacker-controlled number "len" is read as an integer,
   and even though there is a test to check if it's greater than
   the length of the buffer, a negative value for len will be converted to
   a large positive value when it gets cast to an unsigned integer in the
   second call to read.
*/


void func(int fd)
{
/* 1) signedness - DO NOT DO THIS. */
 char *buf;
 int i, len;

 read(fd, &len, sizeof(len));

 /* OOPS!  We forgot to check for < 0 */
 if (len > 8000) { error("too large length"); return; }

 buf = malloc(len);
 read(fd, buf, len); /* len casted to unsigned and overflows */
}

