; Memmove: copy String1 to String2
STACK   SEGMENT PARA STACK
    STACK_AREA  DW  100 DUP(?)
    STACK_TOP   EQU $-STACK_AREA
STACK   ENDS

DATA    SEGMENT PARA
                DB  5 DUP(?)    ; space before
    STRING1     DB  'DongHanyuan', '$'
    LEN         EQU $-STRING1   ; length of string
                DB  5 DUP(?)    ; space after (optional)
    STRING2     DB  20 DUP(?)   ; after string1
DATA    ENDS

CODE    SEGMENT PARA
ASSUME  CS:CODE, DS:DATA, ES:DATA, SS:STACK

MEMMOVE PROC
    ; prepare: DS:[SI] at String1, ES:[DI] at String2
    MOV CX, LEN
    CLD
    REP MOVSB   ; move string by byte
    RET
MEMMOVE ENDP

MAIN    PROC
; setup segments
    MOV AX, STACK
    MOV SS, AX
    MOV SP, STACK_TOP
    MOV AX, DATA
    MOV DS, AX
    MOV ES, AX
; attempt 1: string2 does not intersect with string1
    ; print string1
    LEA DX, STRING1
    MOV AH, 9
    INT 21H
    ; putchar '\n'
    MOV DL, 0AH
    MOV AH, 2
    INT 21H
    ; prepare DS:[SI] and ES:[DI]
    LEA SI, STRING1
    LEA DI, STRING2
    CALL MEMMOVE
    ; print string1
    LEA DX, STRING1
    MOV AH, 9
    INT 21H
    ; putchar ' '
    MOV DL, 20H
    MOV AH, 2
    INT 21H
    ; print string2
    LEA DX, STRING2
    MOV AH, 9
    INT 21H
    ; putchar '\n'
    MOV DL, 0AH
    MOV AH, 2
    INT 21H
; attempt 2: string2 before string1 with intersection
    ; print string1
    LEA DX, STRING1
    MOV AH, 9
    INT 21H
    ; putchar '\n'
    MOV DL, 0AH
    MOV AH, 2
    INT 21H
    ; prepare DS:[SI] and ES:[DI]
    LEA SI, STRING1
    LEA DI, STRING1-5H
    CALL MEMMOVE
    ; print string1
    LEA DX, STRING1
    MOV AH, 9
    INT 21H
    ; putchar ' '
    MOV DL, 20H
    MOV AH, 2
    INT 21H
    ; print string2
    LEA DX, STRING1-5H
    MOV AH, 9
    INT 21H
    ; putchar '\n'
    MOV DL, 0AH
    MOV AH, 2
    INT 21H
; attempt 3: string2 after string1 with intersection
    ; print string1
    LEA DX, STRING1
    MOV AH, 9
    INT 21H     ; string1 is already corrupted by last process
    ; putchar '\n'
    MOV DL, 0AH
    MOV AH, 2
    INT 21H
    ; prepare DS:[SI] and ES:[DI]
    LEA SI, STRING1
    LEA DI, STRING1+5H
    CALL MEMMOVE
    ; print string1
    LEA DX, STRING1
    MOV AH, 9
    INT 21H
    ; putchar ' '
    MOV DL, 20H
    MOV AH, 2
    INT 21H
    ; print string2
    LEA DX, STRING1+5H
    MOV AH, 9
    INT 21H
    ; putchar '\n'
    MOV DL, 0AH
    MOV AH, 2
    INT 21H
; return to dos
    MOV AX, 4C00H
    INT 21H
MAIN    ENDP

CODE    ENDS
END     MAIN