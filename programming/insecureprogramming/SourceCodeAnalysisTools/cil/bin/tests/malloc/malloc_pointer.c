/*
 * RET:line 15: free of 'a', but this variable is not allocated.
 */
/* detecting:
 *      keeping track of pointers
 *      detecting pointer to malloced area 
 */
int main() {
        char *a,*pa;
        char **b;

        a = malloc(10);
        pa=a;
        free(pa);
        free(a);
        return 0;
}
