/*
 * RET:line 16: FATAL, found use of tainted variable in dangerous function
 */
int main() {
        char b[100];
        
        read(0,&b[0],100);

        callit("plem", &b[0]);
        return 0;
}

void callit(char *msg, char *p) {
        char a[30];

        strcpy(a,p);
}
