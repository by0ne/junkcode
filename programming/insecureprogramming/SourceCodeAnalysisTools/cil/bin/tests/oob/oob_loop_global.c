/* 
 * RET:line 14: exit condition of this loop and array length do not match
 */
// 4*4 = 16
int defined = 4*sizeof(int);

int main() {
        int i;
        char *a[10];

        printf("%d\n", sizeof(int));

        for(i=0;i<defined;i++) {
                a[i] = 'a';
        }
        return 0;
}


