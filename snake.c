#include <reg51.h>

#define SNAKE_MAX_SIZE 20
#define SNAKE_SCREEN_WIDTH 84
#define SNAKE_SCREEN_HEIGHT 48

sbit left = P3 ^ 2;
sbit right = P3 ^ 7;
sbit up = P3 ^ 4;
sbit down = P3 ^ 3;

// array com as posições X da Snake
unsigned char x[SNAKE_MAX_SIZE + 1];
// array com as posições Y da Snake
unsigned char y[SNAKE_MAX_SIZE + 1];
// tamanho atual da Snake
unsigned char n;
// contador utilizado para iterar pela Snake
unsigned char i;

char addx, addy;

int rand()
{
    // TODO
    return 5;
}

void updateDirections()
{
    if (left == 0)
    {
        addy = 0;
        if (addx != 1)
            addx = -1;
        else
            addx = 1;
    }

    if (right == 0)
    {
        addy = 0;
        if (addx != -1)
            addx = 1;
        else
            addx = -1;
    }

    if (down == 0)
    {
        addx = 0;
        if (addy != -1)
            addy = 1;
        else
            addy = -1;
    }

    if (up == 0)
    {
        addx = 0;
        if (addy != 1)
            addy = -1;
        else
            addy = 1;
    }
}

int colision()
{
    bit k;
    k = 0;
    // colisão com as paredes
    if (x[1] > SNAKE_SCREEN_WIDTH || y[1] > SNAKE_SCREEN_HEIGHT)
        k = 1;
    // colisão com o corpo
    for (i = 2; i < n; i++)
        if ((x[1] == x[i]) && (y[1] == y[i]))
            k = 1;
    return k;
}

void mainn(void)
{
    while (1)
    {
        for (i = 3; i < SNAKE_MAX_SIZE + 1; i++)
        {
            x[i] = 100;
        }
        for (i = 3; i < SNAKE_MAX_SIZE + 1; i++)
        {
            y[i] = 100; 
        }
    
        //  posição inicial da comida
        x[0] = rand(); 
        y[0] = rand();
    
        n = 2; // tamanho inicial da snake
        
        // posição inicial da cabeça
        x[1] = 1; y[1] = 2; 
        // posição inicial da calda
        x[2] = 1; y[2] = 1;
    
        // sentido inicial
        addx = 0; addy = 1;
    
        while (1)
        {
            updateDirections();

            // checando colisão
            if (colision())
            {
                // Fim de jogo!
                break;
            }
        
            // checando se a posição atual da cabeça tem comida
            if ((x[0] == x[1] + addx) && (y[0] == y[1] + addy))
            {
                n++;
            
                // se atingiu o limite da snake, reseta
                if (n == SNAKE_MAX_SIZE)
                {
                    break;
                }
            
                // adiciona comida em outro lugar
                x[0] = rand();
                y[0] = rand();
            }
        
            for (i = n; i > 1; i--)
            {
                x[i] = x[i - 1];
                y[i] = y[i - 1];
            }
        
            x[1] = x[2] + addx;
            y[1] = y[2] + addy;
        }
    }
}