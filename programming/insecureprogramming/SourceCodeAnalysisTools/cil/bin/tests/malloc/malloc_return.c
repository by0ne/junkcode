/*
 * RET:line 19: free of 'c', but this variable is not allocated.
 */
/* detecting:
 *      returning a malloced variable
 */
char* xx(char *bl) {
        char *mm;

//        mm = malloc(10);
        strcpy(mm,"a");
        return mm;
}

void freeit(char *m) {
        char *c;

        c = xx(m);
        free(c);
}

int main() {
        char *l;
        freeit(l);
        return 0;
}

