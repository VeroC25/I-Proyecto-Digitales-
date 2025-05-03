
#Tecnológico de Costa Rica - Ingeniería Electrónica
#Veronica Cambronero, Pablo Elizondo y Marycruz Fallas.
#Proyecto I. Diseño de Sistemas Digitales.

#-----------------------------------------------------
#                      PONG GAME
#-----------------------------------------------------


.data
LED_MATRIX_BASE: .word 0xf0000000
MATRIX_WIDTH:    .word 0x37        #d'55
MATRIX_HEIGHT:   .word 0x37        #d'55

D_PAD_BASE:  .word 0xf0002f44
D_PAD_UP:    .word 0xf0002f44
D_PAD_DOWN:  .word 0xf0002f48
D_PAD_LEFT:  .word 0xf0002f4c
D_PAD_RIGHT: .word 0xf0002f50

P1_Y: .word 0x0
P1_X: .word 0x0       
P2_Y: .word 0x32 
P2_X: .word 0x36      

BALL_X:     .word 0x1A  
BALL_Y:     .word 0x1A  
BALL_DX:    .word 0x1 
BALL_DY:    .word 0x1
BALL_OLD_X: .word 0x1A
BALL_OLD_Y: .word 0x1A



.text
.globl _start

  call limpia       # Llama a la rutina para limpiar la pantalla
  jal welcome_column  # Muestra columna inicial de bienvenida


# Subrutina para limpiar la pantalla (pintarla de blanco)
limpia:
  li t1, LED_MATRIX_0_BASE     # Dirección base de la matriz de LEDs
  li t2, LED_MATRIX_0_SIZE     # Tamaño total de la matriz en bytes
  add t2, t2, t1               # Calcula dirección final
  li t3, 0xffffff              # Color blanco

blimpia:
  sw t3, 0(t1)                 # Escribe color blanco en la dirección actual
  addi t1, t1, 4               # Avanza al siguiente píxel (4 bytes por píxel)
  bne t1, t2, blimpia          # Repite hasta llegar al final
                         # Retorna al llamador

_start:
    jal welcome_column
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

    # Dibujar paletas
        jal draw_p1
        jal draw_p2
    
    #bolita
        jal move_ball  
        jal clear_ball   
        jal check_collision
        jal draw_ball

    j loop

# ==== WELCOME SECTION ====
welcome_column:
    li t0, 0xf0000000 
    li t1, 0           
    li t2, 55      
    li t3, 27

welcome_column_loop:
    li t4, 55
    mul t5, t1, t4     
    add t5, t5, t3    
    slli t5, t5, 2   
    add t6, t0, t5   
    li t4, 0xff0000  
    sw t4, 0(t6)      

    addi t1, t1, 1  
    blt t1, t2, welcome_column_loop

    j delete_welcome
    
delete_welcome:
    li t0, 0xf0000000 
    li t1, 0          
    li t2, 55       
    
delete_welcome_loop:
    li t4, 55
    mul t5, t1, t4    
    add t5, t5, t3   
    slli t5, t5, 2    
    add t6, t0, t5 
    li t4,  0xffffff  
    sw t4, 0(t6)  

    addi t1, t1, 1  
    blt t1, t2, delete_welcome_loop
    ret

# ==== MOVEMENT SECTION ====
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
    li t2, 0x32
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
    li t2, 0x32
    beq t1, t2, loop
    addi t1, t1, 1
    sw t1, 0(t0)
    j loop

# ==== DRAWING SECTION ====
draw_p1:
    li t3, 0xf0000000 
    li t4, 0x37            
    li t5, 0xff00ff  
    li t6, 0           

    la t0, P1_X
    lw t1, 0(t0) 
    la t0, P1_Y
    lw t2, 0(t0)      

draw_p1_loop:
    mul t0, t2, t4    
    add t0, t0, t1       
    slli t0, t0, 2    
    add t0, t0, t3    
    sw t5, 0(t0)          

    addi t2, t2, 1     
    addi t6, t6, 1        
    li t0, 5
    blt t6, t0, draw_p1_loop
    ret
draw_p2:
    li t3, 0xf0000000     
    li t4, 0x37          
    li t5, 0x00ff00     
    li t6, 0                  # t6 = counter i = 0

    la t0, P2_X
    lw t1, 0(t0)              # t1 = X
    la t0, P2_Y
    lw t2, 0(t0)              # t2 = Y

draw_p2_loop:
    mul t0, t2, t4            # t0 = y * width
    add t0, t0, t1            # t0 = y * width + x
    slli t0, t0, 2       
    add t0, t0, t3       
    sw t5, 0(t0)         

    addi t2, t2, 1            # y++
    addi t6, t6, 1            # i++
    li t0, 5
    blt t6, t0, draw_p2_loop
    ret

clear_p1:
    li t3, 0xf0000000    
    li t4, 0x37       
    li t5, 0xffffff      
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
    li t5,  0xffffff
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
    
draw_ball:
    # t3 = base matriz
    li t3, 0xf0000000
    li t4, 0x37           
    li t5, 0x800080      

    la t0, BALL_X
    lw t1, 0(t0)        
    la t0, BALL_Y
    lw t2, 0(t0)        

    mul t0, t2, t4      
    add t0, t0, t1        
    slli t0, t0, 2       
    add t0, t0, t3       

    sw t5, 0(t0)          
    ret

move_ball:
    la t0, BALL_X
    lw t1, 0(t0)
    la t2, BALL_OLD_X
    sw t1, 0(t2)

    la t0, BALL_Y
    lw t1, 0(t0)
    la t2, BALL_OLD_Y
    sw t1, 0(t2)

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
    li t3, 0xf0000000 
    li t4, 0x37        
    li t5,  0xffffff  

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

# ==== COLLISIONS SECTION ====
check_collision:
    la t0, BALL_X
    lw t1, 0(t0)      # t1 = BALL_X
    la t0, BALL_Y
    lw t2, 0(t0)      # t2 = BALL_Y

    li t3, 0
    beq t2, t3, invert_dy_2 
    li t3, 54
    beq t2, t3, invert_dy_2  

    la t0, P2_X
    lw t3, 0(t0)                # t3 = P2_X (54)
    la t0, BALL_DX
    lw t4, 0(t0)                # t4: BALL direction
    blez t4, check_left_paddle  

    addi t5, t3, -1
    bne t1, t5, check_left_paddle  


    la t0, P2_Y
    lw t3, 0(t0)                # t3 = P2_Y
    addi t4, t3, 4              # t4 = P2_Y + 4

    blt t2, t3, check_left_paddle  
    bgt t2, t4, check_left_paddle  

    j invert_dx 
    ret
    
check_left_paddle:
    la t0, P1_X
    lw t3, 0(t0)                # t3 = P1_X (0)
    la t0, BALL_DX
    lw t4, 0(t0)                # t4: BALL direction
    bgez t4, end_collision 

    addi t5, t3, 1
    bne t1, t5, end_collision 

    la t0, P1_Y
    lw t3, 0(t0)                # t3 = P1_Y
    addi t4, t3, 4              # t4 = P1_Y + 4 

    blt t2, t3, end_collision  
    bgt t2, t4, end_collision 

    j invert_dx         

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