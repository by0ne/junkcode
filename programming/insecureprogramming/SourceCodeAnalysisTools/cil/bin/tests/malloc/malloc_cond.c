/*
 * RET:line 21: free of 'p', but this variable is not allocated.
 */
/* detecting:
 *      conditional free
 */
#include <stdio.h>
#define false 0
int somefun() {
        char *p;

        p = malloc(10);

        strcpy(p,"a");

        if(p!=NULL) {
                free(p);
                return 1;
        }

        free(p);
        return 0;
}

int main() {
        int x;
        
        x=somefun();
        return 0;
}
