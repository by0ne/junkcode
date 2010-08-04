/*
 * untainting should work aswell.
 * RET:
 */
int main() {
        char *a,*b;
        char *x="hiya";

        read(0,a,100);

        // a gets untainted
        a = x;
        strcpy(b,a);

        return 0;
}
