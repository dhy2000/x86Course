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

; print str1, call memmove, print str1 and str2
TRY     PROC
; head address of str2 and str1 is already pushed to stack
    MOV BP, SP  ; [BP+2H]: str2, [BP+4H]: str1
    ; print str1
    MOV DX, [BP+4H]
    MOV AH, 9
    INT 21H
    ; print '\n'
    MOV DL, 0AH
    MOV AH, 2
    INT 21H
    ; call memmove: load SI and DI
    MOV SI, [BP+4H]
    MOV DI, [BP+2H]
    CALL MEMMOVE
    ; print str1
    MOV DX, [BP+4H]
    MOV AH, 9
    INT 21H
    ; print ' '
    MOV DL, 20H
    MOV AH, 2
    INT 21H
    ; print str2
    MOV DX, [BP+2H]
    MOV AH, 9
    INT 21H
    ; print '\n'
    MOV DL, 0AH
    MOV AH, 2
    INT 21H
; end, pop str2 and str1
    RET 4H
TRY     ENDP

MAIN    PROC
; setup segments
    MOV AX, STACK
    MOV SS, AX
    MOV SP, STACK_TOP
    MOV AX, DATA
    MOV DS, AX
    MOV ES, AX
; try 1: string2 does not intersect with string1
    LEA AX, STRING1
    PUSH AX
    LEA AX, STRING2
    PUSH AX
    CALL TRY
; try 2: string2 before string1 with intersection
    LEA AX, STRING1
    PUSH AX
    LEA AX, STRING1-5H
    PUSH AX
    CALL TRY
; attempt 3: string2 after string1 with intersection
    LEA AX, STRING1
    PUSH AX
    LEA AX, STRING1+5H
    PUSH AX
    CALL TRY
; return to dos
    MOV AX, 4C00H
    INT 21H
MAIN    ENDP

CODE    ENDS
END     MAIN