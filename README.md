# Proyecto I: Diseño de Sistemas Digitales

Veronica Cambronero, 
Pablo Elizondo y 
Marycruz Fallas.

Este proyecto consta del juego "Pong" en el simulador Ripes, utilizando lenguaje ensamblador. Para el mismo, se utilizan dos dispositivos periféricos con los que dispone el simulador, una matriz de LEDs y un DPAD con botones para 4 direcciones posibles. 

## Pasos iniciales

Antes de comenzar el juego y la simulación, es necesario agregar los periféricos en el orden correcto y establecer los tamaños adecuados para que la simulación funcione adecuadamente. 

Comenzando con el espacio de trabajo completamente vacío, se puede hacer doble click sobre el periférico "LED Matrix" para agregarlo:
![image](https://github.com/user-attachments/assets/d4bb8c6d-1fe4-4c3a-b736-823f8bf9f10d)

Luego, se habilita la columna derecha en donde se pueden ajustar los tamaños de alto y ancho de la matriz de LEDs. Para coincidir con lo preestablecido en el juego, ambas dimensiones deben estar ajustadas en 55; el tamaño de cada LED por su parte, se puede variar para visualizar de mejor forma la matriz, según se requiera:
![image](https://github.com/user-attachments/assets/009c9bbd-0069-4989-8661-86e8ab600091)

Ahora sí, se hace doble click sobre el periférico denotado como "D-Pad" para incluirlo dentro de la simulación:
![image](https://github.com/user-attachments/assets/5a21f3f3-7993-4e0f-bce7-32af1c08822a)

Con ambos periféricos incluidos y ajustados, se puede corroborar las direcciones en memoria para cada uno de estos:

     LED_MATRIX_0
     #define LED_MATRIX_0_BASE	(0xf0000000)
     #define LED_MATRIX_0_SIZE	(0x2f44)
     #define LED_MATRIX_0_WIDTH	(0x37)
     #define LED_MATRIX_0_HEIGHT	(0x37)
__________
     D_PAD_0
     #define D_PAD_0_BASE	(0xf0002f44)
     #define D_PAD_0_SIZE	(0x10)
     #define D_PAD_0_UP_OFFSET	(0x0)
     #define D_PAD_0_UP	(0xf0002f44)
     #define D_PAD_0_DOWN_OFFSET	(0x4)
     #define D_PAD_0_DOWN	(0xf0002f48)
     #define D_PAD_0_LEFT_OFFSET	(0x8)
     #define D_PAD_0_LEFT	(0xf0002f4c)
     #define D_PAD_0_RIGHT_OFFSET	(0xc)
     #define D_PAD_0_RIGHT	(0xf0002f50)

## Ajuste de tiempos de simulación

En el simulador, viene por defecto un periodo para las simulaciones de 100 ms, este tiempo se puede ajustar hasta un mínimo de 1 ms de forma que la simulación se vea un poco más fluida y mejore la experiencia en el juego; sin embargo, cabe mencionar que aún así, la simulación se ejecuta de una forma no tan rápida como se quisiera. 
![image](https://github.com/user-attachments/assets/b9ae2a2f-4fc0-4de0-a15c-cc5489575f60)

## Controles y modo de juego

El D-Pad cuenta con 4 botones para las direcciones. De los cuales la flecha "arriba" e "izquierda" son para el jugador de la izquierda (jugador 1), mientras que los botones de "abajo" y "derecha" son para el jugador de la derecha (jugador 2). 

      Flecha arriba: Jugador 1 - mover arriba
      Flecha izquierda: Jugador 1 - mover abajo

      Flecha derecha: Jugador 2 - mover arriba
      Flecha abajo: Jugador 2 - mover abajo

Listo, ya están todos los detalles para poder jugar Pong. Ahora solo intenta que la bolita no choque con la pared de tu lado de la matriz, o si no, perderás. 
