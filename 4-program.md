# 程序结构

## 三段式程序结构

堆栈段, 数据段, 程序段。

定义堆栈段:

    STACK       SEGMENT PARA STACK
    STACK_AREA  DW  100h DUP(?)
    STACK_TOP   EQU $-STACK_AREA
    STACK       ENDS

定义数据段:

    DATA        SEGMENT PARA
    TABLE_LEN   DW  16
    TABLE       DW  200, 300, 400, 10, 20, 0, 1, 8
                DW  41H, 40, 42H, 50, 60, 0FFFFH, 2, 3
    DATA        ENDS

## 定义段

伪指令: `SEGMENT` 和 `ENDS`

格式:

    段名    SEGMEMT [对齐类型] [组合类型] [类别名]
            ; 本段中的程序和数据定义语句
    段名    ENDS

对齐类型: 定义了段在内存中分配时的起始边界设定

- `PAGE`: 本段从页边界开始，一页为 256B
- `PARA`: 本段从节边界开始，一节为 16B
- `WORD`: 本段从字对齐地址(偶地址)开始，段间至多 1B 空隙
- `BYTE`: 本段从字节地址开始，段间无空隙

组合类型: 确定段与段之间的关系

- `STACK`: 该段为堆栈段的一部分。链接器链接时，将所有同名的具有 `STACK` 组合类型的段连成一个堆栈段，并将 `SS` 初始化为其首地址，`SP` 为段内最大偏移。（正确定义段的 `STACK` 属性可以在主程序中省略对 `SS` 和 `SP` 的初始化）

## 定义过程

伪指令: `PROC`, `ENDP`, `END 标号`

格式:

    过程名  PROC    [NEAR|FAR]
            ; 过程代码
            RET
    过程名  ENDP

- 如果过程为 `FAR` 则 `RET` 被编译为 `RETF`（段间返回）
- `RET 2n`: 在 `RET` 或 `RETF` 后 `SP+=2n`

`END 标号` 为程序总结束, 标号为入口（被设置为初始的 `CS:IP` 值）

## 定义数据

格式:

    变量名  伪指令    值

用 `DB`, `DW`, `DD` 伪指令定义内存中的变量，变量名对应内存地址。

用 `EQU` 伪指令定义常量，不占内存，变量名被翻译成立即数。

值的表示:

- 常数
- `DUP` 重复操作符（用于定义数组，或定义堆栈空间）
- `?` 不预置任何内容
- 字符串表达式
- 地址表达式
- `$` 当前位置计数器

### `DUP` 表达式

    ARRAY1  DB  2 DUP (0, 1, 0FFH, ?)
    ARRAY2  DB  100 DUP (?)

其中 `ARRAY1` 定义了一个二维数组，等价于

    ARRAY1  DB  0, 1, 0FFH, ?, 0, 1, 0FFH, ?

`ARRAY2` 定义了一段长度为 100 字节的连续空间，值未初始化。

`DUP` 表达式可以嵌套，相当于定义多维数组。

    ARRAY3  DB  2 DUP(1, 2 DUP ('A', 'B'), 0) ; 'A', 'B' 为字符 ASCII 码 41H 和 42H

对应的内存图:

    ARRAY3+ 0000:   01H
            0001:   41H
            0002:   42H
            0003:   41H
            0004:   42H
            0005:   00H
            0006:   01H
            0007:   41H
            0008:   42H
            0009:   41H
            000A:   42H
            000B:   00H

### 地址表达式

使用 `DW` 及 `DD` 伪指令后跟标号，表示变量的偏移地址或逻辑地址。使用 `DD` 存储逻辑地址时，低字为偏移地址，高字为段地址。

当前位置计数器: 用 `$` 表示，为当前标号所在的偏移地址。

    X1  DW  ?   ; X1 内容未定义
    X2  DW  $   ; X2 单元存放当前 (X2 自身的) 偏移地址
    X3  DW  X1  ; X3 单元存放 X1 偏移地址
    X4  DW  L1  ; X4 单元存放 L1 标号的偏移地址
    X5  DW  P1  ; X5 单元存放 P1 子程序的偏移地址
    X6  DD  X1  ; X6 单元存放 X1 的逻辑地址
    X7  DD  L1  ; X7 单元存放 L1 标号的逻辑地址
    X8  DD  P1  ; X8 单元存放 P1 子程序的逻辑地址

### 字符串表达式

    STR1    DB  'ABCD', 0DH, 0AH, '$'
    STR2    DW  'AB', 'CD'

其中 `STR1` 分配了 7 个单元(字节)，按顺序存放。其中 `$` 为字符串的结束（使用 DOS 9 号功能调用输出字符串，结果为 `ABCD\r\n` ）

`STR2` 分配了两个字（4 个字节），按顺序其值分别为 `42H`, `41H`, `44H`, `43H`。对于 `DW` 和 `DD` 伪指令，不允许使用两个以上字符的字符串作为其参数。

## 初始化寄存器

    MOV AX, STACK
    MOV SS, AX
    MOV SP, STACK_TOP
    MOV AX, DATA
    MOV DS, AX

`ASSUME` 伪指令: 告诉汇编器，将 `CS`, `DS`, `SS` 分别设定成相应段的首地址（仅仅是"设定"，并没有真正将地址存入段寄存器，仍然需要使用上述几条指令来初始化段寄存器）

    ASSUME  CS:CODE, DS:DATA, SS:STACK

## DOS 功能调用

调用指令: `INT 21H`，其中 `21H` 表示 DOS。

用寄存器 `AH` 指定功能调用号。

### 返回 DOS

    MOV AX, 4CH     ; AH = 4C, DOS 4C 号功能调用: 返回 DOS
    MOV AL, 00H     ; AL = 给 DOS 的返回值
    INT 21H         ; 21H 表示 DOS 功能调用

### 输入输出

输入一个 ASCII 字符:

    MOV AH, 1           ; 1 号功能调用
    INT 21H
    MOV BYTE PTR X, AL  ; 结果存储在 AL 中

输出一个 ASCII 字符:

    MOV DL, 'A'         ; 输出的字符在 DL 中
    MOV AH, 2           ; 2 号功能调用
    INT 21H             ; 输出的字符保存在 AL 中 (不确定)

**注意**: `AL` 寄存器会改变（书上没找到，但是自己试出来了）！

输出字符串:

    LEA DX, STR         ; 输出的字符串首地址在 DX 中
    MOV AH, 9           ; 9 号功能调用
    INT 21H

## 一个完整的程序示例

    STACK       SEGMENT PARA STACK
    STACK_AREA  DW  100h DUP(?)
    STACK_TOP   EQU $-STACK_AREA
    STACK       ENDS

    DATA        SEGMENT PARA
    MESSAGE     DB  'Hello, World!', '$'
    DATA        ENDS

    CODE        SEGMENT
    ASSUME      CS:CODE, DS:DATA, SS:STACK

    MAIN        PROC
                ; initialize
                MOV AX, STACK
                MOV SS, AX
                MOV SP, STACK_TOP
                MOV AX, DATA
                MOV DS, AX
                ; display message
                MOV AH, 9
                LEA DX, MESSAGE
                INT 21H
                ; return to dos
                MOV AX, 4C00H
                INT 21H

    MAIN        ENDP
    CODE        ENDS
    END         MAIN
