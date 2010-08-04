/*
 * RET:line 20: FATAL, found use of tainted variable in dangerous function
 */
int main() {
        char b[100];
        
        read(0,&b[0],100);

        callit("plem", &b[0]);
        return 0;
}

void callit(char *msg, char *p) {
        copyfun(p);
}

void copyfun(char *x) {
        char y[100];

        strcpy(y, x);
}
