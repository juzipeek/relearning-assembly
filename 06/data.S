/*
 * 数据文件, 包含 name 以及 name 长度
 * 将 name, len 设置为全局符号导出, 保证连接成功
 * 如果将下面一行注释, 使用 as 汇编成功,但是 ld 时会失败.
 * 汇编器在编译此汇编代码的时候，会将此 `name` 和 `len` 变量记下来,
 * 知道其是个全局变量.遇到其他文件是用到此变量的的时候，知道是访问这个全局变量的。
 */
.global name, len
.data
name:
    .ascii "apple\n"
    len = . - name
