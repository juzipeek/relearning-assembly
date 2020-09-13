# 符号导出

## 符号可见

在 `hello.S` 中使用软中断调用 `write` 系统调用, 向标准输出输出字符串.
`hello.S` 代码解释:

```assembly
# file: hello.S
.text # 代码段
.global _start
_start:
    mov $4, %eax;    # 系统调用号, 4 是 write 系统调用
    mov $1, %ebx;    # write 系统调用参数, 文件描述符, 1 是标准输出
    mov $name, %ecx; # write 系统调用参数, 输出字符串起始地址
    mov $len, %edx;  # write 系统调用参数, 输出字符串长度
    int $0x80;       # 调用软中断

                     # 退出处理操作, 调用中断 1, 参数为 0
    mov $1, %eax;
    mov $0, %ebx;
    int $0x80;

```

`data.S` 代码解释:

```assembly
/*
 * 数据文件, 包含 name 以及 name 长度
 * 将 name, len 设置为全局符号导出, 保证连接成功
 * 如果将下面一行注释, 使用 as 汇编成功,但是 ld 时会失败.
 * 汇编器在编译此汇编代码的时候，会将此 `name` 和 `len` 变量记下来,
 * 知道其是个全局变量.遇到其他文件是用到此变量的的时候，知道是访问这个全局变量的。
 */
.global name, len
.data # 数据段
name:
    .ascii "apple\n"
    # 通过当前地址减去 `name` 符号地址得到 `name` 长度
    len = . - name
```

在 `hello.S` 中使用到 `name`, `len` 两个符号, 但是符号未在本文件定义, 是定义在 `data.S` 内. 如果 `data.S` 未将两个符号导出, `name` 和 `len` 两个符号对链接器不可见, 最终链接会以为找不到符号而失败.

使用以下命令进行编译:

```bash
as data.S -o data.o
as hello.S -o hello.o

ld hello.o data.o -o a.out
./a.out
```

## 程序启动

其实 `.global _start` 同样使得 `_start` 符号对链接器可见. 装载器默认使用 `_start` 符号(函数)作为程序入口, 启动程序. 使用 `ld` 链接时可以使用 `-e [sym]` 指定入口地址(符号). 使用 `ld main.o data.o -e main -o a.out` 链接产生可执行文件.

如果不使用 `-e` 指定程序入口, 使用运行时同样可以实现 `main` 函数调用. 将 `hello.S` 进行修改, 将 `_start` 符号修改为 `main`:

```assembly
# file: main.S
.text
.global main
main:
    mov $4, %eax;    # 系统调用号, 4 是 write 系统调用
    mov $1, %ebx;    # write 系统调用参数, 文件描述符, 1 是标准输出
    mov $name, %ecx; # write 系统调用参数, 输出字符串起始地址
    mov $len, %edx;  # write 系统调用参数, 输出字符串长度
    int $0x80;       # 调用软中断

                     # 退出处理操作, 调用中断 1, 参数为 0
    mov $1, %eax;
    mov $0, %ebx;
    int $0x80;

```

此时不能使用之前的链接操作, 需要链接 `crt` 启动器, 在运行时中调用 `main` 符号(函数).

```bash
as main.S -o main.o
as data.S -o data.o

ld \
main.o data.o \
/usr/lib64/crt1.o \
/usr/lib64/crti.o \
/usr/lib64/crtn.o \
-lc \
-dynamic-linker /usr/lib64/ld-2.17.so \
-o a.out
```

`crt` 包含 `crt1.o`, `crti.o`, `crtbegion.o`, `crtend.o`, `crtn.o` 5 个对象文件, 其中
- `crt1.o` 包含作为程序入口的 `_start` 符号, `_start` 会调用 `__libc_start_main` 符号(定义与 `libc` 中).
- `crti.o` 中包含 `_init` 与 `_fini` 符号, 在调用 `main` 函数之前会被调用.
- `crtbegion.o` 与 `crtend.o` 主要用于 C++ 全局对象的创建与销毁(析构).

## 函数调用约定

IA32 下有 `cdel`, `stdcall`, `fastcall`, `thiscall` 四种函数调用约定, 调用约定有两个职责:
- 函数参数的入栈顺序
- 函数调用栈恢复

### cdel

这是在 C/C++ 中默认使用的约定方式, 编译器会将参数从右向左压栈, 并且由调用者恢复栈. 这主要是为了保证 C 的灵活性, 像 C 库中的 `printf` 这种变参参数, 在函数体中是无法知道调用栈中究竟有多少个参数的, 这只有调用者心里清楚. 所以将维护栈平衡的任务交给调用者.

在 64 位架构下会依次使用 `rdi`, `rsi`, `rdx`, `rcx`, `r8`, `r9` 传递函数的前 6 个参数, 超过 6 个才会使用栈传递.

### stdcall

`stdcall` 与 `cdecl` 约定方式最大区别在于, `stdcall` 约定由被调函数来恢复堆栈, 显而易见, 这种约定方式可以使代码的体积要小一些(因为不需要在调用方插入栈恢复代码, 仅在函数实现中实现恢复代码).

### fastcall

这种调用约定与 `stdcall` 差不多, 区别在于 `fastcall` 规定第一个和第二个比双字节小的参数通过寄存器传递参数, 而不通过压栈. 寄存器要比内存快, 固有 fast 之称.

### thiscall

`thiscall` 是 C++ 成员函数默认的调用约定. 由于成员函数中隐含 `this` 指针, 所以对这个特殊参数做了特殊处理规定:
- 参数从右向左入栈
- 如果参数个数确定, `this` 指针通过 `ecx` 传递给函数, 并且函数自己恢复堆栈, 类似 `stdcall` 方式
- 如果参数个数不确定, `this` 指针在所有参数压栈后被压入堆栈, 这相当于 `T* const this` 是第一个参数, 调用者恢复堆栈, 类似 `cdecl` 方式.

## 参考链接

- [汇编伪指令](https://sourceware.org/binutils/docs/as/Pseudo-Ops.html)
- [gnu 汇编参考](https://sourceware.org/binutils/docs/as/index.html)
- [Linux X86 程序启动 – main函数是如何被执行的？](https://luomuxiaoxiao.com/?p=516)
- [x86_64 abi](https://gitlab.com/x86-psABIs/x86-64-ABI.git)
