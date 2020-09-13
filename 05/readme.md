编译操作:

```bash
as entry.s -o entry.o
ld entry.o -o entry
./entry

strace -e trace=exit ./entry
strace ./entry
```
