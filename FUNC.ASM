; 1-5: input str, strchr, strcmp, strcpy, puts
STACK   SEGMENT PARA STACK
    STACK_AREA  DW 100h DUP(?)
    STACK_TOP   EQU $-STACK_AREA
STACK   ENDS

DATA    SEGMENT PARA
    PRO     DW  GETS, STRCHR, STRCMP, STRCPY, PUTS
    STRING  DB  'donghanyuan', 0H
    MAX_LEN EQU 121
    IN_BUF  DB  MAX_LEN-1
    IN_LEN  DB  ?
    IN_STR  DB  MAX_LEN
DATA    ENDS

CODE    SEGMENT PARA
ASSUME  CS:CODE, DS:DATA, ES:DATA, SS:STACK

; sub program 1: read string to IN_BUF
GETS    PROC
    PUSH BX
    PUSH DX
    ; use 0AH function of INT 21H
    LEA DX, IN_BUF
    MOV AH, 0AH
    INT 21H
    ; set IN_STR[IN_LEN] = '\0'
    LEA BX, IN_STR
    ADD BL, BYTE PTR IN_LEN
    ADC BH, 0
    MOV BYTE PTR [BX], 0H
    ; print '\n'
    MOV DL, 0AH
    MOV AH, 2
    INT 21H
    ; return
    POP DX
    POP BX
    RET
GETS    ENDP

; sub program 2: find char 'x' in string (IN_STR), return count via AX
STRCHR  PROC
    PUSH SI
    PUSH CX
; for (p = IN_STR; *p != '\0'; p++)
    LEA SI, IN_STR
    MOV CX, 0
STRCHR_LP:
    CLD
    LODSB
    CMP AL, 'x'
    JNZ STRCHR_CONTINUE
    INC CX
STRCHR_CONTINUE:
    CMP AL, 0
    JNZ STRCHR_LP
; end of loop, ret
    MOV AX, CX
    POP CX
    POP SI
    RET
STRCHR  ENDP

; sub program 3: compare two string
STRCMP  PROC
; compare STRING and IN_STR
    PUSH SI
    PUSH DI
    PUSH BX
    LEA SI, STRING
    LEA DI, IN_STR
    ; while (true)
    ;   if (*p != *q) break
    ;   if (*p == 0) break
STRCMP_LP:
    CLD
    LODSB   ; AL = *p
    PUSH AX
    XCHG SI, DI
    CLD
    LODSB   ; AL = *q
    XCHG SI, DI
    POP BX  ; BL = *p
    XCHG BL, AL ; AL = *p, BL = *q
    CMP AL, BL
    JNZ STRCMP_END  ; until *p != *q
    CMP AL, 0
    JNZ STRCMP_LP   ; until *p == 0 (and s1 == s2)
STRCMP_END:
    ; keep ZF, CF flags
    POP BX
    POP DI
    POP SI
    RET
STRCMP  ENDP

; sub program 4: copy str1 to str2
STRCPY  PROC
; copy STRING to IN_STR
    PUSH SI
    PUSH DI
    LEA SI, STRING
    LEA DI, IN_STR
STRCPY_LP:
    CLD
    LODSB
    STOSB
    CMP AL, 0
    JNZ STRCPY_LP
; end of loop
    POP DI
    POP SI
    RET
STRCPY  ENDP

; sub program 5: display string
PUTS    PROC
; display IN_STR
    PUSH SI
    PUSH DX
    LEA SI, IN_STR
PUTS_LP:
    CLD
    LODSB
    CMP AL, 0
    JZ PUTS_END
    MOV DL, AL
    MOV AH, 2
    INT 21H
    JMP PUTS_LP
PUTS_END:
    ; print '\n'
    MOV DL, 0AH
    MOV AH, 2
    INT 21H
    POP DX
    POP SI
    RET
PUTS    ENDP

; main program
MAIN    PROC
; setup segment registers
    MOV AX, STACK
    MOV SS, AX
    MOV SP, STACK_TOP
    MOV AX, DATA
    MOV DS, AX
    MOV ES, AX
; input index
MAIN_LP:
    MOV AH, 1
    INT 21H
    PUSH AX ; store AL
    MOV DL, 0AH
    MOV AH, 2
    INT 21H
    POP AX  ; after print '\n'
    CMP AL, '0'
    JZ MAIN_END
    JB MAIN_LP
    CMP AL, '9'
    JA MAIN_LP
    MOV AH, 0
    SUB AL, 30H
    PUSH AX ; index 1-5
    ; call jump table
    DEC AL
    LEA BX, PRO
    ADD BX, AX
    ADD BX, AX  ; BX = PRO + 2*AX
    CALL [BX]
    ; output result of strchr(index=2) and strcmp(index=3)
    POP BX  ; index 1-5
    PUSHF   ; protect flags from strcmp
    CMP BL, 2   ; strchr
    JNZ CONTINUE1
    ; output strchr result (return via AX)
    POPF    ; restore stack
    ; assert strchr count <= 9
    ADD AL, 30H
    MOV DL, AL
    MOV AH, 2
    INT 21H
    ; print '\n'
    MOV DL, 0AH
    MOV AH, 2
    INT 21H
    JMP MAIN_LP
CONTINUE1:
    CMP BL, 3   ; strcmp
    JNZ CONTINUE2
    ; output strcmp result
    POPF    ; result of strcmp
    JA STRCMP_GT
    JB STRCMP_LT
    JZ STRCMP_EQ
STRCMP_EQ:
    MOV DL, '='
    JMP STRCMP_OUT
STRCMP_GT:
    MOV DL, '>'
    JMP STRCMP_OUT
STRCMP_LT:
    MOV DL, '<'
STRCMP_OUT:
    MOV AH, 2
    INT 21H
    ; print '\n'
    MOV DL, 0AH
    MOV AH, 2
    INT 21H
    JMP MAIN_LP ; continue loop
CONTINUE2:
    POPF    ; restore stack
    JMP MAIN_LP
MAIN_END:
; return to dos
    MOV AX, 4C00H
    INT 21H
MAIN    ENDP
CODE    ENDS
END     MAIN