; ---------------------------------- ;
; UNIVERSIDADE DE PERNAMBUCO         ;
; ESCOLA POLITÉCNICA DE PERNAMBUCO   ;
; ECOMP                              ;
; ---------------------------------- ;
; ALUNO: GEARLLES VIANA FERREIRA     ;
; ORIENTADOR: DANIEL CHAVES          ;
; RECIFE, DEZEMBRO DE 2014           ;
; ---------------------------------- ;

$include(REG52.inc)
$include(Random.asm)
$include(LCD.asm)
$include(draw_end.asm)

SNAKE_MAX_SIZE SET 0x20

SNAKE_SCREEN_WIDTH SET 0x54
SNAKE_SCREEN_HEIGHT SET 0x30

SNAKE_X_ARRAY_START_ADDRESS SET 0x38
SNAKE_Y_ARRAY_START_ADDRESS SET 0x50

SNAKE_ADD_X_ADDRESS SET 0x30
SNAKE_ADD_Y_ADDRESS SET 0x31

SNAKE_SIZE_ADDRESS SET 0x32

; variaveis globais temporarias (em minusculo!)
x_temp SET 0x33
y_temp SET 0x34
k SET 0x35
i SET 0x36
j SET 0x37

SNAKE_PRE_SCREEN_Y_START_ADDRESS SET 0x00

code at 0
    MOV SP, #080h
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
        MOV @R0, #000h
        INC R0
        DJNZ R1, SNAKE_CLEAR_X_MEMORY_LOOP_START
    
    ; limpando regiao Y
    MOV R1, #SNAKE_MAX_SIZE
    MOV R0, #SNAKE_Y_ARRAY_START_ADDRESS
    SNAKE_CLEAR_Y_MEMORY_LOOP_START:
        MOV @R0, #000h
        INC R0
        DJNZ R1, SNAKE_CLEAR_Y_MEMORY_LOOP_START
    RET

code
SNAKE_INIT:
    ; zera o gerador de num aleatorio
    MOV R0, 0x20
    MOV @R0, #000H
    
    ; a snake comeca com duas partes
    MOV R0, #SNAKE_SIZE_ADDRESS
    MOV @R0, #02h

    ;LCALL RAND8 ; gera um numero aleatorio no acumulador
    MOV A, #03h
    MOV B, #SNAKE_SCREEN_WIDTH
    DIV AB
    MOV A, B
    MOV R0, #SNAKE_X_ARRAY_START_ADDRESS
    MOV @R0, A ; seta posicao X inicial da comida ; x[0] = rand
    INC R0
    MOV @R0, #03h ; x[1] = 1
    INC R0
    MOV @R0 #03h ; x[2] = 1

    
    ;LCALL RAND8 ; gera um numero aleatorio no acumulador
    MOV A, #08h
    MOV B, #SNAKE_SCREEN_HEIGHT
    DIV AB
    MOV A, B
    MOV R0, #SNAKE_Y_ARRAY_START_ADDRESS
    MOV @R0, A ; seta posicao Y inicial da comida ; y[0] = rand
    INC R0
    MOV @R0, #06H ; y[1] = 2
    INC R0
    MOV @R0, #05H ; y[2] = 1

    
    MOV R0, #SNAKE_ADD_X_ADDRESS
    MOV @R0, #00H
    MOV R0, #SNAKE_ADD_Y_ADDRESS
    MOV @R0, #01H
    RET
    
code
SNAKE_UPDATE:
    LCALL SNAKE_CHECK_GAME_END
    JNC SNAKE_UPDATE_START
    
    MOV R0, #FMG_SCORE_0
    MOV @R0, #0A0h
    MOV R0, #FMG_SCORE_1
    MOV @R0, #000h
    LCALL FMG_DRAW_END
    
    SNAKE_UPDATE_START:
    
    ; checar se comeu
    ; (x[0] == x[1] + addx)
    MOV R0, #00H
    MOV A, SNAKE_ADD_X_ADDRESS
    MOV R0, #SNAKE_X_ARRAY_START_ADDRESS
    INC R0
    ADD A, @R0 ; A <- addx + x[1]
    MOV R5, A ; R5 <- addx + x[1]
    MOV R6, SNAKE_X_ARRAY_START_ADDRESS ; R6 <- x[0]
    MOV B, R6
    CJNE A, B, SNAKE_UPDATE_END_CHECK_FOOD
    
    ; (y[0] == y[1] + addy)
    MOV A, SNAKE_ADD_Y_ADDRESS
    MOV R0, #SNAKE_Y_ARRAY_START_ADDRESS
    INC R0
    ADD A, @R0 ; A <- addy + y[1]
    MOV R7, A ; R5 <- addy + y[1]
    MOV R6, SNAKE_Y_ARRAY_START_ADDRESS ; R6 <- y[0]
    MOV B, R6
    CJNE A, B, SNAKE_UPDATE_END_CHECK_FOOD
    
    ; cresce o corpo
    MOV R0, #SNAKE_SIZE_ADDRESS
        MOV A, @R0
        MOV R3, A
        LOOP_INCREASE_BODY:
            MOV A, R3
            CJNE A, #000h, INCREASE
            SETB C
        INCREASE:
            JC AFTER_INCREASE_LOOP
            
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
            SJMP LOOP_INCREASE_BODY
        AFTER_INCREASE_LOOP:
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

    MOV R0, #SNAKE_X_ARRAY_START_ADDRESS
    MOV A, R5
    MOV @R0, A
    MOV R0, #SNAKE_Y_ARRAY_START_ADDRESS
    MOV A, R7
    MOV @R0, A
    
    ; posiciona nova comida
    LCALL RAND8 ; gera um numero aleatorio no acumulador
    MOV B, #14h
    DIV AB
    MOV A, B
    MOV R0, #SNAKE_X_ARRAY_START_ADDRESS
    MOV @R0, A
    
    LCALL RAND8 ; gera um numero aleatorio no acumulador
    MOV B, #14h
    DIV AB
    MOV A, B
    MOV R0, #SNAKE_Y_ARRAY_START_ADDRESS
    MOV @R0, A
    
    ; incrementar SNAKE_SIZE_ADDRESS
    MOV R0, #SNAKE_SIZE_ADDRESS
    MOV A, @R0
    INC A
    MOV @R0, A
    
    ;SJMP SNAKE_UPDATE_END
    
    SNAKE_UPDATE_END_CHECK_FOOD:
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
    SNAKE_UPDATE_END:
    RET
    
code
SNAKE_CHECK_GAME_END:
    CLR C
    CLR k
    MOV A, SNAKE_SIZE_ADDRESS
    CJNE A, #SNAKE_MAX_SIZE, SNAKE_ELSE_MAX

    SETB k

    SNAKE_ELSE_MAX:
          MOV R0, #SNAKE_X_ARRAY_START_ADDRESS+01H
          MOV A, @R0
          ;MOV A, SNAKE_X_ARRAY_START_ADDRESS+01H
          CJNE A, #SNAKE_SCREEN_WIDTH, SNAKE_CHECK_HEIGHT
          SETB C
          SNAKE_CHECK_HEIGHT:
                JNC SNAKE_FIRST_IF_SET
                MOV R0, #SNAKE_Y_ARRAY_START_ADDRESS+01H
                MOV A, @R0
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
          MOV R0, #SNAKE_X_ARRAY_START_ADDRESS+01H
          MOV A, @R0
          CJNE A, B, SNAKE_COLISION_NEXT_ITERATION
          MOV A, i
          ADD A, #SNAKE_Y_ARRAY_START_ADDRESS
          MOV R1, A
          MOV B, @R1
          MOV R0, #SNAKE_Y_ARRAY_START_ADDRESS+01H
          MOV A, @R0
          CJNE A, B, SNAKE_COLISION_NEXT_ITERATION
          SETB k
    SNAKE_COLISION_NEXT_ITERATION:
          INC i
          SJMP SNAKE_COLISION_MAIN_LOOP
    SNAKE_COLISION_END_LOOP:
          MOV C, k
    RET    
    
code
SNAKE_READ_BUTTONS:
    CHECK_LEFT:
        JB P1.2, CHECK_RIGHT
        
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
        JB P1.3, CHECK_DOWN
        
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
        JB P1.0, CHECK_UP
        CLR    A
        MOV    SNAKE_ADD_X_ADDRESS,A
        CJNE   A,#0FFH,NOT_EQUAL_CHECK_DOWN
        MOV    A,SNAKE_ADD_Y_ADDRESS
        CPL    A
        JZ     CHECK_DOWN_ELSE
        
        NOT_EQUAL_CHECK_DOWN:
            MOV    SNAKE_ADD_Y_ADDRESS,#001H
            SJMP   CHECK_UP
        CHECK_DOWN_ELSE:
            MOV    SNAKE_ADD_Y_ADDRESS,#0FFH
        
    CHECK_UP:
        JB     P1.1, CHECK_RESET
        CLR    A
        MOV    SNAKE_ADD_X_ADDRESS,A
        MOV    A,SNAKE_ADD_Y_ADDRESS
        XRL    A,#001H
        JZ     CHECK_UP_ELSE
        MOV    SNAKE_ADD_Y_ADDRESS,#0FFH
        RET
        CHECK_UP_ELSE:
            MOV    SNAKE_ADD_Y_ADDRESS,#001H
        
    CHECK_RESET:
        JB P1.4, CHECK_BUTTONS_END
        LJMP SNAKE_MAIN
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
    MOV    i,  #000H
    SNAKE_CONVERT_MEMORY_LOOP:
        MOV    A, i
        CJNE   A, SNAKE_SIZE_ADDRESS, SNAKE_CONVERT_MEMORY_LOOP_I
    SNAKE_CONVERT_MEMORY_LOOP_I:
        JNC    SNAKE_CONVERT_MEMORY_LOOP_END
        MOV    A, i
        ADD    A, #SNAKE_X_ARRAY_START_ADDRESS
        MOV    R0, A
        MOV    A, @R0
        ADD    A, ACC
        MOV    x_temp, A
        
        MOV    A, i
        ADD    A, #SNAKE_Y_ARRAY_START_ADDRESS
        MOV    R0, A
        MOV    A, @R0
        ADD    A, ACC
        MOV    y_temp, A
        
        MOV    j, #000H
    SNAKE_CONVERT_MEMORY_LOOP_J:
        MOV    k, #000H
    SNAKE_CONVERT_MEMORY_LOOP_K:
        MOV    A, k
        ADD    A, y_temp ; A <- k + y
        MOV    B,  #054H
        MUL    AB  ; A <- (k+y) * width
        
        MOV    DPL,  A
        MOV    DPH,  B ; dptr <- (k + y) * width
        
        MOV    A,  j
        ADD    A,  x_temp ; A <- x + j
        
        ADD    A,  DPL
        MOV    DPL,  A
        MOV    A,  DPH
        ADDC   A,  #000H
        MOV    DPH,  A ; dptr <- (y + k) * width + (x + j)
        
        MOV    A, #001H
        MOVX   @DPTR, A
        
        INC    k
        MOV    A, k
        CJNE   A, #002H, SNAKE_CONVERT_MEMORY_LOOP_K
        
        INC    j
        MOV    A, j
        CJNE   A, #002H, SNAKE_CONVERT_MEMORY_LOOP_J
        
        INC    i
        SJMP   SNAKE_CONVERT_MEMORY_LOOP
        SNAKE_CONVERT_MEMORY_LOOP_END:
    RET     

; Transfere e tela da memoria para o LCD
code
NTMJ_DRAW_TO_LCD:
    PUSH PSW ; Salva a pagina atual
    PUSH ACC ; Salva o ACC atual
    SETB RS1 ; Vai para a pagina do LCD
    SETB RS0 ; Vai para a pagina do LCD
    LCALL LCD_CLEAR ; Limpa o display
    MOV DPTR, #00h ; Vai para o comeco da tela na memoria
    MOV A, #0 ; Vai para o comeco da tela no LCD
    MOV B, #0 ; Vai para o comeco da tela no LCD
    LCALL LCD_ACC_XY ; Vai para o comeco da tela no LCD
    MOV R6, #6 ; Quantidade de linhas a serem andadas no display
    NTMJ_DRAW_LCD_LINE:
        MOV R7, #84 ; Quantidade de colunas a serem andadas no display
        NTMJ_DRAW_LCD_COLUMN:
            LCALL NTMJ_EXTRACT_LCD_COLUMN ; Salva em B o resultado do extract column
            LCALL LCD_ACC_DRAW ; Usa o B resultante anterior pra desenhar no LCD
            INC DPTR ; Aponta para a proxima coluna, na memoria
            DJNZ R7 NTMJ_DRAW_LCD_COLUMN ; Se ainda restam colunas a visitar, refaz
            ; neste trecho, o cursor esta na ultima coluna da linha
            ; para ir para proxima linha temos q fazer dptr + 7*84
            ; que eh a mesma coisa que fazer dptr + 3*84 + 3*83 + 84
            MOV B, #252 
            LCALL NTMJ_ADD_DPTR 
            MOV B, #252 
            LCALL NTMJ_ADD_DPTR 
            MOV B, #84 ; Vai para a proxima linha Y
            LCALL NTMJ_ADD_DPTR ; Vai para a proxima linha Y
            DJNZ R6 NTMJ_DRAW_LCD_LINE ; Se ainda restarem linhas a visitar, refaz
    MOV A, #2
    MOV B, #0
    LCALL LCD_ACC_XY
    POP ACC ; Restaura o ACC anterior
    POP PSW ; Restaura a pagina anterior
    RET

; Extrai um byte de coluna da representa da tela, em memoria
code
NTMJ_EXTRACT_LCD_COLUMN:
    PUSH ACC ; Guarda o acumulador atual
    MOV A, DPH ; Guarda o DPH
    PUSH ACC ; Guarda o DPH
    MOV A, DPL ; Guarda o DPL
    PUSH ACC ; Guarda o DPL
    MOV R5, #0 ; Resultado
    MOV R3, #8 ; Contador de bytes a serem utilizados
    NTMJ_EXTRACT_LCD_LOOP: 
        MOVX A, @DPTR ; Le o byte atual
        MOV R4, A ; Salva o byte atual em R4
        MOV A, R5 ; Recupera o resultado mais recente
        ORL A, R4 ; Adiciona o byte atual no resultado
        RR A ; Rotaciona o novo resultado
        MOV R5, A ; Sobrescreve o resultado antigo pelo atualizado
        MOV B, #84 ; Avanca para o endereco do proximo byte
        LCALL NTMJ_ADD_DPTR ; Avanca para o endereco do proximo byte
        DJNZ R3 NTMJ_EXTRACT_LCD_LOOP ; Se ainda nao atingiu a qtd de bytes, faz de novo
    MOV B, R5 ; Salva o resultado em B, para retorno
    POP ACC ; Recupera o DPL
    MOV DPL, A ; Recupera o DPL
    POP ACC ; Recupera o DPH
    MOV DPH, A ; Recupera o DPH
    POP ACC ; Recupera o ACC
    RET 
    
code
NTMJ_ADD_DPTR:
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
    MOV R0, B
    LCALL LCD_DRAW
    POP PSW
    POP ACC
    ret