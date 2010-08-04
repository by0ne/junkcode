/*
 * RET:line 7: FATAL, found use of tainted variable in dangerous function
 */
static void giveitup(char *xx) {
        char a[199];

        strcpy(a,xx);
}
int main() {
        char *b;

        read(0,b,1000);
        giveitup(*b);
        return 0;
}

