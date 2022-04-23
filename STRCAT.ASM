; strcat sample string with input string
STACK   SEGMENT PARA STACK
    STACK_AREA  DW 100h DUP(?)
    STACK_TOP   EQU $-STACK_AREA
STACK   ENDS

DATA    SEGMENT PARA
    MAX_LEN EQU 101
    IN_BUF  DB  MAX_LEN-1
    IN_LEN  DB  ?
    IN_STR  DB  MAX_LEN DUP(?)
    STRING  DB 'Hello, ', 0h
            DB 200h DUP(?)      ; space for strcat
DATA    ENDS

CODE    SEGMENT PARA
ASSUME  CS:CODE, DS:DATA, ES:DATA, SS:STACK
; input string to buf
GETLINE PROC
; arg: head address of IN_BUF (structure must satisfy DOS interrupt 0AH)
    PUSH BP     ; protect BP
    MOV BP, SP  ; addressing argument with BP
    ; SS:[SP]: BP, IP, IN_BUF, ...
    ; use 0AH function of INT 21H
    MOV DX, [BP+4H] ; DX = IN_BUF
    MOV AH, 0AH
    INT 21H
    ; set IN_STR[IN_LEN] = '\0'
    MOV BX, [BP+4H]
    ADD BX, 2   ; BX = &IN_STR
    ADD BL, BYTE PTR [BX-1H]   ; BX += IN_LEN
    INC BH
    MOV BYTE PTR [BX], 0H
    ; print '\n'
    MOV DL, 0AH
    MOV AH, 2
    INT 21H
    ; return
    POP BP
    RET 2H  ; pop IN_BUF
GETLINE ENDP

; concat str2 after str1 (both asciiz)
STRCAT  PROC
; arg: head address of str1 and str2 (terminated with 0H)
    PUSH BP
    MOV BP, SP
    PUSH SI
    PUSH DI
    ; SS:[SP]: DI, SI, BP, IP, str2, str1, ...
; 1. scan the end of str1
    MOV DI, [BP+6H]
    MOV CX, MAX_LEN
    MOV AL, 0H
    CLD
    REPNZ SCASB
    ; now DI is after '\0' of str1
    DEC DI  ; [DI] is end of str1
    MOV SI, [BP+4H] ; SI at str2
; 2. copy str2 to after str1
STRCAT_LP:
    CLD
    LODSB   ; AL = *(str2++)
    STOSB   ; *(str1++) = AL
    CMP AL, 0H  ; if (AL ! 0) loop
    JNZ STRCAT_LP
; after copy
    ; return
    POP DI
    POP SI
    POP BP
    RET 4H  ; pop str2, str1
STRCAT  ENDP

; print asciiz string
PUTS    PROC
; arg: head address of string
    PUSH BP
    MOV BP, SP
    PUSH SI
    ; SS:[SP]: SI, BP, IP, str, ...
    MOV SI, [BP+4H]
PUTS_LP:
    CLD
    LODSB   ; AL = *(str++)
    CMP AL, 0h
    JZ PUTS_END
    MOV DL, AL  ; putchar AL
    MOV AH, 2
    INT 21H
    JMP PUTS_LP
PUTS_END:
    POP SI
    POP BP
    RET 2H  ; pop str
PUTS    ENDP

MAIN    PROC
; setup segment register
    MOV AX, STACK
    MOV SS, AX
    MOV SP, STACK_TOP
    MOV AX, DATA
    MOV DS, AX
    MOV ES, AX
; input IN_BUF
    LEA DX, IN_BUF
    PUSH DX
    CALL GETLINE
; strcat
    LEA DX, STRING
    PUSH DX
    LEA DX, IN_STR
    PUSH DX
    CALL STRCAT
; output
    LEA DX, STRING
    PUSH DX
    CALL PUTS
; return to dos
    MOV AX, 4C00H
    INT 21H
MAIN    ENDP
CODE    ENDS
END     MAIN

