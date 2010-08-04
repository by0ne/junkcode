int main() {
        char *p;

        p=malloc(10);

        strcpy(p,"hiya");
        doit(p);
        return 0;
}

void doit(char *a) {
        free(a);
}
