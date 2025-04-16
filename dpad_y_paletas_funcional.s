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
