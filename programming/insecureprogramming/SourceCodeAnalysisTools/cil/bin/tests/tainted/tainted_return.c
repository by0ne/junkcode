/*
 * RET:line 19: FATAL, found use of tainted variable in dangerous function
 */
#include <unistd.h>
char *dosmth(char *bla) {
        int x;
        char *buf,*l;

        read(0,buf,100);
        l=buf;
        return l;
}

int main() {
        char *b;
        char a[100];

        b= dosmth("b am");
        strcpy(a,b);

        return 0;
}

