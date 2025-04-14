.data
# Formato: x1, y1, x2, y2, color
lineas: .word 0, 0, 0, 7, 0xff00ff      # Línea en columna 0 (rojo)
         .word 54, 0, 54, 7, 0x00ff00   # Línea en columna 54 (verde)

.text

la s0, lineas     # Dirección de los datos
li s3, 2          # Cantidad de líneas

bucle:
    lw a0, 0(s0)   # x1
    lw a1, 4(s0)   # y1
    lw a3, 8(s0)   # x2
    lw a4, 12(s0)  # y2
    lw a2, 16(s0)  # color

    call linea

    addi s3, s3, -1
    addi s0, s0, 20
    bnez s3, bucle

li a7, 10
ecall

# === SUBRUTINAS ===

linea: # a0, a1 -> x1, y1 ; a3, a4 -> x2, y2 ; a2 -> color
    addi sp, sp, -16
    sw ra, 0(sp)
    sw a0, 4(sp)
    sw a1, 8(sp)

    beq a1, a4, lhoriz
    beq a0, a3, lvert
    j fin

lhoriz:
    call pixel
    addi a0, a0, 1
    ble a0, a3, lhoriz
    j fin

lvert:
    call pixel
    addi a1, a1, 1
    ble a1, a4, lvert
    j fin

fin:
    lw ra, 0(sp)
    lw a0, 4(sp)
    lw a1, 8(sp)
    addi sp, sp, 16
    ret

pixel: # a0: x, a1: y, a2: color
    li t0, LED_MATRIX_0_WIDTH
    mul t0, t0, a1
    add t0, t0, a0
    li t1, 4
    mul t0, t0, t1
    li t1, LED_MATRIX_0_BASE
    add t0, t0, t1
    sw a2, 0(t0)
    ret
