; Input two decimal 32-bits integer, output sum equation in hexadecimal and decimal.
; Assume the sum does not exceed UINT32_MAX.

; stack segment
STACK       SEGMENT PARA STACK
STACK_AREA  DW  100h DUP(?)
STACK_TOP   EQU $-STACK_AREA
STACK       ENDS

; data segment
DATA        SEGMENT PARA
; numbers and the sum
A           DD  ?
B           DD  ?
S           DD  00H
; hexadecimal characters
HEXCHAR     DB  '0123456789ABCDEF'
HEXPREFIX   DB  '0x', '$'
DATA        ENDS

; code segment
CODE        SEGMENT
ASSUME      CS:CODE, DS:DATA, SS:STACK

; read a 32-bits decimal integer from console
GETINT32    PROC    ; [BX] = getint32()
; protect registers
            PUSH AX
            PUSH BX
            PUSH CX
            PUSH DX
; do
;   AL = getchar()
; while AL < '0' || AL > '9'
GETINT32_LOOP_1:
            MOV AH, 1
            INT 21H     ; char -> AL
            CMP AL, 30H ; 30H: '0'
            JB  GETINT32_LOOP_1 ; AL < '0': loop
            CMP AL, 39H ; 39H: '9'
            JA  GETINT32_LOOP_1 ; AL > '9': loop
; end of loop 1
; setup ret@[BX] = 0
            MOV WORD PTR [BX+00H], 0
            MOV WORD PTR [BX+02H], 0
; do
;   ret = ret * 10 + (ch - '0')
;   ch(AL) = getchar()
; until AL < '0' || AL > '9'
GETINT32_LOOP_2:
            ; AL - '0'
            MOV AH, 0
            SUB AL, 30H ; AL -= '0'
            PUSH AX     ; cache ch-'0'
            ; ret * 10
            MOV CX, 10
            MOV AX, [BX+00H]
            MUL CX      ; DX:AX = ret.lo * 10
            MOV [BX+00H], AX
            PUSH DX     ; cache hi(ret.lo*10)
            MOV AX, [BX+02H]
            MUL CX      ; DX:AX = ret.hi * 10, discard DX
            POP DX      ; DX = hi(ret.lo*10)
            ADD DX, AX  ; hi(x*10)=hi(x.lo*10)+lo(x.hi*10)
            MOV [BX+02H], DX
            ; add them
            POP CX      ; ch-'0'
            MOV AX, [BX+00H]
            ADD AX, CX  ; generate carry-flag
            MOV [BX+00H], AX
            MOV AX, 0
            ADC [BX+02H], AX    ; add CF
            ; get next char
            MOV AH, 1
            INT 21H     ; AL = getchar()
            CMP AL, 30H ; '0'
            JB GETINT32_RET    ; AL < '0': break
            CMP AL, 39H ; '9'
            JA GETINT32_RET    ; AL > '9': break
            JMP GETINT32_LOOP_2
GETINT32_RET:
; restore registers
            POP DX
            POP CX
            POP BX
            POP AX
            RET
GETINT32    ENDP

; print a 32-bits integer in decimal
PUTINT32    PROC    ; putint32 mem32@[BX]
; protect registers
            PUSH AX
            PUSH BX
            PUSH CX
            PUSH DX
            PUSH BP ; cache quotient in stack
; if [BX] == 0: print 0
            MOV AX, [BX+00H]
            OR  AX, [BX+02H]
            CMP AX, 0
            JNZ PUTINT32_MAIN
; print zero
PUTINT32_ZERO:
            MOV DL, 0
            MOV AH, 2
            INT 21H
            JMP PUTINT32_RET
PUTINT32_MAIN:
; setup cache space in stack
            SUB SP, 8   ; two double-words
            MOV BP, SP  ; d and d / 10
; copy mem32@[BX] to stack
            MOV AX, [BX+00H]
            MOV [BP+04H], AX
            MOV AX, [BX+02H]
            MOV [BP+06H], AX
PUTINT32_LOOP1:
; rem@DX = d % 10, quo@[BP] = d@[BP+4] / 10
            MOV CX, 0AH ; divisor 10
            MOV DX, 0   ; partial remainder and higher part
            MOV AX, [BP+06H]
            DIV CX
            MOV [BP+02H], AX    ; partial quotient
            MOV AX, [BP+04H]    ; DX:AX with DX fall through
            DIV CX
            MOV [BP+00H], AX
            PUSH DX     ; store d % 10
; copy quo@[BP] to d@[BP+4]
            MOV AX, [BP+00H]
            MOV [BP+04H], AX
            MOV AX, [BP+02H]
            MOV [BP+06H], AX
; if d@[BP+4] != 0: loop
            MOV AX, [BP+04H]
            OR  AX, [BP+06H]
            CMP AX, 0
            JNZ PUTINT32_LOOP1
; end of loop1
; print each digit from stack
PUTINT32_LOOP2:
            POP DX
            ADD DL, 30H ; DL += '0'
            MOV AH, 2
            INT 21H
            CMP BP, SP  ; until stack-under-BP is empty
            JNZ PUTINT32_LOOP2
; end of loop2
; free cache space
            ADD SP, 8
PUTINT32_RET:
; restore registers
            POP BP
            POP DX
            POP CX
            POP BX
            POP AX
            RET
PUTINT32    ENDP

; print a byte value in hexadecimal
PUTB        PROC    ; print AL in hexadecimal
; protect registers
            PUSH CX
            PUSH DX
            PUSH SI
; print high digit
            PUSH AX
            MOV DH, 0
            MOV DL, AL
            MOV CL, 4
            SHR DL, CL  ; AL >> 4
            MOV SI, DX
            MOV DL, [SI+HEXCHAR]    ; relative addressing
            MOV AH, 2
            INT 21H     ; putchar
; print low digit
            POP AX
            MOV DL, AL
            AND DL, 0FH ; low digit
            MOV SI, DX
            MOV DL, [SI+HEXCHAR]
            MOV AH, 2
            INT 21H
; restore registers and return
            POP SI
            POP DX
            POP CX
            RET
PUTB        ENDP

; print 32-bit integer in hexadecimal
PUTHEX32    PROC    ; print mem32@[BX]
; protect registers
            PUSH AX
            PUSH BX
            PUSH DX
; print 4 bytes from high to low
            MOV AL, [BX+03H]
            CALL PUTB
            MOV AL, [BX+02H]
            CALL PUTB
            MOV AL, [BX+01H]
            CALL PUTB
            MOV AL, [BX+00H]
            CALL PUTB
; restore registers and return
            POP DX
            POP BX
            POP AX
            RET
PUTHEX32    ENDP

; main program
MAIN        PROC
; setup segment registers
            MOV AX, STACK
            MOV SS, AX
            MOV SP, STACK_TOP
            MOV AX, DATA
            MOV DS, AX
; input number 1
            LEA BX, A
            CALL GETINT32
; input number 2
            LEA BX, B
            CALL GETINT32
; calculate the sum
            MOV AX, WORD PTR A+00H
            ADD AX, WORD PTR B+00H  ; set CF
            MOV WORD PTR S+00H, AX
            MOV AX, WORD PTR A+02H
            ADC AX, WORD PTR B+02H  ; add CF
            MOV WORD PTR S+02H, AX
; output the sum equation in decimal
            ; print a
            LEA BX, A
            CALL PUTINT32
            ; putchar '+'
            MOV DL, 2BH
            MOV AH, 2
            INT 21H
            ; print b
            LEA BX, B
            CALL PUTINT32
            ; putchar '='
            MOV DL, 3DH
            MOV AH, 2
            INT 21H
            ; print sum
            LEA BX, S
            CALL PUTINT32
            ; putchar '\n'
            MOV DL, 0AH
            MOV AH, 2
            INT 21H
; output the sum equation in hexadecimal
            ; print 0x
            LEA DX, HEXPREFIX
            MOV AH, 9
            INT 21H
            ; print a
            LEA BX, A
            CALL PUTHEX32
            ; putchar '+'
            MOV DL, 2BH
            MOV AH, 2
            INT 21H
            ; print 0x
            LEA DX, HEXPREFIX
            MOV AH, 9
            INT 21H
            ; print b
            LEA BX, B
            CALL PUTHEX32
            ; putchar '='
            MOV DL, 3DH
            MOV AH, 2
            INT 21H
            ; print 0x
            LEA DX, HEXPREFIX
            MOV AH, 9
            INT 21H
            ; print sum
            LEA BX, S
            CALL PUTHEX32
            ; putchar '\n'
            MOV DL, 0AH
            MOV AH, 2
            INT 21H
; return to dos
            MOV AX, 4C00H
            INT 21H
MAIN        ENDP
CODE        ENDS
END         MAIN
