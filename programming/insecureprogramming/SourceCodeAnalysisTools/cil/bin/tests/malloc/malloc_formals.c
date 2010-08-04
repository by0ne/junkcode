/* checking:
 *      tracking free() through function calls
 *      detecting double free, dangling free
 */
#include <string.h>
#include <stdlib.h>

/*void afun(void) {
        char *p;
        p=malloc(10);
        doit("hans", p);
}*/

int main(int argc, char **argv) {
        unsigned int a;
        unsigned int b;
        char *buf;
        char *r;
        char *a;

    r=malloc(100);
    free(r);

    doit("peter",r);

    // double free() here
        //free(r);
        return 0;
}

void doit(char *n,char *a) {
        char *p;
        p=a;
        justsomething("uha",p);
}

void justsomething(char *msg, char *c) {
        char *l;
        l=c;
        free(l);
}


