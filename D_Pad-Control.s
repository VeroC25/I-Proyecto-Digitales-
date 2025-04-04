#Tecnológico de Costa Rica - Ingeniería Electrónica
#Veronica Cambronero, Pablo Elizondo y Marycruz Fallas.
#Proyecto I. Diseño de Sistemas Digitales.

#-----------------------------------------------------
#                      PONG GAME
#-----------------------------------------------------

    .data
LED_MATRIX_BASE: .word 0xf0000000
MATRIX_WIDTH:    .word 0x37    # Matrix width
MATRIX_HEIGHT:   .word 0x37    # Matrix height
    
D_PAD_BASE:  .word 0xf0002f44
D_PAD_UP:    .word 0xf0002f44  # UP button address
D_PAD_DOWN:  .word 0xf0002f48  # DOWN button address
D_PAD_LEFT:  .word 0xf0002f4c  # LEFT button address
D_PAD_RIGHT: .word 0xf0002f50  # RIGHT button address

    .text
    .globl _start
    
    _start:
    loop:
        # UP button reading:
            li t0, 0xf0002f44
            lw t1, 0(t0)
            bnez t1, move_up1
            
        # DOWN button reading:
            li t0, 0xf0002f44
            lw t1, 4(t0)
            bnez t1, move_down2
            
        # LEFT button reading:
            li t0, 0xf0002f44
            lw t1, 8(t0)
            bnez t1, move_down1
            
        # RIGHT button reading:
            li t0, 0xf0002f44
            lw t1, 12(t0)
            bnez t1, move_up2
            
    j loop
    
    move_up1:
    j loop
        
    move_up2:
    j loop
            
    move_down1:
    j loop
                
    move_down2:  
    j loop
