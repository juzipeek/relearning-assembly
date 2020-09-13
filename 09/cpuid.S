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
