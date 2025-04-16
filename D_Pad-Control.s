#Tecnológico de Costa Rica - Ingeniería Electrónica
#Veronica Cambronero, Pablo Elizondo y Marycruz Fallas.
#Proyecto I. Diseño de Sistemas Digitales.

#-----------------------------------------------------
#                      PONG GAME
#-----------------------------------------------------

    .data
LED_MATRIX_BASE: .word 0xf0000000
MATRIX_WIDTH:    .word 0x37    # Matrix width (d'55)
MATRIX_HEIGHT:   .word 0x37    # Matrix height (d'55)
    
D_PAD_BASE:  .word 0xf0002f44
D_PAD_UP:    .word 0xf0002f44  # UP button address
D_PAD_DOWN:  .word 0xf0002f48  # DOWN button address
D_PAD_LEFT:  .word 0xf0002f4c  # LEFT button address
D_PAD_RIGHT: .word 0xf0002f50  # RIGHT button address

P1_Y: .word 0x0     # Right Paddle (original reference)
P1_X: .word 0x0     # Right Paddle (original reference)
P2_Y: .word 0x33    # Left Paddle (original reference)
P2_X: .word 0x36    # Left Paddle (original reference)

    .text
    .globl _start
    
    _start:
    loop:
        # UP button reading:
            li t0, 0xf0002f44
            lw t1, 0(t0)
            bnez t1, move_up1
            
        # DOWN button reading:
            li t0, 0xf0002f48
            lw t1, 0(t0)
            bnez t1, move_down2
            
        # LEFT button reading:
            li t0, 0xf0002f4c
            lw t1, 0(t0)
            bnez t1, move_down1
            
        # RIGHT button reading:
            li t0, 0xf0002f50
            lw t1, 0(t0)
            bnez t1, move_up2
            
    j loop
    
    move_up1:
        la t0, P1_Y 
        lw t1, 0(t0) 
        li t2, 0x0 
        beq t1, t2, loop
        
        addi t1, t1, -1
        sw t1, 0(t0)
    j loop
        
    move_up2:
        la t0, P2_Y 
        lw t1, 0(t0) 
        li t2, 0x0 
        beq t1, t2, loop 
        
        addi t1, t1, -1
        sw t1, 0(t0)
    j loop
            
    move_down1:
        la t0, P1_Y 
        lw t1, 0(t0) 
        li t2, 0x33 
        beq t1, t2, loop 
        
        addi t1, t1, 1
        sw t1, 0(t0)
    j loop
                
    move_down2:
        la t0, P2_Y 
        lw t1, 0(t0) 
        li t2, 0x33 
        beq t1, t2, loop 
        
        addi t1, t1, 1
        sw t1, 0(t0)  
    j loop
