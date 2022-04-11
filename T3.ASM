; Multiplication of two 32-bit unsigned integers.
STACK       SEGMENT PARA STACK
STACK_AREA  DW  100h DUP(?)
STACK_TOP   EQU $-STACK_AREA
STACK       ENDS

DATA        SEGMENT PARA
; multiplier and product
X           DD 18375354     ; multiplier 1
Y           DD 18373391     ; multiplier 2
P           DD 2 DUP(00H)   ; 4 words, 8 bytes
; hexadecimal characters
HEXDIGIT    DB '0123456789ABCDEF'
DATA        ENDS

CODE        SEGMENT PAGE
ASSUME      CS:CODE, DS:DATA, SS:STACK
; Display a byte in hexadecimal
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
            MOV DL, [SI+HEXDIGIT]   ; relative addressing
            MOV AH, 2
            INT 21H     ; putchar
; print low digit
            POP AX
            MOV DL, AL
            AND DL, 0FH ; low digit
            MOV SI, DX
            MOV DL, [SI+HEXDIGIT]
            MOV AH, 2
            INT 21H
; restore registers and return
            POP SI
            POP DX
            POP CX
            RET
PUTB        ENDP

; Display 64-bit integer in hexadecimal
PUTHEX64    PROC    ; print mem64@[BX]
; protect registers
            PUSH AX
            PUSH BX
            PUSH DX
; display 8 bytes from high to low
            MOV AL, [BX+7]
            CALL PUTB
            MOV AL, [BX+6]
            CALL PUTB
            MOV AL, [BX+5]
            CALL PUTB
            MOV AL, [BX+4]
            CALL PUTB
            MOV AL, [BX+3]
            CALL PUTB
            MOV AL, [BX+2]
            CALL PUTB
            MOV AL, [BX+1]
            CALL PUTB
            MOV AL, [BX]
            CALL PUTB
; restore registers and return
            POP DX
            POP BX
            POP AX
            RET
PUTHEX64    ENDP

; Display 64-bit integer in decimal.
PUTINT64    PROC    ; print mem64@[BX]
; protect registers
            PUSH AX
            PUSH BX
            PUSH CX
            PUSH DX
            PUSH BP ; store temp-result to stack
; if [BX] == 0 : print 0
            MOV AX, [BX]
            OR  AX, [BX+02H]
            OR  AX, [BX+04H]
            OR  AX, [BX+06H]
            CMP AX, 0
            JNZ PUTINT64_MAIN
; print zero
PUTINT64_ZERO:
            MOV AH, 2
            MOV DL, 30H
            INT 21H
            JMP PUTINT64_RET
PUTINT64_MAIN:
; copy mem64@[BX] to stack
            SUB SP, 16  ; two 64-bit
            MOV BP, SP
            MOV AX, [BX+00H]
            MOV [BP+08H], AX
            MOV AX, [BX+02H]
            MOV [BP+0AH], AX
            MOV AX, [BX+04H]
            MOV [BP+0CH], AX
            MOV AX, [BX+06H]
            MOV [BP+0EH], AX
            JMP PUTINT64_LOOP1
; [BP] / 10, [BP] % 10 : per word, 4 times
PUTINT64_LOOP1:
            MOV CX, 0AH ; divisor: 10
            MOV DX, 0   ; higher part (partial remainder)
            MOV AX, [BP+0EH]
            DIV CX      ; DX, AX = AX % 10, AX / 10
            MOV [BP+06H], AX  ; partial-quotient
            MOV AX, [BP+0CH]
            DIV CX
            MOV [BP+04H], AX
            MOV AX, [BP+0AH]
            DIV CX
            MOV [BP+02H], AX
            MOV AX, [BP+08H]
            DIV CX
            MOV [BP+00H], AX    ; DX is the remainder
            PUSH DX         ; follow BP
; copy BP[0:3] to BP[4:7]
            MOV AX, [BP+00H]
            MOV [BP+08H], AX
            MOV AX, [BP+02H]
            MOV [BP+0AH], AX
            MOV AX, [BP+04H]
            MOV [BP+0CH], AX
            MOV AX, [BP+06H]
            MOV [BP+0EH], AX
; if [BX] != 0 LOOP
            MOV AX, [BP+08H]
            OR AX, [BP+0AH]
            OR AX, [BP+0CH]
            OR AX, [BP+0EH]
            CMP AX, 0
            JNZ PUTINT64_LOOP1
; end of LOOP1
; print each digit
PUTINT64_LOOP2:
            POP DX
            ADD DL, 30H ; + '0'
            MOV AH, 2
            INT 21H
            CMP SP, BP  ; pop until stack-under-BP empty
            JNZ PUTINT64_LOOP2
; end of LOOP2
; finished output.
            ADD SP, 16  ; two 64-bit
; restore registers and return
PUTINT64_RET:
            POP BP
            POP DX
            POP CX
            POP BX
            POP AX
            RET
PUTINT64    ENDP

; test output functions
TEST_OUTPUT PROC
; test PUTB
            MOV AL, 3AH
            CALL PUTB
            ; putchar '\n'
            MOV DL, 0AH
            MOV AH, 2
            INT 21H
; test PUTHEX64
            LEA BX, X
            CALL PUTHEX64
            ; putchar '\n'
            MOV DL, 0AH
            MOV AH, 2
            INT 21H
; test PUTINT64
            CALL PUTINT64
            ; putchar '\n'
            MOV DL, 0AH
            MOV AH, 2
            INT 21H
; all test passed
            RET
TEST_OUTPUT ENDP

; Main program.
MAIN        PROC
; setup stack and data
            MOV AX, STACK
            MOV SS, AX
            MOV SP, STACK_TOP
            MOV AX, DATA
            MOV DS, AX

; test output functions
            ; CALL TEST_OUTPUT

; multiply two 32-bit numbers
            ; lo1 * lo2
            MOV AX, WORD PTR X+00H
            MOV BX, WORD PTR Y+00H
            MUL BX  ; DX:AX <- AX*BX
            MOV WORD PTR P+00H, AX
            MOV WORD PTR P+02H, DX
            ; lo1 * hi2
            MOV AX, WORD PTR X+00H
            MOV BX, WORD PTR Y+02H
            MUL BX
            ADD WORD PTR P+02H, AX
            ADC WORD PTR P+04H, DX
            ADC WORD PTR P+06H, 0
            ; hi1 * lo2
            MOV AX, WORD PTR X+02H
            MOV BX, WORD PTR Y+00H
            MUL BX
            ADD WORD PTR P+02H, AX
            ADC WORD PTR P+04H, DX
            ADC WORD PTR P+06H, 0
            ; hi1 * hi2
            MOV AX, WORD PTR X+02H
            MOV BX, WORD PTR Y+02H
            MUL BX
            ADD WORD PTR P+04H, AX
            ADC WORD PTR P+06H, DX
; output the production
            LEA BX, P
            ; output in hex
            CALL PUTHEX64
            ; putchar '\n'
            MOV DL, 0AH
            MOV AH, 2
            INT 21H
            ; output in dec
            CALL PUTINT64
            ; putchar '\n'
            MOV DL, 0AH
            MOV AH, 2
            INT 21H
; return to dos
            MOV AX, 4C00H
            INT 21H
; end of main program
MAIN        ENDP
CODE        ENDS
END         MAIN