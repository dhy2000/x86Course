; print hello world
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