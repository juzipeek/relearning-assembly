static inline int strcmp(const char *cs, const char *ct)
{
    int d0, d1;
    register int __res;
    __asm__ __volatile__(
        "1:\tlodsb\n\t"
        "scasb\n\t"
        "jne 2f\n\t"
        "testb %%al,%%al\n\t"
        "jne 1b\n\t"
        "xorl %%eax,%%eax\n\t"
        "jmp 3f\n"
        "2:\tsbbl %%eax,%%eax\n\t"
        "orb $1,%%al\n"
        "3:"
        : "=a"(__res), "=&S"(d0), "=&D"(d1)
        : "1"(cs), "2"(ct));
    return __res;
}

int add(int foo, int bar)
{
    __asm__ __volatile__(
        "addl %2,%0"
        : "=r"(foo) // 输出占位符限定部分,`%0` 占位符限定
        : "0"(foo), // 输入占位符限定部分, "0" 表示占位符 `%0`,
          "g"(bar)  // `%2` 占位符限定
    );
    return foo;
}

int main()
{
    char *p1 = "abc";
    char *p2 = "bcd";

    int ret = strcmp(p1, p2);
    printf("ret:%d\n", ret);

    ret = add(1, 3);
    printf("ret:%d\n", ret);
}
