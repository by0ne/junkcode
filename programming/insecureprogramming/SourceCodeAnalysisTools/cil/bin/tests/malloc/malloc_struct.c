struct a {
        char *p;
        char *a;
};

int main() {
        struct a *pa;

        pa = malloc(100);
//        pa->p = malloc(10);
       
        free(pa->p);
 //       free(pa);
        return 0;
}
