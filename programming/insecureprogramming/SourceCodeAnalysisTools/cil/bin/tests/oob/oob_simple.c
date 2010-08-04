/*
 * RET:line 8: array out of bound access found on variable p, at least index 0 is too big.
 */
int main(int argc, char **argv) {
        char *p[5];

        p[0]="hi";
        p[20]="baluba";
        return 0;
}
