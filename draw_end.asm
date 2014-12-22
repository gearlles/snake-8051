fmg_score_1 SET 0x28
fmg_score_0 SET 0x28

fmg_numbers_font: DB 0F8h, 088h, 0F8h, 090h, 0F8h, 080h, 090h, 0C8h, 0B8h, 088h, 0A8h, 050h, 038h, 020h, 0F8h, 038h, 0A8h, 048h, 0F8h, 0A8h, 0D8h, 008h, 0D8h, 081h, 0F8H, 0A8H, 0F8h, 038h, 028h, 0F8h

code
    FMG_DRAW_SCORE:
    PUSH PSW
    SETB RS1
    CLR RS0
    MOV A, fmg_score_1
    MOV B, #006h
    MUL AB
    MOV B, #00Ah
    DIV AB
    MOV R2, A; Estouro!
    MOV A, B; Unidades da parte High do score!
    MOV R1, A
    MOV A, fmg_score_0
    MOV B, #00Ah
    DIV AB
    MOV R7, A ;Divisão
    MOV A, B
    ADD A, R1
    MOV R1, A 
    MOV B, #00Ah
    DIV AB
    ADD A, R2
    MOV R2, A
    MOV A, B
    MOV R1, A ;Unidades!
    MOV A, R7
    ADDC A, #000h
    MOV R7, A
    
    MOV A, fmg_score_1
    MOV B, #005h
    MUL AB
    ADD A, R2
    MOV B, #00Ah
    DIV AB
    MOV R3, A;Estouro
    MOV A, B; Dezenas da parte High do score!
    MOV R2, A
    MOV A, R7
    MOV B, #00Ah
    DIV AB
    MOV R7, A ; Divisão
    MOV A, B
    ADD A, R2
    MOV R2, A ;Dezenas
    MOV B, #00Ah
    DIV AB
    ADD A, R3
    MOV R3, A
    MOV A, B
    MOV R2, A
    MOV A, R7
    ADDC A, #000h
    MOV R7, A
    
    MOV A, fmg_score_1
    MOV B, #002h
    MUL AB
    ADD A, R3
    MOV B, #00Ah
    DIV AB
    MOV R4, A;Estouro
    MOV A, B; Centenas da parte High do score!
    MOV R3, A
    MOV A, R7
    MOV B, #00Ah
    DIV AB
    MOV R7, A ; Divisão
    MOV A,B
    ADD A, R3
    MOV R3, A ;Centenas
    MOV B, #00Ah
    DIV AB
    ADD A, R4
    MOV R4, A
    MOV A, B
    MOV R3, A
    MOV A, R7
    ADDC A, #000h
    MOV R7, A
    
    MOV A, R1
    PUSH ACC
    MOV A, R2
    PUSH ACC
    MOV A, R3
    PUSH ACC
    MOV A, R4
    PUSH ACC
    
    ;;;;;;;;;;;;;
    ;; DESENHO ;;
    ;;;;;;;;;;;;;
    SETB RS1
    CLR RS0
    
    MOV DPTR, #fmg_numbers_font
    MOV R3, #000h
    ;Milhares
    POP ACC
    MOV lcd_X, #020h
    MOV lcd_Y, #034h
    LCALL LCD_XY
    
    MOV B, #003h
    MUL AB
    MOV R4, A
    MOVC A, @A+DPTR
    MOV lcd_bus, A    
    LCALL LCD_DRAW
    INC R4
    MOV A, R4
    MOVC A, @A+DPTR
    MOV lcd_bus, A
    LCALL LCD_DRAW
    INC R4
    MOV A, R4
    MOVC A, @A+DPTR
    MOV lcd_bus, A
    LCALL LCD_DRAW
    
    ;Centenas
    POP ACC
    MOV lcd_X, #025h
    MOV lcd_Y, #034h
    LCALL LCD_XY
    
    MOV B, #003h
    MUL AB
    MOV R4, A
    MOVC A, @A+DPTR
    MOV lcd_bus, A    
    LCALL LCD_DRAW
    INC R4
    MOV A, R4
    MOVC A, @A+DPTR
    MOV lcd_bus, A
    LCALL LCD_DRAW
    INC R4
    MOV A, R4
    MOVC A, @A+DPTR
    MOV lcd_bus, A
    LCALL LCD_DRAW
    
    ;Dezenas
    POP ACC
    MOV lcd_X, #02Ah
    MOV lcd_Y, #034h
    LCALL LCD_XY
    
    MOV B, #003h
    MUL AB
    MOV R4, A
    MOVC A, @A+DPTR
    MOV lcd_bus, A
    LCALL LCD_DRAW
    INC R4
    MOV A, R4
    MOVC A, @A+DPTR
    MOV lcd_bus, A
    LCALL LCD_DRAW
    INC R4
    MOV A, R4
    MOVC A, @A+DPTR
    MOV lcd_bus, A
    LCALL LCD_DRAW
    
    ;Unidades
    POP ACC
    MOV lcd_X, #02Fh
    MOV lcd_Y, #034h
    LCALL LCD_XY
    MOV B, #003h
    MUL AB
    MOV R4, A
    MOVC A, @A+DPTR
    MOV lcd_bus, A
    LCALL LCD_DRAW
    INC R4
    MOV A, R4
    MOVC A, @A+DPTR
    MOV lcd_bus, A
    LCALL LCD_DRAW
    INC R4
    MOV A, R4
    MOVC A, @A+DPTR
    MOV lcd_bus, A
    LCALL LCD_DRAW
    POP PSW
    RET
    
code
    FMG_DRAW_END:
    PUSH PSW
    SETB RS1
    CLR RS0
    
    LCALL LCD_CLEAR

    ;;;;;;;;;;;;;;;
    ;; GAME OVER ;;
    ;;;;;;;;;;;;;;;
    MOV lcd_X, #01Bh
    MOV lcd_Y, #001h
    LCALL LCD_XY    
    
    ;G
    MOV lcd_bus, #0FFh
    LCALL LCD_DRAW
    MOV lcd_bus, #081h
    LCALL LCD_DRAW
    MOV lcd_bus, #081h
    LCALL LCD_DRAW
    MOV lcd_bus, #091h
    LCALL LCD_DRAW
    MOV lcd_bus, #091h
    LCALL LCD_DRAW
    MOV lcd_bus, #0F1h
    LCALL LCD_DRAW
    

    MOV lcd_bus, #000h
    LCALL LCD_DRAW
    MOV lcd_bus, #000h
    LCALL LCD_DRAW
    
    ;A
    MOV lcd_bus, #0FFh
    LCALL LCD_DRAW
    MOV lcd_bus, #011h
    LCALL LCD_DRAW
    MOV lcd_bus, #011h
    LCALL LCD_DRAW
    MOV lcd_bus, #011h
    LCALL LCD_DRAW
    MOV lcd_bus, #011h
    LCALL LCD_DRAW
    MOV lcd_bus, #0FFh
    LCALL LCD_DRAW
    
    MOV lcd_bus, #000h
    LCALL LCD_DRAW
    MOV lcd_bus, #000h
    LCALL LCD_DRAW
    
    ;M
    MOV lcd_bus, #0FFh
    LCALL LCD_DRAW
    MOV lcd_bus, #003h
    LCALL LCD_DRAW
    MOV lcd_bus, #01Ch
    LCALL LCD_DRAW
    MOV lcd_bus, #01Ch
    LCALL LCD_DRAW
    MOV lcd_bus, #003h
    LCALL LCD_DRAW
    MOV lcd_bus, #0FFh
    LCALL LCD_DRAW
    
    MOV lcd_bus, #000h
    LCALL LCD_DRAW
    MOV lcd_bus, #000h
    LCALL LCD_DRAW
    
    ;E
    MOV lcd_bus, #0FFh
    LCALL LCD_DRAW
    MOV lcd_bus, #091h
    LCALL LCD_DRAW
    MOV lcd_bus, #091h
    LCALL LCD_DRAW
    MOV lcd_bus, #091h
    LCALL LCD_DRAW
    MOV lcd_bus, #081h
    LCALL LCD_DRAW
    MOV lcd_bus, #081h
    LCALL LCD_DRAW
    
    MOV lcd_X, #01Bh
    MOV lcd_Y, #003h
    LCALL LCD_XY   
    
    ;0
    MOV lcd_bus, #0FFh
    LCALL LCD_DRAW
    MOV lcd_bus, #081h
    LCALL LCD_DRAW
    MOV lcd_bus, #081h
    LCALL LCD_DRAW
    MOV lcd_bus, #081h
    LCALL LCD_DRAW
    MOV lcd_bus, #081h
    LCALL LCD_DRAW
    MOV lcd_bus, #0FFh
    LCALL LCD_DRAW


    MOV lcd_bus, #000h
    LCALL LCD_DRAW
    MOV lcd_bus, #000h
    LCALL LCD_DRAW
    
    ;V
    MOV lcd_bus, #007h
    LCALL LCD_DRAW
    MOV lcd_bus, #038h
    LCALL LCD_DRAW
    MOV lcd_bus, #0C0h
    LCALL LCD_DRAW
    MOV lcd_bus, #0C0h
    LCALL LCD_DRAW
    MOV lcd_bus, #038h
    LCALL LCD_DRAW
    MOV lcd_bus, #007h
    LCALL LCD_DRAW
        
    MOV lcd_bus, #000h
    LCALL LCD_DRAW
    MOV lcd_bus, #000h
    LCALL LCD_DRAW
    
    ;E
    MOV lcd_bus, #0FFh
    LCALL LCD_DRAW
    MOV lcd_bus, #091h
    LCALL LCD_DRAW
    MOV lcd_bus, #091h
    LCALL LCD_DRAW
    MOV lcd_bus, #091h
    LCALL LCD_DRAW
    MOV lcd_bus, #081h
    LCALL LCD_DRAW
    MOV lcd_bus, #081h
    LCALL LCD_DRAW
    
    
    MOV lcd_bus, #000h
    LCALL LCD_DRAW
    MOV lcd_bus, #000h
    LCALL LCD_DRAW
    
    ;R
    MOV lcd_bus, #0FFh
    LCALL LCD_DRAW
    MOV lcd_bus, #009h
    LCALL LCD_DRAW
    MOV lcd_bus, #019h
    LCALL LCD_DRAW
    MOV lcd_bus, #029h
    LCALL LCD_DRAW
    MOV lcd_bus, #049h
    LCALL LCD_DRAW
    MOV lcd_bus, #086h
    LCALL LCD_DRAW
    
    LCALL FMG_DRAW_SCORE
    
    FMG_DRAW_END_ETERNAL:
        LCALL SNAKE_READ_BUTTONS
        JMP FMG_DRAW_END_ETERNAL
    POP PSW
    RET