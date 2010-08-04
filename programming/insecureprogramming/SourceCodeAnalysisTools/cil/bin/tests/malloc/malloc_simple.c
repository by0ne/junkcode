/*
 * RET:line 40: free of 'l', but this variable is not allocated.
 */
/* detecting:
 *      double free() 
 */
int main() {
        char *c;

        c = malloc(10);
        doit("hiya",c);

        f1(c);
        return 0;
}



void doit(char *m, char *b) {
        char *a;

        printf("%s\n", m);
        free(b);
}

void f1(char *k) {
        char*XX;
        
        XX=k;
        fnew(111, XX);
}


void fnew(int b, char *l) {
        int x;
        char *abc;

        x=b;
        abc = l;
        free(l);
}
