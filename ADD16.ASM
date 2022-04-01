; Input two decimal 16-bits integer, output their sum in decimal.
; Assume the sum does not exceed 65535.

; stack segment
STACK       SEGMENT PARA STACK
STACK_AREA  DW  100h DUP(?)
STACK_TOP   EQU $-STACK_AREA
STACK       ENDS

; code segment
CODE        SEGMENT
ASSUME      CS:CODE, SS:STACK   ; assume segment registers

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

; print a decimal integer to console
PUTINT      PROC    ; usage: putint AX
; protect registers
            PUSH AX
            PUSH BX
            PUSH CX
            PUSH DX
; if (AX == 0) putchar '0'
            CMP AX, 0
            JNZ PUTINT_MAIN
; putchar '0'
PUTINT_ZERO:
            MOV AH, 2
            MOV DL, '0'
            INT 21H
            JMP PUTINT_RET
PUTINT_MAIN:
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
; output finished.
PUTINT_RET:
; restore registers
            POP DX
            POP CX
            POP BX
            POP AX
            RET
PUTINT      ENDP

; main program
MAIN        PROC
; setup segment registers
            MOV AX, STACK
            MOV SS, AX
            MOV SP, STACK_TOP
; input the first number
            CALL GETINT
            MOV BX, AX  ; BX = first num
; input the second number
            CALL GETINT ; AX = second num
; calculate the sum
            ADD AX, BX  ; AX = AX + BX
; output the sum
            CALL PUTINT ; print AX
            ; putchar '\n'
            MOV DL, 0AH
            MOV AH, 2
            INT 21H
; return to dos
            MOV AX, 4C00H
            INT 21H
; end of code
MAIN        ENDP
CODE        ENDS
END         MAIN