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
    // 保存 ecx 寄存器值, 因为 64 位只支持 16/64 位操作数, 因此使用 pushq 指令, 并使用 rcx 寄存器
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
