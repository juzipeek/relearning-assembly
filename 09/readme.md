# 函数调用

首先使用 c 代码示例生成汇编代码, 观察函数调用的约定. 根据约定使用汇编实现 `cpuid` 信息输出, 再在 c 代码中调用汇编函数, 输出 `cpuid` 信息.

## 反汇编示例

```bash
gcc -S hi.c
```

观察汇编代码中 `say` 函数内容:

```assembly
    .text
    .globl    say
    .type    say, @function
say:
.LFB2:
    .cfi_startproc
    pushq    %rbp
    .cfi_def_cfa_offset 16
    .cfi_offset 6, -16
    movq    %rsp, %rbp
    .cfi_def_cfa_register 6
    movl    $.LC0, %edi
    call    puts
    popq    %rbp
    .cfi_def_cfa 7, 8
    ret
    .cfi_endproc
```

## 汇编函数

在 `cpuid.S` 中实现 `cpuid` 信息输出:
```assembly
.data
fmt:
    .asciz "cpuid:%s\n"

.bss
    .lcomm buffer, 12

.text
.global cpuid_info
cpuid_info:
    pushq   %rbp        # 保存调用函数的函数栈帧(由被调用方保存栈帧, 仅在函数实现中增加栈帧保存指令, 能使程序体积小些)
    movq    %rsp, %rbp
    movq    $0, %rax
    cpuid
    movl $buffer, %edi
    movl %ebx, (%edi)
    movl %edx, 2(%edi)
    movl %ecx, 4(%edi)

    movl $fmt,    %edi   # 将 fmt 地址作为第 1 个参数, 保存到 edi 寄存器
    movl $buffer, %esi   # 将 name 地址作为第 2 个参数, 保存到 esi 寄存器
    call printf          # 调用 printf
    popq %rbp            # 恢复 printf 调用后当前函数栈帧
    ret

```

在 `main.c` 中调用 `cpuid_info` 函数:

```c
#include <stdio.h>
#include <stdlib.h>

// 声明为外部函数
extern void cpuid_info();

int main() {
    cpuid_info();
}

```

进行编译执行:

```bash
as cpuid.S -o cpuid.o
gcc -v main.c cpuid.o -o a.out
./a.out
```
