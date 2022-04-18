; String table sort: build a table of strings with different length, sort it. Then input a word and insert it into the table.
STACK   SEGMENT PARA STACK
    STACK_AREA  DW  100h DUP(?)
    STACK_TOP   EQU $-STACK_AREA
STACK   ENDS

DATA    SEGMENT PARA
    ; string data, ends with '.'
    STR1        DB 'x86', '.'
    STR2        DB 'beihang', '.'
    STR3        DB 'scse', '.'
    STR4        DB 'assembly', '.'
    STR5        DB '19260817', '.'
    STR6        DB 'GitHub', '.'
    STR7        DB 'WindowsXP', '.'
    ; list of string pointers
    STR_NUM     DW 7
    STR_LIST    DW STR1, STR2, STR3, STR4, STR5, STR6, STR7
                DW ?    ; for the newly-input string
    ; input string
    MAX_LEN     EQU 21h
    BUF         DB  MAX_LEN-1
    LEN         DB  ?
    STR8        DB  MAX_LEN DUP(?)
DATA    ENDS

CODE    SEGMENT
ASSUME  CS:CODE, DS:DATA, ES:DATA, SS:STACK

; strcmp, ends with '.'
STRCMP  PROC
    ; address of str1 and str2 is pushed into stack
    MOV BP, SP  ; str2 = [BP+02H], str1 = [BP+04H]
    ; protect registers
    PUSH SI
    PUSH DI
    ; protect ES and set ES=DS
    PUSH ES
    PUSH DS
    POP ES
    MOV DI, [BP+02H]
    MOV SI, [BP+04H]
    ; use loop
STRCMP_LOOP:
    ; if s1 or s2 ends, break
    CMP BYTE PTR [SI], '.'  ; s1 ends
    JZ STRCMP_BELOW         ; s1 < s2
    CMP BYTE PTR [DI], '.'  ; s2 ends
    JZ STRCMP_ABOVE         ; s1 > s2
    ; real strcmp for s1[i] and s2[i]
    CLD
    CMPSB
    JZ STRCMP_LOOP  ; if s1[i]==s2[i] continue
    JMP STRCMP_END
STRCMP_ABOVE:
    MOV AX, 1
    CMP AX, 0
    JMP STRCMP_END
STRCMP_BELOW:
    MOV AX, 0
    CMP AX, 1
    ; JMP STRCMP_END
STRCMP_END:
    ; restore ES
    POP ES
    ; restore registers
    POP DI
    POP SI
    RET 04H         ; pop str2 and str1
STRCMP  ENDP

; sort str table
SORT    PROC
    ; STR_LIST and STR_NUM
SORT_LP1:   ; loop1: until no swap in a row
    MOV BX, 1           ; setup swap flag
    MOV CX, STR_NUM     ; loop str_num times
    DEC CX              ; cx = str_num - 1 (downto 0)
    MOV SI, 0           ; offset = 0
SORT_LP2:   ; for i in 0...STR_NUM-1
    ; strcmp STR_LIST[SI], STR_LIST[SI+2]
    PUSH STR_LIST[SI]
    PUSH STR_LIST[SI+02H]
    CALL STRCMP
    JBE SORT_CONTINUE
    ; swap
    MOV AX, STR_LIST[SI]
    XCHG AX, STR_LIST[SI+2]
    MOV STR_LIST[SI], AX
    MOV BX, 0
SORT_CONTINUE:
    ADD SI, 2
    LOOP SORT_LP2
; end of LP2
    CMP BX, 1   ; if (not swapped) break
    JNZ SORT_LP1
; end of LP1
    RET
SORT    ENDP

; input str8
READ    PROC
    ; call input
    LEA DX, BUF
    MOV AH, 0AH
    INT 21H
    ; putchar '\n'
    MOV AH, 2
    MOV DL, 0AH
    INT 21H
    ; add '.' after
    MOV BH, 0
    MOV BL, LEN ; SI = len(STR8)
    MOV BYTE PTR STR8[BX], '.'
    RET
READ    ENDP

; insert into str table
INSERT  PROC
    ; put str8 after table
    LEA AX, STR8
    MOV BX, STR_NUM
    ADD BX, BX  ; offset BX words
    MOV STR_LIST[BX], AX
    ; swap until str[i - 1] <= str8 (or i == 0)
    ; loop old str_num times
    MOV CX, STR_NUM
INSERT_LP:
    ; strcmp str_list[i], str_list[i+1]
    ; str_list are words, use SI=2*CX
    MOV SI, CX  ; CX from STR_NUM to 1
    SUB SI, 1   ; i = CX - 1
    ADD SI, SI  ; 2 * CX, STR_LIST[SI]
    PUSH STR_LIST[SI]
    PUSH STR_LIST[SI+02H]
    CALL STRCMP
    ; if str_list[i] < str_list[i+1] break, else swap
    JB INSERT_END
    MOV AX, STR_LIST[SI]
    XCHG AX, STR_LIST[SI+02H]
    MOV STR_LIST[SI], AX
    LOOP INSERT_LP  ; CX--, if (CX==0) break
INSERT_END:
    ADD WORD PTR STR_NUM, 1
    RET
INSERT  ENDP

; print string terminated with '.'
PUTS    PROC
    ; SI: string start address
    ; use dos int 21h function 2
PUTS_LP:
    CLD
    LODSB   ; AL = [SI], SI++
    ; if (AL == '.') break
    CMP AL, '.'
    JZ PUTS_END
    ; print AL
    MOV DL, AL
    MOV AH, 2
    INT 21H
    JMP PUTS_LP
PUTS_END:
    RET
PUTS    ENDP

; print str list
PUTLIST PROC
    ; loop STR_NUM times
    MOV CX, STR_NUM     ; loop STR_NUM times
    LEA SI, STR_LIST    ; SI += 2 each cycle
PUTLIST_LP:
    ; output str_list[i]
    PUSH SI ; protect SI
    MOV SI, [SI]    ; SI = *str_list[i]
    CALL PUTS       ; consumes SI
    POP SI  ; restore SI
    ; CX-- and check break
    DEC CX
    CMP CX, 0
    JZ PUTLIST_END
    ; putchar ' '
    MOV DL, 20H
    MOV AH, 2
    INT 21H
    ; loop next
    ADD SI, 2
    JMP PUTLIST_LP
PUTLIST_END:
    ; putchar '\n'
    MOV DL, 0AH
    MOV AH, 2
    INT 21H
    RET
PUTLIST ENDP

; main program
MAIN    PROC
; setup segment registers
    MOV AX, STACK
    MOV SS, AX
    MOV SP, STACK_TOP
    MOV AX, DATA
    MOV DS, AX
    MOV ES, AX

    CALL PUTLIST    ; output raw list
    CALL SORT       ; sort it
    CALL PUTLIST    ; output sorted list
    CALL READ       ; input str8
    CALL INSERT     ; insert into list
    CALL PUTLIST    ; output inserted list

; return to dos
    MOV AX, 4C00H
    INT 21H
MAIN    ENDP
CODE    ENDS
END     MAIN