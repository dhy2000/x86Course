; calculate N! (N=6)

STACK   SEGMENT PARA STACK
    STACK_AREA  DW 100h DUP(?)
    STACK_TOP   EQU $-STACK_AREA
STACK   ENDS

CODE    SEGMENT PARA
ASSUME  CS:CODE, SS:STACK

; fact(n) = n!
FACT    PROC
; arg: n
    PUSH BP     ; protect BP
    MOV BP, SP  ; addressing arg with BP
    ; SS:[SP]: BP, IP, n
    MOV AX, [BP+4H] ; AX = n
; if (n == 0) return 1
    CMP AX, 0
    JZ FACT_RET1
; return n * fact(n - 1)
    DEC AX  ; AX = n - 1
    PUSH AX ; pass n-1 to nested fact
    CALL FACT
    ; now AX = fact(n-1)
    MOV BX, [BP+4H] ; restore BX = n
    MUL BX          ; DX:AX = AX * BX
    ; just return AX
    JMP FACT_RET
FACT_RET1:
    MOV AX, 1
FACT_RET:
    POP BP
    RET 2H
FACT    ENDP

; print a decimal integer to console
PUTINT  PROC    ; usage: putint AX
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
PUTINT  ENDP

MAIN    PROC
; setup segment register
    MOV AX, STACK
    MOV SS, AX
    MOV SP, STACK_TOP
; setup N = 6
    MOV AX, 6
    PUSH AX
; call FACT
    CALL FACT
; print result
    CALL PUTINT ; putint(AX)
; return to dos
    MOV AX, 4C00H
    INT 21H
MAIN    ENDP
CODE    ENDS
END     MAIN