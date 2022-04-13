; Strcmp: string1 in memory, string2 from keyboard input
STACK   SEGMENT PARA STACK
    STACK_AREA  DW 100h DUP(?)
    STACK_TOP   EQU $-STACK_AREA
STACK   ENDS

DATA    SEGMENT PARA
    STRING1     DB  'DongHanyuan', '$'
    STR1_LEN    EQU $-STRING1-1 ; exclude '$'
    STR2_MAX    EQU 20h
    STR2_BUF    DB  STR2_MAX-1  ; buffer for dos call 0AH
    STR2_LEN    DB  ?
    STRING2     DB  STR2_MAX DUP (?)
DATA    ENDS

CODE    SEGMENT PARA
ASSUME  CS:CODE, DS:DATA, ES:DATA, SS:STACK

STRCMP  PROC
; requires: string1, string2 from input, both should terminate with '$'
; provides: CMP flags ZF, CF, SF
    ; use REPZ CMPSB
    ; CX: min(LEN1, LEN2)
    ; prepare CX, use stack
    MOV CH, 0
    MOV CL, STR1_LEN        ; assume CX = str1_len
    ; len1: immediate addr, len2: direct addr
    MOV AL, STR1_LEN
    CMP AL, STR2_LEN
    JBE STRCMP_MINLEN       ; len1 <= len2 skip
    MOV CL, STR2_LEN        ; if (len1 > len2) CX=len2
STRCMP_MINLEN:
    CLD
    REPZ CMPSB
    ; now we have CX and ZF
    ; ZF: prefix equal, return CMP len1, len2
    ; NZ: returns cmp of character
    JNZ STRCMP_END
    MOV AL, STR1_LEN
    CMP AL, STR2_LEN
STRCMP_END:
    RET
STRCMP  ENDP

MAIN    PROC
; setup segment registers
    MOV AX, STACK
    MOV SS, AX
    MOV SP, STACK_TOP
    MOV AX, DATA
    MOV DS, AX
    MOV ES, AX
; input string2
    LEA DX, STR2_BUF
    MOV AH, 0AH
    INT 21H
; append '$' after string2
    MOV BH, 0
    MOV BL, STR2_LEN
    MOV BYTE PTR STRING2[BX], '$'   ; register relative addressing
; print string1
    LEA DX, STRING1
    MOV AH, 9
    INT 21H
; call strcmp
    LEA SI, STRING1
    LEA DI, STRING2
    CALL STRCMP
    JA  STRCMP_G
    JB  STRCMP_L
    MOV DL, '='
    JMP OUTPUT
; print cmp status '<'|'='|'>'
STRCMP_L: ; less: str1 < str2
    MOV DL, '<'
    JMP OUTPUT
STRCMP_G: ; greater: str1 > str2
    MOV DL, '>'
    JMP OUTPUT
OUTPUT:
    MOV AH, 2   
    INT 21H
; print string2
    LEA DX, STRING2
    MOV AH, 9
    INT 21H
; return to dos
    MOV AX, 4C00H
    INT 21H
MAIN    ENDP
CODE    ENDS
END     MAIN
