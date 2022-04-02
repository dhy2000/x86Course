; Bubble sort based on TTTT.ASM
STACK       SEGMENT PARA STACK
STACK_AREA  DW      100h DUP(?)
STACK_TOP   EQU     $-STACK_AREA
STACK       ENDS

DATA        SEGMENT PARA
TABLE_LEN   DW 16
TABLE       DW 200,300,400,10,20,1837H,5354H,1,8,41H,40,42H,3321h,60,0FFFFH,2,3
            ; 1837h, 5354h
; hexadecimal characters
HEXCHAR     DB  '0123456789ABCDEF'
DATA        ENDS

CODE        SEGMENT
ASSUME      CS:CODE,DS:DATA, SS:STACK

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

; print 16-bit integer in hexadecimal
PUTHEX16    PROC    ; print DX
; protect registers
            PUSH AX
            PUSH DX
; print 4 bytes from high to low
            MOV AL, DH
            CALL PUTB
            MOV AL, DL
            CALL PUTB
; restore registers and return
            POP DX
            POP AX
            RET
PUTHEX16    ENDP

; bubble sort
BUBBLE_SORT PROC    ; sort `TABLE` in memory with `TABLE_LEN` before.
LP1:
            MOV     BX, 1   ; flag
            MOV     CX, TABLE_LEN
            DEC     CX  ; loop TABLE_LEN times
            LEA     SI, TABLE   ; i = 0
LP2:
            MOV     AX, [SI]    ; a[i], a[i + 1]
            CMP     AX, [SI+2]
            JBE     CONTINUE    ; if a[i] > a[i + 1] swap
            XCHG    AX, [SI+2]  ; swap
            MOV     [SI], AX
            MOV     BX, 0       ; swap happen in a pass
CONTINUE:
            ADD     SI, 2       ; i++
            LOOP    LP2
; end of LP2
            CMP     BX, 1       ; if (not swapped) break
            JZ      EXIT
            JMP     SHORT LP1   ; loop LP1
; end of LP1
EXIT:
            RET
BUBBLE_SORT ENDP

; main program
MAIN        PROC
; setup stack and data
            MOV     AX,STACK
            MOV     SS,AX
            MOV     SP,STACK_TOP
            MOV     AX,DATA
            MOV     DS,AX               ;SET SS,SP,DS
; display the old table
            MOV     CX,0
            MOV     SI,0
PRINT_LOOP1:
            MOV     DX, [SI+TABLE]
            CALL PUTHEX16
            ; cx += 1
            INC     CX
            ADD     SI, 2
            CMP     CX, TABLE_LEN
            JZ      PRINT_LOOP1_END
            ; putchar ' '
            MOV     DL, 20H
            MOV     AH, 2
            INT     21H
            ; loop
            JMP     PRINT_LOOP1
; end of print loop 1
PRINT_LOOP1_END:
            ; putchar '\n'
            MOV     DL, 0AH
            MOV     AH, 2
            INT     21H
; call bubblesort
            CALL    BUBBLE_SORT
; end of sort
            MOV     CX,0
            MOV     SI,0
PRINT_LOOP2:
            MOV     DX, [SI+TABLE]
            CALL PUTHEX16
            ; cx += 1
            INC     CX
            ADD     SI, 2
            CMP     CX, TABLE_LEN
            JZ      PRINT_LOOP2_END
            ; putchar ' '
            MOV     DL, 20H
            MOV     AH, 2
            INT     21H
            JMP     PRINT_LOOP2
; end of print loop 2
PRINT_LOOP2_END:
; return to dos
            MOV     AX,4C00H
            INT     21H
MAIN        ENDP
CODE        ENDS
END         MAIN

