#include <stdio.h>
struct test {
        char *a;
        char *p;
};
int main() {
        struct test* a;

        a->p = NULL;

        printf("%s\n", a->p);
        return 0;
}

