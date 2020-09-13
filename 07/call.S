# file: call.S
# 数据段
.data
fmt:
    .asciz "name:%s, cpuid:%s\n"
    fmt_len = . - fmt
name:
    .ascii "apple"
    name_len = . - name

# bss 段
.bss
    .lcomm buffer, 12

# 代码段
.text
.global _start
_start:
    movl $0, %eax   # 向EAX寄存器传参
    cpuid           # 执行cpuid指令

    # 首先将 buffer 地址保存到 edi 寄存器中
    # 然后从 EBX, EDX, ECX 寄存器中取 cpuid 值，并填充到 buffer 中
    movl $buffer, %edi
    movl %ebx, (%edi)
    movl %edx, 2(%edi)
    movl %ecx, 4(%edi)

    movl $fmt,    %edi   # 将 fmt 地址作为第 1 个参数, 保存到 edi 寄存器
    movl $name,   %esi   # 将 name 地址作为第 2 个参数, 保存到 esi 寄存器
    movl $buffer, %edx   # 将 buffer 地址作为第 3 个参数, 保存到 edx 寄存器
    call printf          # 调用 printf

    movl $0, %edi
    call exit       # 调用exit
