$include(REG52.inc)
$include(Random.asm)


SNAKE_MAX_SIZE SET 0x09
SNAKE_MAX_SIZE_ADDRESS SET 0x50

SNAKE_SCREEN_WIDTH SET 0x54
SNAKE_SCREEN_WIDTH_ADDRESS SET 0x51

SNAKE_SCREEN_HEIGHT SET 0x30
SNAKE_SCREEN_HEIGHT_ADDRESS SET 0x52

SNAKE_X_ARRAY_START_ADDRESS SET 0xA0
SNAKE_Y_ARRAY_START_ADDRESS SET 0xB8

SNAKE_ADD_X_ADDRESS SET 0x53
SNAKE_ADD_Y_ADDRESS SET 0x54

SNAKE_SIZE_ADDRESS SET 0x55

; variaveis globais temporarias
x_temp SET 0x56
y_temp SET 0x57
k SET 0x58
i SET 0x59

SNAKE_PRE_SCREEN_Y_START_ADDRESS SET 0x00

code at 0
    MOV SP, #0D0h
    ljmp SNAKE_MAIN

SNAKE_MAIN:
    LCALL LCD_INIT
    ; limpa a regiao de memoria da Snake
    LCALL SNAKE_CLEAR_INTERNAL_MEMORY
    ; configura o estado inicial da Snake
    LCALL SNAKE_INIT
    SNAKE_MAIN_LOOP:
        ; le a memoria da Snake e converte para informacao pre-tela
        LCALL SNAKE_CONVERT_MEMORY
        ; le e regiao de memoria que armazena 
        ; as informacoes da Snake e imprime na tela
        LCALL NTMJ_DRAW_TO_LCD
        ; le os botoes e atualiza a memoria
        LCALL SNAKE_READ_BUTTONS
        ; atualiza a regiao de memoria da Snake
        LCALL SNAKE_UPDATE
        SJMP SNAKE_MAIN_LOOP
    RET

code
SNAKE_CLEAR_INTERNAL_MEMORY:
    ; limpando regiao X
    MOV R1, #SNAKE_MAX_SIZE
    MOV R0, #SNAKE_X_ARRAY_START_ADDRESS
    SNAKE_CLEAR_X_MEMORY_LOOP_START:
        MOV @R0, #001h
        INC R0
        DJNZ R1, SNAKE_CLEAR_X_MEMORY_LOOP_START
    
    ; limpando regiao Y
    MOV R1, #SNAKE_MAX_SIZE
    MOV R0, #SNAKE_Y_ARRAY_START_ADDRESS
    SNAKE_CLEAR_Y_MEMORY_LOOP_START:
        MOV @R0, #001h
        INC R0
        DJNZ R1, SNAKE_CLEAR_Y_MEMORY_LOOP_START
    RET
    
code
SNAKE_INIT:
    MOV R0, #SNAKE_MAX_SIZE_ADDRESS
    MOV @R0, #SNAKE_MAX_SIZE
    
    MOV R0, #SNAKE_SCREEN_WIDTH_ADDRESS
    MOV @R0, #SNAKE_SCREEN_WIDTH
    
    MOV R0, #SNAKE_SCREEN_HEIGHT_ADDRESS
    MOV @R0, #SNAKE_SCREEN_HEIGHT
    
    ; a snake comeca com duas partes
    MOV R0, #SNAKE_SIZE_ADDRESS
    MOV @R0, #02h

    LCALL RAND8 ; gera um numero aleatorio no acumulador
    MOV R0, #SNAKE_X_ARRAY_START_ADDRESS
    MOV @R0, A ; seta posicao X inicial da comida ; x[0] = rand
    INC R0
    MOV @R0, #01h ; x[1] = 1
    INC R0
    MOV @R0 #01h ; x[2] = 1
    
    LCALL RAND8 ; gera um numero aleatorio no acumulador
    MOV R0, #SNAKE_Y_ARRAY_START_ADDRESS
    MOV @R0, A ; seta posicao Y inicial da comida ; y[0] = rand
    INC R0
    MOV @R0, #02H ; y[1] = 2
    INC R0
    MOV @R0, #01H ; y[2] = 1
    
    MOV R0, #SNAKE_ADD_X_ADDRESS
    MOV @R0, #00H
    MOV R0, #SNAKE_ADD_Y_ADDRESS
    MOV @R0, #01H
    RET
    
code
NTMJ_EXTRACT_LCD_COLUMN:
    PUSH ACC
    MOV A, DPH
    PUSH ACC
    MOV A, DPL
    PUSH ACC
    MOV R5, #0
    MOV R3, #8 ; Contador de bits buscados
    NTMJ_EXTRACT_LCD_LOOP: 
        MOVX A, @DPTR
        MOV R4, A ; Salva o pixel em R4
        MOV A, R5
        RL A ; Rotaciona o valor anterior
        ORL A, R4 ; Adiciona o pixel lido agora
        MOV R5, A ; Sobrescreve o valor anterior
        MOV B, #84 ; Vai buscar o proximo
        LCALL NTMJ_INC_DPTR
        DJNZ R3 NTMJ_EXTRACT_LCD_LOOP
    MOV B, R5
    POP ACC
    MOV DPL, A
    POP ACC
    MOV DPH, A
    POP ACC
    RET
 
code
NTMJ_DRAW_TO_LCD:
    PUSH PSW ; Salva a pagina atual
    PUSH ACC ; Salva o ACC atual
    SETB RS1 ; Vai para a pagina do LCD
    SETB RS0 ; Vai para a pagina do LCD
    LCALL LCD_CLEAR
    MOV DPTR, #000h 
    MOV R6, #6 ; Laco externo eh y
    MOV lcd_Y, #0 ; Comeca em 00
    NTMJ_DRAW_LCD_LINE:
        MOV lcd_X, #0 ; Comeca em 00
        MOV R7, #84 ; Laco interno eh x
        NTMJ_DRAW_LCD_COLUMN:
            LCALL NTMJ_EXTRACT_LCD_COLUMN
            MOV lcd_bus, B
            MOV A, lcd_X
            MOV B, lcd_Y
            LCALL LCD_ACC_XY
            MOV B, lcd_bus
            LCALL LCD_ACC_DRAW
            INC lcd_X
            MOV B, #1
            LCALL NTMJ_INC_DPTR ; Vai para a proxima coluna
            ; Diminui o contador de colunas e repete ate q complete
            DJNZ R7 NTMJ_DRAW_LCD_COLUMN
            INC lcd_Y
            MOV B, #252
            LCALL NTMJ_INC_DPTR ; Vai para a proxima coluna
            MOV B, #252
            LCALL NTMJ_INC_DPTR ; Vai para a proxima coluna
            MOV B, #84
            LCALL NTMJ_INC_DPTR ; Vai para a proxima coluna
            ; Diminui o contador de linhas e repete ate q complete
            DJNZ R6 NTMJ_DRAW_LCD_LINE
 
    POP ACC ; Restaura o ACC anterior
    POP PSW ; Restaura a pagina anterior
    RET
    
code
NTMJ_INC_DPTR:
    PUSH ACC
    MOV A, DPL ; Pega o DPL pra ACC
    ADD A, B ; Soma B (pula um byte)
    MOV DPL, A ; Salva no DPL o ACC
    MOV A, DPH ; Pega o DPH pro ACC
    ADDC A, #00h ; Adiciona o carry da operacao anterior
    MOV DPH, A ; Salva no DPH o ACC
    POP ACC
    RET


code
LCD_ACC_XY:
    PUSH ACC 
    PUSH PSW 
    SETB RS1
    CLR RS0
    MOV lcd_X, A
    MOV lcd_Y, B
    LCALL LCD_XY
    POP PSW
    POP ACC
    ret
	
code
LCD_ACC_DRAW:
    PUSH ACC 
    PUSH PSW 
    SETB RS1
    CLR RS0
    MOV lcd_bus, B
    LCALL LCD_DRAW
    POP PSW
    POP ACC
    ret

code
SNAKE_CHECK_GAME_END:
    CLR k
    MOV A, SNAKE_SIZE_ADDRESS
    CJNE A, SNAKE_MAX_SIZE, SNAKE_ELSE_MAX

    SETB k

    SNAKE_ELSE_MAX:
          MOV A, SNAKE_X_ARRAY_START_ADDRESS+01H
          CJNE A, #054H, SNAKE_CHECK_HEIGHT
          SETB C
          SNAKE_CHECK_HEIGHT:
                JNC SNAKE_FIRST_IF_SET
                MOV A, SNAKE_Y_ARRAY_START_ADDRESS+01H
                CJNE A, #030H, SNAKE_IF_EXIT
                SETB C
          SNAKE_IF_EXIT:
                JC SNAKE_AFTER_FIRST_IF
    SNAKE_FIRST_IF_SET:
          SETB k
    SNAKE_AFTER_FIRST_IF:
          MOV i, #002H
    SNAKE_COLISION_MAIN_LOOP:
          MOV A, i
          CJNE A, SNAKE_SIZE_ADDRESS, SNAKE_COLITION_MAIN_LOOP_BODY
    SNAKE_COLITION_MAIN_LOOP_BODY:
          JNC SNAKE_COLISION_END_LOOP
          MOV A, i
          ADD A, #SNAKE_X_ARRAY_START_ADDRESS
          MOV R0, A
          MOV B, @R0
          MOV A, SNAKE_X_ARRAY_START_ADDRESS+01H
          CJNE A, B, SNAKE_COLISION_NEXT_ITERATION
          MOV A, i
          ADD A, #SNAKE_Y_ARRAY_START_ADDRESS
          MOV R1, A
          MOV B, @R1
          MOV A, SNAKE_Y_ARRAY_START_ADDRESS+01H
          CJNE A, B, SNAKE_COLISION_NEXT_ITERATION
          SETB k
    SNAKE_COLISION_NEXT_ITERATION:
          INC i
          SJMP SNAKE_COLISION_MAIN_LOOP
    SNAKE_COLISION_END_LOOP:
          MOV C, k
          CLR A
          RLC A
          MOV R6, #000H
          MOV R7, A
    RET

code
SNAKE_UPDATE:
    LCALL SNAKE_CHECK_GAME_END
    JC SNAKE_MAIN
        
    MOV R0, #SNAKE_SIZE_ADDRESS
    MOV A, @R0
    MOV R3, A
    LOOP_UPDATE_BODY:
        MOV A, R3
        CJNE A, #001h, BODY
        SETB C
    BODY:
        JC AFTER_LOOP
        
        MOV    A, R3
        ADD    A, #SNAKE_X_ARRAY_START_ADDRESS + 0FFH
        MOV    R0, A
        MOV    A, R3
        ADD    A, #SNAKE_X_ARRAY_START_ADDRESS
        MOV    R1, A
        MOV    A, @R0
        MOV    @R1, A
        
        MOV    A, R3
        ADD    A, #SNAKE_Y_ARRAY_START_ADDRESS + 0FFH
        MOV    R0, A
        MOV    A, R3
        ADD    A, #SNAKE_Y_ARRAY_START_ADDRESS
        MOV    R1, A
        MOV    A, @R0
        MOV    @R1, A
        
        DEC R3
        SJMP LOOP_UPDATE_BODY
    AFTER_LOOP:
       MOV R0, #SNAKE_ADD_X_ADDRESS
       MOV A, @R0
       MOV R0, #SNAKE_X_ARRAY_START_ADDRESS + 02H
       ADD A, @R0
       MOV R0, #SNAKE_X_ARRAY_START_ADDRESS + 01H
       MOV @R0, A
       
       MOV R0, #SNAKE_ADD_Y_ADDRESS
       MOV A, @R0
       MOV R0, #SNAKE_Y_ARRAY_START_ADDRESS + 02H
       ADD A, @R0
       MOV R0, #SNAKE_Y_ARRAY_START_ADDRESS + 01H
       MOV @R0, A
    RET
    
code
SNAKE_READ_BUTTONS:
    CHECK_LEFT:
        JNB P1.2, CHECK_RIGHT
        
        ;  addy = 0;
        CLR A
        MOV SNAKE_ADD_Y_ADDRESS, A
        
        ; if (addx != 1)
        MOV A, SNAKE_ADD_X_ADDRESS
        XRL A, #001H
        JZ ELSE_CHECK_LEFT
        
        ; addx = -1;
        MOV SNAKE_ADD_X_ADDRESS, #0FFH
        SJMP CHECK_RIGHT
        
        ELSE_CHECK_LEFT:
            ; addx = 1;
            MOV SNAKE_ADD_X_ADDRESS, #001H
        
    CHECK_RIGHT:
        JNB P1.3, CHECK_DOWN
        
        ;  addy = 0;
        CLR A
        MOV SNAKE_ADD_Y_ADDRESS, A
        
        CJNE A, #0FFH, NOT_EQUAL
        MOV A, SNAKE_ADD_X_ADDRESS
        CPL A
        JZ ELSE_CHECK_RIGHT
        
        NOT_EQUAL:
            MOV SNAKE_ADD_X_ADDRESS, #001H
            SJMP CHECK_DOWN
        ELSE_CHECK_RIGHT:
             MOV SNAKE_ADD_X_ADDRESS, #0FFH
             
    CHECK_DOWN:
        JB P1.1, CHECK_UP
        CLR    A
        MOV    SNAKE_ADD_Y_ADDRESS,A
        CJNE   A,#0FFH,NOT_EQUAL_CHECK_DOWN
        MOV    A,SNAKE_ADD_Y_ADDRESS
        CPL    A
        JZ     NOT_EQUAL_CHECK_DOWN
        
        NOT_EQUAL_CHECK_DOWN:
            MOV    SNAKE_ADD_Y_ADDRESS,#001H
            SJMP   CHECK_UP
        CHECK_DOWN_ELSE:
            MOV    SNAKE_ADD_Y_ADDRESS,#0FFH
        
    CHECK_UP:
        JB     P1.0, CHECK_BUTTONS_END
        CLR    A
        MOV    SNAKE_ADD_X_ADDRESS,A
        MOV    A,SNAKE_ADD_Y_ADDRESS
        XRL    A,#001H
        JZ     CHECK_UP_ELSE
        MOV    SNAKE_ADD_Y_ADDRESS,#0FFH
        RET
        CHECK_UP_ELSE:
            MOV    SNAKE_ADD_Y_ADDRESS,#001H
        CHECK_BUTTONS_END:
    RET
    
code
SNAKE_CONVERT_MEMORY:
    ; limpa a memoria antes de popular (sempre populo todos pixels)
    MOV    R5,#000H
    SNAKE_CONVERT_MEMORY_LOOP_CLEAN_MEMORY_I:
        MOV    A,R5
        CJNE   A,#SNAKE_SCREEN_HEIGHT,SNAKE_CONVERT_MEMORY_LOOP_SHIFT_I
        SNAKE_CONVERT_MEMORY_LOOP_SHIFT_I:
        JNC    SNAKE_CONVERT_MEMORY_LOOP_CLEAN_END_I

        MOV    R6,#000H
        SNAKE_CONVERT_MEMORY_LOOP_CLEAN_MEMORY_J:
            MOV    A,R6
            CJNE   A,#SNAKE_SCREEN_WIDTH,SNAKE_CONVERT_MEMORY_LOOP_SHIFT_J
            SNAKE_CONVERT_MEMORY_LOOP_SHIFT_J:
            JNC    SNAKE_CONVERT_MEMORY_LOOP_CLEAN_END_J

            MOV    A,R5
            MOV    B,#054H
            MUL    AB
            ADD    A,#LOW (SNAKE_PRE_SCREEN_Y_START_ADDRESS)
            MOV    DPL,A
            MOV    A,B
            ADDC   A,#HIGH (SNAKE_PRE_SCREEN_Y_START_ADDRESS)
            MOV    DPH,A
            MOV    A,R6
            ADD    A,DPL
            MOV    DPL,A
            CLR    A
            ADDC   A,DPH
            MOV    DPH,A
            CLR    A
            MOVX   @DPTR,A

            INC    R6
            SJMP   SNAKE_CONVERT_MEMORY_LOOP_CLEAN_MEMORY_J
        SNAKE_CONVERT_MEMORY_LOOP_CLEAN_END_J:

        INC    R5
        SJMP   SNAKE_CONVERT_MEMORY_LOOP_CLEAN_MEMORY_I
    SNAKE_CONVERT_MEMORY_LOOP_CLEAN_END_I:
            
        ; faz a conversao
        MOV    R4,#001H
        SNAKE_CONVERT_MEMORY_LOOP:
              MOV    A,#SNAKE_MAX_SIZE
              ADD    A,#001H
              MOV    R0,A
              CLR    A
              RLC    A
              MOV    R3,AR0
              MOV    B,A
              CPL    B.7
              MOV    A,#080H
              CJNE   A,B,SNAKE_CONVERT_MEMORY_SHIFT
              MOV    A,R4


              CJNE   A,AR3,SNAKE_CONVERT_MEMORY_SHIFT
              SNAKE_CONVERT_MEMORY_SHIFT:
              JC     $ + 5
              LJMP   SNAKE_CONVERT_MEMORY_LOOP_END

              MOV    A,R4
              ADD    A,#SNAKE_X_ARRAY_START_ADDRESS
              MOV    R0,A
              MOV    A,@R0
              ADD    A,ACC
              MOV    x_temp,A

              MOV    A,R4
              ADD    A,#SNAKE_Y_ARRAY_START_ADDRESS
              MOV    R0,A
              MOV    A,@R0
              ADD    A,ACC

              MOV    R3,A

              MOV    y_temp,A

              MOV    A,x_temp
              MOV    B,#054H
              MUL    AB
              ADD    A,#LOW (SNAKE_PRE_SCREEN_Y_START_ADDRESS)
              MOV    DPL,A
              MOV    A,B
              ADDC   A,#HIGH (SNAKE_PRE_SCREEN_Y_START_ADDRESS)
              MOV    DPH,A
              MOV    A,R3
              ADD    A,DPL
              MOV    DPL,A
              CLR    A
              ADDC   A,DPH
              MOV    DPH,A
              MOV    A,#001H
              MOVX   @DPTR,A

              MOV    A,x_temp
              MOV    B,#054H
              MUL    AB
              ADD    A,#LOW (SNAKE_PRE_SCREEN_Y_START_ADDRESS + 054H)
              MOV    DPL,A
              MOV    A,B
              ADDC   A,#HIGH (SNAKE_PRE_SCREEN_Y_START_ADDRESS + 054H)
              MOV    DPH,A
              MOV    A,R3
              ADD    A,DPL
              MOV    DPL,A
              CLR    A
              ADDC   A,DPH
              MOV    DPH,A
              MOV    A,#001H
              MOVX   @DPTR,A

              MOV    A,x_temp
              MOV    B,#054H

               
              MUL    AB
              ADD    A,#LOW (SNAKE_PRE_SCREEN_Y_START_ADDRESS + 01H)
              MOV    DPL,A
              MOV    A,B
              ADDC   A,#HIGH (SNAKE_PRE_SCREEN_Y_START_ADDRESS + 01H)
              MOV    DPH,A
              MOV    A,R3
              ADD    A,DPL
              MOV    DPL,A
              CLR    A
              ADDC   A,DPH
              MOV    DPH,A
              MOV    A,#001H
              MOVX   @DPTR,A

              MOV    A,x_temp
              MOV    B,#054H
              MUL    AB
              ADD    A,#LOW (SNAKE_PRE_SCREEN_Y_START_ADDRESS + 055H)
              MOV    DPL,A
              MOV    A,B
              ADDC   A,#HIGH (SNAKE_PRE_SCREEN_Y_START_ADDRESS + 055H)
              MOV    DPH,A
              MOV    A,R3
              ADD    A,DPL
              MOV    DPL,A
              CLR    A
              ADDC   A,DPH
              MOV    DPH,A
              MOV    A,#001H
              MOVX   @DPTR,A

              INC    R4
              LJMP   SNAKE_CONVERT_MEMORY_LOOP
        SNAKE_CONVERT_MEMORY_LOOP_END:
        RET     
END