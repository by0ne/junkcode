/*
 * RET:line 9: exit condition of this loop and array length do not match
 */
int main() {
        int i,bb=100;
        char *a[40];

        for(i=0;bb>i;i++) {
                a[i]="c";
        }
        return 0;
}
