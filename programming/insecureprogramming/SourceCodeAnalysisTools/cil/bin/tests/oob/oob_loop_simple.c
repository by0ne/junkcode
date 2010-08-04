/*
 * RET:line 11: exit condition of this loop and array length do not match
 */
int main() {
        int i,bb;
        char *a[40];

        i=0;

        for(i=0;100>i;i++) {
                a[i]="c";
                printf("looping\n");
        }

        return 0;
}
