/* run with:
 *   cilly --myinput=inps --docodechecker tainted_getenv.c
 *
 *   The file 'inps' is stored in this local directory.
 */
int main() {
        char *x;
        char *a;

        x = getenv("HOME");

        strcpy(a,x);

        return 0;
}
