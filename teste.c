#include <reg51.h>

#define SNAKE_MAX_SIZE 20
#define SNAKE_SCREEN_WIDTH 84
#define SNAKE_SCREEN_HEIGHT 48

unsigned char x[SNAKE_MAX_SIZE + 1];
unsigned char y[SNAKE_MAX_SIZE + 1];
unsigned char n;
// contador utilizado para iterar pela Snake, declarado como global pra economizar mem�ria
unsigned char i;

int colision()
{
    bit k;
    k = 0;
    // colis�o com as paredes
    if (x[1] > SNAKE_SCREEN_WIDTH || y[1] > SNAKE_SCREEN_HEIGHT)
        k = 1;
    // colis�o com o corpo
    for (i = 2; i < n; i++)
        if ((x[1] == x[i]) && (y[1] == y[i]))
            k = 1;
    return k;
}

void main(void)
{
    if (colision()){
        
    }
}