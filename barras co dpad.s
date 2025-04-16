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

.text
.globl _start

_start:
loop:
    # Leer botón UP
    li t0, 0xf0002f44
    lw t1, 0(t0)
    bnez t1, move_up1

    # Leer botón DOWN
    lw t1, 4(t0)
    bnez t1, move_down2

    # Leer botón LEFT
    lw t1, 8(t0)
    bnez t1, move_down1

    # Leer botón RIGHT
    lw t1, 12(t0)
    bnez t1, move_up2

    # Dibujar paletas
    jal draw_p1
    jal draw_p2

    j loop

# ==== LÓGICA DE MOVIMIENTO ====

move_up1:
    la t0, P1_Y
    lw t1, 0(t0)
    li t2, 0
    beq t1, t2, loop
    addi t1, t1, -1
    sw t1, 0(t0)
    j loop

move_down1:
    la t0, P1_Y
    lw t1, 0(t0)
    li t2, 0x30    # límite inferior para 5 LEDs
    beq t1, t2, loop
    addi t1, t1, 1
    sw t1, 0(t0)
    j loop

move_up2:
    la t0, P2_Y
    lw t1, 0(t0)
    li t2, 0
    beq t1, t2, loop
    addi t1, t1, -1
    sw t1, 0(t0)
    j loop

move_down2:
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
    add t0, t0, t3            # t0 = dirección final
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
    add t0, t0, t3            # t0 = dirección final
    sw t5, 0(t0)              # pintar azul

    addi t2, t2, 1            # y++
    addi t6, t6, 1            # i++
    li t0, 5
    blt t6, t0, draw_p2_loop
    ret
