#Tecnológico de Costa Rica - Ingeniería Electrónica
#Veronica Cambronero, Pablo Elizondo y Marycruz Fallas.
#Proyecto I. Diseño de Sistemas Digitales.

#-----------------------------------------------------
#                      PONG GAME
#-----------------------------------------------------

.data
LED_MATRIX_BASE: .word 0xf0000000
MATRIX_WIDTH:    .word 0x37      # d'55
MATRIX_HEIGHT:   .word 0x37

D_PAD_BASE:  .word 0xf0002f44
D_PAD_UP:    .word 0xf0002f44
D_PAD_DOWN:  .word 0xf0002f48
D_PAD_LEFT:  .word 0xf0002f4c
D_PAD_RIGHT: .word 0xf0002f50

P1_Y: .word 0x0       # Paleta derecha
P1_X: .word 0x0       
P2_Y: .word 0x32      # Paleta izquierda
P2_X: .word 0x36      

#bolita
BALL_X:     .word 0x1A      # posici?n inicial X
BALL_Y:     .word 0x1A      # posici?n inicial Y
BALL_DX:    .word 0x1       # direcci?n en X (1 = derecha, -1 = izquierda)
BALL_DY:    .word 0x1       # direcci?n en Y (1 = abajo, -1 = arriba)
BALL_OLD_X: .word 0x1A
BALL_OLD_Y: .word 0x1A

#Puntajes
SCORE_LEFT:  .word 0
SCORE_RIGHT: .word 0


.text
.globl _start

_start:
loop:
    # Leer bot?n UP
    li t0, 0xf0002f44
    lw t1, 0(t0)
    bnez t1, move_up1

    # Leer bot?n DOWN
    lw t1, 4(t0)
    bnez t1, move_down2

    # Leer bot?n LEFT
    lw t1, 8(t0)
    bnez t1, move_down1

    # Leer bot?n RIGHT
    lw t1, 12(t0)
    bnez t1, move_up2

    # Dibujar paletas
    jal draw_p1
    jal draw_p2
    
    #bolita
    jal move_ball       # primero actualiza y guarda la posici?n vieja
    jal clear_ball      # borra la posici?n antigua
    jal check_collision
    jal draw_ball

    j loop

# ==== L?GICA DE MOVIMIENTO ====

move_up1:
    jal clear_p1
    la t0, P1_Y
    lw t1, 0(t0)
    li t2, 0
    beq t1, t2, loop
    addi t1, t1, -1
    sw t1, 0(t0)
    j loop

move_down1:
    jal clear_p1
    la t0, P1_Y
    lw t1, 0(t0)
    li t2, 0x30    # l?mite inferior para 5 LEDs
    beq t1, t2, loop
    addi t1, t1, 1
    sw t1, 0(t0)
    j loop

move_up2:
    jal clear_p2
    la t0, P2_Y
    lw t1, 0(t0)
    li t2, 0
    beq t1, t2, loop
    addi t1, t1, -1
    sw t1, 0(t0)
    j loop

move_down2:
    jal clear_p2
    la t0, P2_Y
    lw t1, 0(t0)
    li t2, 0x30
    beq t1, t2, loop
    addi t1, t1, 1
    sw t1, 0(t0)
    j loop

# ==== DIBUJAR PALETAS ====
draw_p1:
    li t3, 0xf0000000         # t3 = base matriz
    li t4, 0x37               # t4 = ancho de la matriz
    li t5, 0xff00ff         # t5 = color azul
    li t6, 0                  # t6 = contador i = 0

    la t0, P1_X
    lw t1, 0(t0)              # t1 = X
    la t0, P1_Y
    lw t2, 0(t0)              # t2 = Y

draw_p1_loop:
    mul t0, t2, t4            # t0 = y * ancho
    add t0, t0, t1            # t0 = y * ancho + x
    slli t0, t0, 2            # t0 = offset en bytes
    add t0, t0, t3            # t0 = direcci?n final
    sw t5, 0(t0)              # pintar pixel azul

    addi t2, t2, 1            # y++
    addi t6, t6, 1            # i++
    li t0, 5
    blt t6, t0, draw_p1_loop
    ret
draw_p2:
    li t3, 0xf0000000         # t3 = base matriz
    li t4, 0x37               # t4 = ancho
    li t5, 0x00ff00         # t5 = color azul
    li t6, 0                  # t6 = contador i = 0

    la t0, P2_X
    lw t1, 0(t0)              # t1 = X
    la t0, P2_Y
    lw t2, 0(t0)              # t2 = Y

draw_p2_loop:
    mul t0, t2, t4            # t0 = y * ancho
    add t0, t0, t1            # t0 = y * ancho + x
    slli t0, t0, 2            # t0 = offset en bytes
    add t0, t0, t3            # t0 = direcci?n final
    sw t5, 0(t0)              # pintar azul

    addi t2, t2, 1            # y++
    addi t6, t6, 1            # i++
    li t0, 5
    blt t6, t0, draw_p2_loop
    ret

clear_p1:
    li t3, 0xf0000000         # base de la matriz
    li t4, 0x37               # ancho
    li t5, 0x000000           # color negro (apagar)
    li t6, 0

    la t0, P1_X
    lw t1, 0(t0)
    la t0, P1_Y
    lw t2, 0(t0)

clear_p1_loop:
    mul t0, t2, t4
    add t0, t0, t1
    slli t0, t0, 2
    add t0, t0, t3
    sw t5, 0(t0)

    addi t2, t2, 1
    addi t6, t6, 1
    li t0, 5
    blt t6, t0, clear_p1_loop
    ret

clear_p2:
    li t3, 0xf0000000
    li t4, 0x37
    li t5, 0x000000
    li t6, 0

    la t0, P2_X
    lw t1, 0(t0)
    la t0, P2_Y
    lw t2, 0(t0)

clear_p2_loop:
    mul t0, t2, t4
    add t0, t0, t1
    slli t0, t0, 2
    add t0, t0, t3
    sw t5, 0(t0)

    addi t2, t2, 1
    addi t6, t6, 1
    li t0, 5
    blt t6, t0, clear_p2_loop
    ret

# Mostrar puntaje del jugador izquierdo (columna 0 en adelante)
la t0, SCORE_LEFT      # direcci?n del puntaje izquierdo
lw t1, 0(t0)           # t1 = valor del puntaje
li t2, 0               # contador de columnas
li t3, 0xf0000000      # direcci?n base matriz LED

loop_left_score:
    beq t2, t1, done_left_score
    slli t4, t2, 2      # offset = columna * 4 (porque cada LED ocupa 4 bytes)
    add t5, t3, t4      # t5 = direcci?n del LED
    li t6, 0x0000FF     # color azul
    sw t6, 0(t5)
    addi t2, t2, 1
    j loop_left_score

done_left_score:


# Mostrar puntaje del jugador derecho (columna 54 hacia la izquierda)
la t0, SCORE_RIGHT     # direcci?n del puntaje derecho
lw t1, 0(t0)           # t1 = valor del puntaje
li t2, 0               # contador de columnas
li t3, 0xf0000000      # direcci?n base matriz LED

loop_right_score:
    beq t2, t1, done_right_score
    li t4, 54           # empezamos en columna 54
    sub t4, t4, t2      # columna actual = 54 - t2
    slli t5, t4, 2      # offset = columna * 4
    add t6, t3, t5      # direcci?n LED
    li t5, 0xFF0000     # color rojo
    sw t5, 0(t6)
    addi t2, t2, 1
    j loop_right_score

done_right_score:
 draw_score:
    player_right_scored:
    la t3, SCORE_RIGHT
    lw t4, 0(t3)
    addi t4, t4, 1
    sw t4, 0(t3)
    j reset_ball

    player_left_scored:
    la t3, SCORE_LEFT
    lw t4, 0(t3)
    addi t4, t4, 1
    sw t4, 0(t3)
    j reset_ball
    
    ret
#bolita
draw_ball:
    # t3 = base matriz
    li t3, 0xf0000000
    li t4, 0x37              # ancho
    li t5, 0xffffff          # color blanco

    la t0, BALL_X
    lw t1, 0(t0)             # t1 = X
    la t0, BALL_Y
    lw t2, 0(t0)             # t2 = Y

    mul t0, t2, t4           # offset fila
    add t0, t0, t1           # offset total
    slli t0, t0, 2           # offset en bytes
    add t0, t0, t3           # direcci?n final

    sw t5, 0(t0)             # pintar bola
    ret

move_ball:

    # Guardar posici?n ACTUAL antes de mover, como "anterior"
    la t0, BALL_X
    lw t1, 0(t0)
    la t2, BALL_OLD_X
    sw t1, 0(t2)

    la t0, BALL_Y
    lw t1, 0(t0)
    la t2, BALL_OLD_Y
    sw t1, 0(t2)

    # Ahora s? movemos la bola
    la t0, BALL_X
    lw t1, 0(t0)
    la t2, BALL_DX
    lw t3, 0(t2)
    add t1, t1, t3
    sw t1, 0(t0)

    la t0, BALL_Y
    lw t1, 0(t0)
    la t2, BALL_DY
    lw t3, 0(t2)
    add t1, t1, t3
    sw t1, 0(t0)

    ret


invert_dy:
    la t0, BALL_DY
    lw t1, 0(t0)
    neg t1, t1
    sw t1, 0(t0)
    ret
    
clear_ball:
    li t3, 0xf0000000     # base matriz
    li t4, 0x37           # ancho matriz
    li t5, 0x000000       # color negro

    la t0, BALL_OLD_X
    lw t1, 0(t0)
    la t0, BALL_OLD_Y
    lw t2, 0(t0)

    mul t0, t2, t4
    add t0, t0, t1
    slli t0, t0, 2
    add t0, t0, t3
    sw t5, 0(t0)
    ret


check_collision:
    # Cargar posici?n de la bola
    la t0, BALL_X
    lw t1, 0(t0)      # t1 = BALL_X
    la t0, BALL_Y
    lw t2, 0(t0)      # t2 = BALL_Y

    # Revisar l?mites verticales (techo y suelo)
    li t3, 0
    beq t2, t3, invert_dy_2       # Si toca el techo
    li t3, 54
    beq t2, t3, invert_dy_2       # Si toca el suelo

    # Revisar colisi?n con paleta derecha (X=54)
    la t0, P2_X
    lw t3, 0(t0)                # t3 = P2_X (54)
    la t0, BALL_DX
    lw t4, 0(t0)                # t4 = direcci?n X de la bola
    blez t4, check_left_paddle  # Solo verificar si se mueve hacia la derecha (DX > 0)

    addi t5, t3, -1
    bne t1, t5, check_left_paddle  # La bola est? en X=53 (justo antes de la paleta)

    # Verificar rango Y de la paleta derecha (5 posiciones)
    la t0, P2_Y
    lw t3, 0(t0)                # t3 = P2_Y
    addi t4, t3, 4              # t4 = P2_Y + 4 (5 posiciones en total)

    blt t2, t3, check_left_paddle  # Bola arriba de la paleta
    bgt t2, t4, check_left_paddle  # Bola abajo de la paleta



    j invert_dx                 # Colisi?n v?lida, invertir direcci?n
    ret
check_left_paddle:
    # Revisar colisi?n con paleta izquierda (X=0)
    la t0, P1_X
    lw t3, 0(t0)                # t3 = P1_X (0)
    la t0, BALL_DX
    lw t4, 0(t0)                # t4 = direcci?n X de la bola
    bgez t4, end_collision      # Solo verificar si se mueve hacia la izquierda (DX < 0)

    addi t5, t3, 1
    bne t1, t5, end_collision   # La bola est? en X=1 (justo antes de la paleta)

    # Verificar rango Y de la paleta izquierda (5 posiciones)
    la t0, P1_Y
    lw t3, 0(t0)                # t3 = P1_Y
    addi t4, t3, 4              # t4 = P1_Y + 4 (5 posiciones en total)

    blt t2, t3, end_collision  # Bola arriba de la paleta
    bgt t2, t4, end_collision  # Bola abajo de la paleta



    j invert_dx                 # Colisi?n v?lida, invertir direcci?n

invert_dx:
    la t0, BALL_DX
    lw t1, 0(t0)
    neg t1, t1
    sw t1, 0(t0)
    j end_collision

invert_dy_2:
    la t0, BALL_DY
    lw t1, 0(t0)
    neg t1, t1
    sw t1, 0(t0)

end_collision:
    ret
    
