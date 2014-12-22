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
    
    FMG_DRAW_END_ETERNAL:
        JMP FMG_DRAW_END_ETERNAL
    POP PSW
    RET