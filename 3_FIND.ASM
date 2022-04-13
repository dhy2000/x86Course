; Find AL in STRING and returns the count
STACK   SEGMENT PARA STACK
    STACK_AREA  DW  100h DUP(?)
    STACK_TOP   EQU $-STACK_AREA
STACK   ENDS

DATA    SEGMENT PARA
    MAX_LEN     EQU 100h
    BUF         DB MAX_LEN-1
    LEN         DB ?
    STRING      DB MAX_LEN DUP(?)
DATA    ENDS

CODE    SEGMENT PARA
ASSUME  CS:CODE, DS:DATA, ES:DATA, SS:STACK
FIND    PROC
    ; requires: AL - char to find, STACK - STRING and LEN
    ; provides: AX - count of AL in STRING
    ; use BP fetch STRING and LEN from stack
    MOV BP, SP
    MOV DI, [BP+04H]    ; STRING
    MOV CX, [BP+02H]    ; LEN
    MOV SI, 0           ; use SI as counter
FIND_LP:    ; LOOP until reach the end of string
    REPNZ SCASB         ; scan
    ; stops either find or end
    JNZ FIND_END        ; end and not found
    ADD SI, 1           ; count++
    JMP FIND_LP
FIND_END:
; end of FIND_LP
    MOV AX, SI          ; return count via AX
    RET 04H             ; return with poping STRING and LEN
FIND    ENDP

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
; setup segment registers
    MOV AX, STACK
    MOV SS, AX
    MOV SP, STACK_TOP
    MOV AX, DATA
    MOV DS, AX
    MOV ES, AX
; input STRING from keyboard
    LEA DX, BUF
    MOV AH, 0AH
    INT 21H
; print '\n'
    MOV DL, 0AH
    MOV AH, 2
    INT 21H
; setup AL
    MOV AL, 'x'
; call FIND
    LEA DI, STRING
    PUSH DI
    MOV DH, 0
    MOV DL, LEN
    PUSH DX
    CALL FIND
; output AX
    CALL PUTINT
; return to dos
    MOV AX, 4C00H
    INT 21H
MAIN    ENDP
CODE    ENDS
END     MAIN