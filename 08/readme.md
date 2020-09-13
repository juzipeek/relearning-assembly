# 循环

## 使用 loop

汇编中可以使用 `loop` 指令实现循环操作, 依赖 `ecx` 寄存器保存循环计数, 每次调用 `loop` 都会对 `ecx` 寄存器值减 1, 当 `ecx` 值小于等于 0 时结束循环.

代码示例:
```assembly
// loop.S
.data
msg:
    .asciz "hi...%d\n"

.text
.global main
main:
    // ecx 保存循环次数, loop 指令会将 ecx 值减一, 当其小于等于零时结束循环
    movl $5, %ecx
loop_label_1:
    // 保存 ecx 寄存器值, 因为 64 位只支持 16/64 位操作数, 因此使用 pushq/pushw 指令, 并使用 rcx 寄存器
    pushq %rcx
    movl $msg, %edi
    movl %ecx, %esi
    call printf
    popq %rcx
    loop loop_label_1

    // 调用 exit 系统调用
    movl $0, %ebx
    movl $1, %eax
    int $0x80

```

编译运行:

```bash
as loop.S -o loop.o

ld \
loop.o \
/usr/lib64/crt1.o \
/usr/lib64/crti.o \
/usr/lib64/crtn.o \
-lc \
-dynamic-linker /usr/lib64/ld-2.17.so \
-o a.out
```

## 使用条件跳转

使用 `jz`, `jnz` 可以实现 `loop` 相同功能:

```assembly
// loop2.S
.data
msg:
    .asciz "hi...%d\n"

.text
.global main
main:
    // ecx 保存循环次数, loop 指令会将 ecx 值减一, 当其小于等于零时结束循环
    movl $5, %ecx
loop_label_1:
    // 保存 ecx 寄存器值, 因为 64 位只支持 16/64 位操作数, 因此使用 pushq/pushw 指令, 并使用 rcx 寄存器
    pushq %rcx
    movl $msg, %edi
    movl %ecx, %esi
    call printf
    popq %rcx
    cmp $0, %ecx
    dec %ecx
    jnz loop_label_1

    // 调用 exit 系统调用
    movl $0, %ebx
    movl $1, %eax
    int $0x80

```
