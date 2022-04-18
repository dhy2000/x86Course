# 第三次实验作业

本次实验作业主要围绕字符串处理。[作业要求](requirements.md)

## 简易说明

- [第一题](1_MMOV.ASM): 实现子程序 Memmove，拷贝字符串并测试源和目的有重叠时的效果。
- [第二题](2_SCMP.ASM): 字符串比较，内存中定义的字符串（姓名）和键盘输入的字符串比较。
- [第三题](3_FIND.ASM): 键盘输入字符串，求寄存器 `AL` 中的字符在串中出现的次数。
- [第四题](4_SORT.ASM): 预设字符串表并排序，键盘输入字符串并插入字符串表中。

第三题由于不清楚待查找字符 `AL` 的输入方式，所以暂且将其硬编码为字符 `x`。

## 注意事项 (踩坑记录)

本次实验用到了 DOS 中断的 `0AH` 号功能调用，从键盘中读取一个字符串。使用 `0AH` 号功能调用时，需要提前构造好一个指定结构的缓冲区 `BUF`:

    MAX_LEN EQU 101h ; 最大长度
    BUF     DB  MAX_LEN-1       ; 最大长度 (不含 0DH)
    LEN     DB  ?               ; 实际长度 (不含 0DH)
    STR     DB  MAX_LEN DUP(?)  ; 字符串内容 (含 0DH)

其中 `BUF` 首个字节为最大长度，下一个字节是 DOS 中断调用返回后实际读入的字符串长度，而后是字符串的内容。

该功能调用以键入 Enter 键结束，输入的字符串以 `0DH` (`'\r'`) 结尾。

由于 `0AH` 功能调用会将键盘输入的字符回显到 DOS 控制台上，所以输入结束键入 Enter 后，由于字符 `0DH` 的回显，光标被移回当前行的行首，从而后续的输出会直接覆盖在当前行上，从而产生显示错位。

为了使输入回显和输出内容显示正常，可以在调用 `0AH` 号 DOS 功能调用后，用 `2` 号 DOS 功能调用输出一个换行符 `0AH` (`'\n'`)。

    MOV DL, 0AH
    MOV AH, 2
    INT 21H

（以上解决方法仍然存在一处缺陷：当使用 `>` 重定向输出时，输入回显的内容会被一并输出，似乎在 dosbox 中不能很好地区分 `stdin` 和 `stdout` ）

update: 感谢 [Coekjan](https://github.com/Coekjan) 指出第 4 题循环的 bug, 现已修复。

`LOOP` 指令执行的行为是先 `CX--` 再判断是否 `CX==0`，也就是保证循环执行的 **次数** 是进入循环体前预置的 `CX` 值。在执行到 `LOOP` 指令前，如果 `CX==1`，则执行完 `LOOP` 后不会再次执行循环体。