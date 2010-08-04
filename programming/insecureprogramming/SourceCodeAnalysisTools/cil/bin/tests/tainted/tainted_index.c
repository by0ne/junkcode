/*
 * RET:line 12: use of tainted array index 'i'
 */
int main() {

        int i;
        char buf[100],a[10];

        read(0, &buf[0], 100);
        i = buf[1];

        a[i] = 'c';
        return 0;
}



