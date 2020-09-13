
/*
 * gcc -c main.c
 * ld /usr/lib64/crt1.o \
 *    /usr/lib64/crti.o \
 *    /usr/lib64/crtn.o main.o -o main \
 *    -lc \
 *    -dynamic-linker /lib64/ld-linux-x86-64.so.2
 */

int main()
{
    return 1;
}