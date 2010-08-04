/*
 * RET:line 7: array out of bound access found on variable a, at least index 1 is too big.
 */
int main() {
        char a[1000][2][3][5][39][293];

        a[10*33][80/4][1*0][339][11][1+2*4-55*2] = 'c';
        return 0;
}
