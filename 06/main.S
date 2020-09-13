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
