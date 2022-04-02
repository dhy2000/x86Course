# X86 汇编程序设计 常用代码

常用汇编代码及涉及的知识点

- `HELLO.ASM`

  屏幕上输出 `Hello, world!`。

  - 基本程序结构
    - 三段式: 定义堆栈段, 数据段, 代码段
    - 初始化段寄存器
    - 退出程序, 返回 DOS
  - 打印字符串
    - DOS 9 号调用
    - 数据段的字符串以 `$` 结尾

- `ADD16.ASM`
  
   键盘输入两个十进制整数, 16 位整数加法。

  - DOS 输入输出字符 (1 号及 2 号调用)
  - 16 位十进制无符号整数输入输出
    - 压栈出栈

- `ADD32.ASM`

  键盘输入两个十进制整数, 32 位整数加法，打印十进制和十六进制算式。

  - 32 位整数加法
  - 32 位十进制无符号整数输入输出
  - 十六进制输出字节及 32 位整数
  - 以字符串方式打印十六进制前缀 `0x` (DOS 9 号调用)
  - 操作数类型转换（使用 `WORD PTR` 指定内存操作数类型）
  - 内存操作数的寄存器相对寻址

- `MULT32.ASM`

  在数据段定义两个 32 位整数，计算乘积 (64 位)，以十进制和十六进制输出。

  - 32 位整数乘法 (乘积 64 位)
    - 加法时应注意进位 (使用 `ADC` 指令)
  - 64 位无符号整数的 10 进制和 16 进制输出

  此程序为第二次实验作业第 3 题，以字 (16 位) 为单位模拟 (循环次数固定的) 高精度乘法，过程示意图如下。

  ![mult32](img/mult32.svg)

- `SORT.ASM`

  在内存中定义字表 (16 位整数数组), 从小到大冒泡排序, 输出排序前和排序后的数组 (十六进制, 空格隔开)

  - 16 位十六进制整数输出
  - 输出数组, 以空格隔开, 行尾无多余空格
  - 冒泡排序, 交换标记

  此程序为第二次实验作业第 1 题，其中子程序 `BUBBLE_SORT` 改编自老师提供的示例代码。

  以下排序代码中，`BX` 寄存器表示当前一轮遍历是否没有交换 (如果没有则已经有序); `CX` 寄存器用于和 `LOOP` 指令配合，作为循环次数计数器; `SI` 为指针，代表 `TABLE[i]`。

      ; bubble sort
      BUBBLE_SORT PROC    ; sort `TABLE` in memory with `TABLE_LEN` before.
      LP1:
                  MOV     BX, 1   ; flag
                  MOV     CX, TABLE_LEN
                  DEC     CX  ; loop TABLE_LEN times
                  LEA     SI, TABLE   ; i = 0
      LP2:
                  MOV     AX, [SI]    ; a[i], a[i + 1]
                  CMP     AX, [SI+2]
                  JBE     CONTINUE    ; if a[i] > a[i + 1] swap
                  XCHG    AX, [SI+2]  ; swap
                  MOV     [SI], AX
                  MOV     BX, 0       ; swap happen in a pass
      CONTINUE:
                  ADD     SI, 2       ; i++
                  LOOP    LP2
      ; end of LP2
                  CMP     BX, 1       ; if (not swapped) break
                  JZ      EXIT
                  JMP     SHORT LP1   ; loop LP1
      ; end of LP1
                  RET
      BUBBLE_SORT ENDP
  
  该汇编代码对应的伪 C 代码:

  ```c
  while (1) {
      flag = true;
      for (i = 0; i < TABLE_LEN; i++) {
          if (a[i] > a[i + 1])
             swap (&a[i], &a[i + 1]);
      }
      if (flag) break;
  }
  ```
