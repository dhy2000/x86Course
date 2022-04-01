# 常用汇编代码

## 基本汇编程序结构

输出 `Hello, World!`:

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
    ; setup stack and data
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

## 整数 IO

十进制整数输入 `GETINT`: 从控制台读入一个 16 位十进制整数并存储到 `AX` 寄存器。

    ; read a decimal integer from console
    GETINT      PROC    ; usage: AX = getint()
    ; protect registers
                PUSH BX
                PUSH CX
    ;   CX = 0
    ;   do
    ;       AL = getchar()
    ;   while AL < '0' || AL > '9'
                MOV CX, 0       ; use CX cache the number
    GETINT_LOOP_1:
                MOV AH, 1
                INT 21H         ; read char -> AL
                ; AL >= '0' && AL <= '9' -- break
                ; AL < '0' || AL > '9' -- loop
                MOV AH, 0
                CMP AL, '0'
                JB GETINT_LOOP_1
                CMP AL, '9'
                JA GETINT_LOOP_1
    ; end of LOOP_1
    ;   do
    ;       AL -= '0'
    ;       CX = CX * 10 + AL
    ;       AL = getchar()
    ;   until AL < '0' || AL > '9'
    GETINT_LOOP_2:
                ; CX = CX * 10 + (AL - '0')
                SUB AL, 30H ; c -= '0'
                XCHG AX, CX
                MOV BX, 10
                MUL BX      ; AX *= 10
                ADD AX, CX  ; AX += (c - '0')
                XCHG AX, CX
                ; another getchar
                MOV AH, 1
                INT 21H
                MOV AH, 0
                CMP AL, '0'
                ; AL < '0' || AL > '9' -- break
                JB GETINT_RET
                CMP AL, '9'
                JA GETINT_RET
                JMP GETINT_LOOP_2   ; loop
    GETINT_RET:
                MOV AX, CX  ; set return value
    ; restore registers
                POP CX
                POP BX
                RET
    GETINT      ENDP

十进制整数输出 `PUTINT`: 将寄存器 `AX` 的值以十进制整数输出到控制台。

    ; print a decimal integer to console
    PUTINT      PROC    ; usage: putint AX
    ; protect registers
                PUSH AX
                PUSH BX
                PUSH CX
                PUSH DX
    ; if (AX == 0) putchar '0'
                CMP AX, 0
                JZ PUTINT_ZERO
    ;   do
    ;       DX, AX = AX % 10, AX / 10
    ;       CX++
    ;       push DX
    ;   while (AX != 0)
                MOV CX, 0
    PUTINT_LOOP1:
                MOV DX, 0
                MOV BX, 10
                DIV BX
                PUSH DX
                INC CX
                CMP AX, 0
                JNZ PUTINT_LOOP1
    ;   do
    ;       pop DX
    ;       putchar DX + '0'
    ;       CX--
    ;   while (CX > 0)
    PUTINT_LOOP2:
                POP DX
                ADD DL, 30H
                MOV AH, 2
                INT 21H
                LOOP PUTINT_LOOP2
                JMP PUTINT_RET
    ; putchar '0'
    PUTINT_ZERO:
                MOV AH, 2
                MOV DL, '0'
                INT 21H
    PUTINT_RET:
    ; restore registers
                POP DX
                POP CX
                POP BX
                POP AX
                RET
    PUTINT      ENDP