.data
LED_MATRIX_BASE: .word 0xf0000010
MATRIX_WIDTH:    .word 0x37    # Matrix width (d'55)
MATRIX_HEIGHT:   .word 0x37    # Matrix height (d'55)
D_PAD_BASE:  .word 0xf0000dac
D_PAD_UP:    .word 0xf0000dac  # UP button address
D_PAD_DOWN:  .word 0xf0000db0  # DOWN button address
D_PAD_LEFT:  .word 0xf0000db4  # LEFT button address
D_PAD_RIGHT: .word 0xf0000db8  # RIGHT button address

# Variables de velocidad (ahora con valores iniciales claros)
dx: .word 1          # Velocidad horizontal (1 píxel/frame)
dy: .word 1          # Velocidad vertical (1 píxel/frame)

# Posiciones de las paletas
paddle_left: .word 20
paddle_right: .word 20

# Colores
ball_color: .word 0xFF0000  # Rojo
paddle_color: .word 0x00FF00 # Verde
bg_color: .word 0x000000    # Negro

.text
.globl main
   .globl _start
    
    _start:
        call main 
        j game_loop
    
main:
    # Inicialización de registros
    li s0, 27        # ball_x (posición X inicial)
    li s1, 27        # ball_y (posición Y inicial)
    
    # Cargar colores desde memoria
    la t0, ball_color
    lw s2, 0(t0)     # s2 = color pelota
    la t0, paddle_color
    lw s3, 0(t0)     # s3 = color paletas
    la t0, bg_color
    lw s4, 0(t0)     # s4 = color fondo
    
    # Dibujar elementos iniciales
    call draw_paddles
    call draw_ball

    # Bucle principal del juego
game_loop:
    
        # ====================
    # LECTURA DEL D-PAD
    # ====================
    # Arriba - Mover paleta izquierda hacia arriba
    li t0, 0xf0000dac
    lw t1, 0(t0)
    bnez t1, move_left_up

    # Abajo - Mover paleta izquierda hacia abajo
    li t0, 0xf0000db0
    lw t1, 0(t0)
    bnez t1, move_left_down

    # Izquierda - Mover paleta derecha hacia arriba
    li t0, 0xf0000db4
    lw t1, 0(t0)
    bnez t1, move_right_up

    # Derecha - Mover paleta derecha hacia abajo
    li t0, 0xf0000db8
    lw t1, 0(t0)
    bnez t1, move_right_down
    
    move_left_up:
    la t0, paddle_left
    lw t1, 0(t0)
    beqz t1, return_from_move      # Ya está arriba
    addi t1, t1, -1
    sw t1, 0(t0)
    call draw_paddles
    j game_loop

move_left_down:
    la t0, paddle_left
    lw t1, 0(t0)
    li t2, 47       # Límite inferior (55 - altura de paleta)
    bge t1, t2, return_from_move
    addi t1, t1, 1
    sw t1, 0(t0)
    call draw_paddles
    j game_loop

move_right_up:
    la t0, paddle_right
    lw t1, 0(t0)
    beqz t1, return_from_move
    addi t1, t1, -1
    sw t1, 0(t0)
    call draw_paddles
    j game_loop

move_right_down:
    la t0, paddle_right
    lw t1, 0(t0)
    li t2, 47
    bge t1, t2, return_from_move
    addi t1, t1, 1
    sw t1, 0(t0)
    call draw_paddles
    j game_loop

return_from_move:
    j game_loop


    # 1. Borrar pelota en posición actual
    mv a0, s0
    mv a1, s1
    mv a2, s4
    call pixel
    
    # 2. Actualizar posición (MOVIMIENTO CRÍTICO)
    # Actualizar X
    la t0, dx         # Cargar dirección de dx
    lw t1, 0(t0)      # Cargar valor de dx
    add s0, s0, t1    # Actualizar posición X
    
    # Actualizar Y
    la t0, dy         # Cargar dirección de dy
    lw t1, 0(t0)      # Cargar valor de dy
    add s1, s1, t1    # Actualizar posición Y
    
    # 3. Comprobar colisiones con bordes
    # Rebote en bordes superior e inferior (Y)
    blt s1, zero, invert_dy
    li t2, 54
    bgt s1, t2, invert_dy
    
    # 4. Comprobar colisiones con paletas
    # Paleta izquierda (X <= 1)
    li t2, 1
    ble s0, t2, check_left_paddle
    
    # Paleta derecha (X >= 53)
    li t2, 53
    bge s0, t2, check_right_paddle
    
update_display:
    # 5. Dibujar pelota en nueva posición
    call draw_ball
    # 7. Repetir bucle
    j game_loop

# ===== FUNCIONES DE COLISIÓN =====
invert_dy:
    la t0, dy
    lw t1, 0(t0)
    neg t1, t1       # Invertir dirección Y
    sw t1, 0(t0)
    j update_display

check_left_paddle:
    la t0, paddle_left
    lw t1, 0(t0)     # Posición Y de la paleta
    addi t2, t1, 8   # Altura de la paleta (8 píxeles)
    
    # Verificar si golpea la paleta
    blt s1, t1, reset_ball  # Si está arriba de la paleta
    bgt s1, t2, reset_ball  # Si está abajo de la paleta
    
    # Si golpea, invertir dirección X
    la t0, dx
    li t1, 1         # Movimiento hacia derecha
    sw t1, 0(t0)
    j update_display

check_right_paddle:
    la t0, paddle_right
    lw t1, 0(t0)     # Posición Y de la paleta
    addi t2, t1, 8   # Altura de la paleta
    
    # Verificar si golpea la paleta
    blt s1, t1, reset_ball
    bgt s1, t2, reset_ball
    
    # Si golpea, invertir dirección X
    la t0, dx
    li t1, -1        # Movimiento hacia izquierda
    sw t1, 0(t0)
    j update_display

reset_ball:
    # Reiniciar posición de la pelota
    li s0, 27
    li s1, 27
    
    # Invertir dirección X (alterna entre izquierda/derecha)
    la t0, dx
    lw t1, 0(t0)
    neg t1, t1
    sw t1, 0(t0)
    j update_display

# ===== FUNCIONES DE DIBUJO =====
draw_ball:
    addi sp, sp, -12
    sw ra, 0(sp)
    sw a0, 4(sp)
    sw a1, 8(sp)
    
    mv a0, s0        # Posición X
    mv a1, s1        # Posición Y
    mv a2, s2        # Color
    call pixel
    
    lw ra, 0(sp)
    lw a0, 4(sp)
    lw a1, 8(sp)
    addi sp, sp, 12
    ret

draw_paddles:
    addi sp, sp, -4
    sw ra, 0(sp)
    
    # Paleta izquierda (X=1)
    la t0, paddle_left
    lw a1, 0(t0)
    li a0, 1
    mv a2, s3
    call draw_vertical_paddle
    
    # Paleta derecha (X=53)
    la t0, paddle_right
    lw a1, 0(t0)
    li a0, 53
    mv a2, s3
    call draw_vertical_paddle
    
    lw ra, 0(sp)
    addi sp, sp, 4
    ret

draw_vertical_paddle:
    addi sp, sp, -16
    sw ra, 0(sp)
    sw a0, 4(sp)
    sw a1, 8(sp)
    sw a2, 12(sp)
    
    mv t3, a1        # Y inicial
    addi t4, a1, 8   # Y final (8 píxeles de altura)
    
draw_paddle_loop:
    mv a1, t3
    call pixel
    addi t3, t3, 1
    blt t3, t4, draw_paddle_loop
    
    lw ra, 0(sp)
    lw a0, 4(sp)
    lw a1, 8(sp)
    lw a2, 12(sp)
    addi sp, sp, 16
    ret

pixel:

    # a0=x, a1=y, a2=color
    li t0, 55
    mul t0, t0, a1
    add t0, t0, a0
    li t1, 4
    mul t0, t0, t1
    li t1, 0x0000010
    add t0, t0, t1
    sw a2, 0(t0)
    ret
# FUNCIONES DE MOVIMIENTO DEL D-PAD
move_left_up:
    la t0, paddle_left
    lw t1, 0(t0)
    beqz t1, return_from_move
    addi t1, t1, -1
    sw t1, 0(t0)
    call draw_paddles
    j game_loop

move_left_down:
    la t0, paddle_left
    lw t1, 0(t0)
    li t2, 47
    bge t1, t2, return_from_move
    addi t1, t1, 1
    sw t1, 0(t0)
    call draw_paddles
    j game_loop

move_right_up:
    la t0, paddle_right
    lw t1, 0(t0)
    beqz t1, return_from_move
    addi t1, t1, -1
    sw t1, 0(t0)
    call draw_paddles
    j game_loop

move_right_down:
    la t0, paddle_right
    lw t1, 0(t0)
    li t2, 47
    bge t1, t2, return_from_move
    addi t1, t1, 1
    sw t1, 0(t0)
    call draw_paddles
    j game_loop

return_from_move:
    j game_loop
    
bnez t1, move_left_up
li a0, 20
call delay_ms

delay_ms:
    # a0 = milisegundos
    li t0, 1      # Ajuste interno para el retardo
delay_loop:
    mul t1, a0, t0
    addi t1, t1, -1
    bnez t1, delay_loop
    ret
    
 