################# CSC258 Assembly Final Project ###################
# This file contains our implementation of Dr Mario.
#
# Student 1: Felix Gao, 1009810689
#
# We assert that the code submitted here is entirely our own 
# creation, and will indicate otherwise when it is not.
#
######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       2
# - Unit height in pixels:      2
# - Display width in pixels:    64
# - Display height in pixels:   64
# - Base Address for Display:   0x10008000 ($gp)
##############################################################################
.data
.align 4
Width:
    .word 19
Height:
    .word 25
##############################################################################
# Immutable Data
##############################################################################
# The address of the bitmap display. Don't forget to connect it!
ADDR_DSPL:
    .word 0x10008000
# The address of the keyboard. Don't forget to connect it!
ADDR_KBRD:
    .word 0xffff0000
state: 
	.word 1
s2_change:
    .word 0
s3_change:
    .word 0
cancel_vertically:
    .word 0
is_dropped:
    .word 0
gravity_enable:
    .word 0
current_speed:
    .word 1000
initial_time:
    .word 0
is_paused:
    .word 0
display_buffer:
    .space 4096
pause_buffer:
    .word 4096
virus_count:
    .word 3
speed_increase_time:
    .word 5000
next_capsule:
    .space 40


##############################################################################
# Mutable Data
##############################################################################

##############################################################################
# Code
##############################################################################
	.text
	.globl main

    # Run the game.
main:
    jal get_current_time
    sw $a0, initial_time
    
    li $t0, 1000
    sw $t0, current_speed
    
    waiting_for_mode_key:
    lw $t0, ADDR_KBRD               # $t0 = base address for keyboard
    lw $t8, 0($t0)                  # Load first word from keyboard
    beq $t8, 1, check_which_mode
    b waiting_for_mode_key

    check_which_mode:                   # A key is pressed
    lw $a0, 4($t0)                  # Load second word from keyboard
    beq $a0, 0x65, easy_mode
    beq $a0, 0x6D, medium_mode
    beq $a0, 0x68, hard_mode
    b main
	
	easy_mode:
	li $t0, 3
	sw $t0, virus_count
	li $t0, 1000
	sw $t0, current_speed
	j draw_background
	
	medium_mode:
	li $t0, 6
	sw $t0, virus_count
	li $t0, 800
	sw $t0, current_speed
	j draw_background
	
	hard_mode:
	li $t0, 9
	sw $t0, virus_count
	li $t0, 400
	sw $t0, current_speed
	j draw_background
	
	
    draw_background:
    lw $t0, ADDR_DSPL
	# Draw a rectangle
	li $t4, 0x00808080	# load the color of the background
	addi $a0, $zero, 2   # set the X coordinate for this line
	addi $a1, $zero, 5	  # set the Y coordinate for this line
	addi $a2, $zero, 19   # initialize $t6 to the final value for the loop variable.
	addi $a3, $zero, 25   # initialize $t6 to the final value for the loop variable.
	jal draw_rect         # call the rectangle drawing function

	# Fill the interior with black color
	li $t4, 0x00000000	# load the color of the background
	addi $a0, $zero, 3   # set the X coordinate for this line
	addi $a1, $zero, 6	  # set the Y coordinate for this line
	addi $a2, $zero, 17   # initialize $t6 to the final value for the loop variable.
	addi $a3, $zero, 23   # initialize $t6 to the final value for the loop variable.
	jal draw_rect         # call the rectangle drawing function

	# Draw the bottle neck
	li $t4, 0x00808080	# load the color of the background
	addi $a0, $zero, 9   # set the X coordinate for this line
	addi $a1, $zero, 3	  # set the Y coordinate for this line
	addi $a2, $zero, 5   # initialize $t6 to the final value for the loop variable.
	addi $a3, $zero, 2   # initialize $t6 to the final value for the loop variable.
	jal draw_rect         # call the rectangle drawing function

	# Fill the opener black
	li $t4, 0x00000000	# load the color of the background
	addi $a0, $zero, 10   # set the X coordinate for this line
	addi $a1, $zero, 3	  # set the Y coordinate for this line
	addi $a2, $zero, 3   # initialize $t6 to the final value for the loop variable.
	addi $a3, $zero, 3   # initialize $t6 to the final value for the loop variable.
	jal draw_rect         # call the rectangle drawing function
	
	jal store_next_capsule
	j draw_virus
	
	store_next_capsule:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal generate_new_capsule
	la $t0, next_capsule
	sw $a0, 0($t0)
	sw $a1, 4($t0)
	jal generate_new_capsule
	addi $t0, $t0, 8
	sw $a0, 0($t0)
	sw $a1, 4($t0)
	jal generate_new_capsule
	addi $t0, $t0, 8
	sw $a0, 0($t0)
	sw $a1, 4($t0)
	jal generate_new_capsule
	addi $t0, $t0, 8
	sw $a0, 0($t0)
	sw $a1, 4($t0)
	jal generate_new_capsule
	addi $t0, $t0, 8
	sw $a0, 0($t0)
	sw $a1, 4($t0)
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
	draw_virus:
	# draw 3 virus
	li $t4, 0
	lw $t5, virus_count
	
	draw_virus_while_start:
	lw $t3, ADDR_DSPL
	jal get_random_color
	move $t0, $a0
	addi $sp, $sp, -4
	sw $t0, 0($sp)
	jal get_random_position
	lw $t0, 0($sp)
	addi $sp, $sp, 4
	move $t1, $a0
	add $t3, $t3, $t1
	sw $t0, 0($t3)
	
	addi $t4, $t4, 1
	beq $t4, $t5, draw_virus_while_end
	j draw_virus_while_start
    draw_virus_while_end:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    jal load_next_capsule
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    j game_loop
    
    load_next_capsule:
    li $t0, 1
    sw $t0, state
    la $t1, next_capsule
    lw $t0, ADDR_DSPL
	addi $t0, $t0, 428
	move $s2, $t0
	lw $a0, 0($t1)
	move $s0, $a0
	sw $a0, 0($t0)
	addi $t0, $t0, 128
	move $s3, $t0
	lw $a0, 4($t1)
	move $s1, $a0
	sw $a0, 0($t0)
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	j draw_next_capsule_on_side_panel
	after_draw_next_capsule:
	jr $ra

    draw_next_capsule_on_side_panel:
    li $t0, 0
    li $t1, 4
    la $t2, next_capsule
    la $t3, next_capsule
    addi $t3, $t3, 8
    update_preview_while_start:
    lw $t4, 0($t3)
    lw $t5, 4($t3)
    sw $t4, 0($t2)
    sw $t5, 4($t2)
    addi $t2, $t2, 8
    addi $t3, $t3, 8
    addi $t0, $t0, 1
    bne $t0, $t1, update_preview_while_start
    addi $sp, $sp, -4
    sw $t2, 0($sp)
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    jal generate_new_capsule
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    lw $t2, 0($sp)
    addi $sp, $sp, 4
    sw $a0, 0($t2)
    sw $a1, 4($t2)
    
    
    lw $t0, ADDR_DSPL
    addi $t0, $t0, 484
    la $t1, next_capsule
    li $t3, 0
    li $t4, 5
    draw_capsules_while_start:
    lw $t2, 0($t1)
    sw $t2, 0($t0)
    addi $t0, $t0, 128
    lw $t2, 4($t1)
    sw $t2, 0($t0)
    addi $t0, $t0, 384
    addi $t1, $t1, 8
    addi $t3, $t3, 1
    bne $t3, $t4, draw_capsules_while_start
    j after_draw_next_capsule

	# Draw the first two-halved capsule
    generate_new_capsule:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
	jal get_random_color
	move $t8, $a0
	jal get_random_color
	move $a1, $t8
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

	
check_entrance_blocked:
    lw $t1, ADDR_DSPL
    addi $t1, $t1, 512
    blt $s2, $t1, block_entrance
    blt $s3, $t1, block_entrance
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    jal load_next_capsule
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    j game_loop

block_entrance:
    jal draw_game_over
    li $v0, 10                      # Quit gracefully
	syscall

draw_game_over:
    lw $t0, ADDR_DSPL   
    addi $sp, $sp, -4
	sw $ra, 0($sp)
    jal empty_screen
    
    li $t4, 0xFFFFFFFF
    li $a0, 0
    li $a1, 2
    li $a2, 5
    li $a3, 5
    jal draw_rect
    
    li $t4, 0x00000000
    li $a0, 1
    li $a1, 3
    li $a2, 4
    li $a3, 1
    jal draw_rect
    
    li $t4, 0x00000000
    li $a0, 1
    li $a1, 3
    li $a2, 2
    li $a3, 3
    jal draw_rect
    
    
    li $t4, 0xFFFFFFFF
    li $a0, 6
    li $a1, 2
    li $a2, 5
    li $a3, 5
    jal draw_rect
    
    li $t4, 0x00000000
    li $a0, 7
    li $a1, 3
    li $a2, 3
    li $a3, 1
    jal draw_rect
    
    li $t4, 0x00000000
    li $a0, 7
    li $a1, 5
    li $a2, 3
    li $a3, 2
    jal draw_rect
    

    
    li $t4, 0xFFFFFFFF
    li $a0, 12
    li $a1, 2
    li $a2, 5
    li $a3, 5
    jal draw_rect
    
    li $t4, 0x00000000
    li $a0, 13
    li $a1, 3
    li $a2, 1
    li $a3, 5
    jal draw_rect
    
    li $t4, 0x00000000
    li $a0, 15
    li $a1, 3
    li $a2, 1
    li $a3, 5
    jal draw_rect
    
    li $t4, 0xFFFFFFFF
    li $a0, 18
    li $a1, 2
    li $a2, 5
    li $a3, 5
    jal draw_rect
    
    
    li $t4, 0x00000000
    li $a0, 19
    li $a1, 3
    li $a2, 4
    li $a3, 1
    jal draw_rect
    
    li $t4, 0x00000000
    li $a0, 19
    li $a1, 5
    li $a2, 4
    li $a3, 1
    jal draw_rect
    
    li $t4, 0xFFFFFFFF
    li $a0, 0
    li $a1, 10
    li $a2, 5
    li $a3, 5
    jal draw_rect
    
    li $t4, 0x00000000
    li $a0, 1
    li $a1, 11
    li $a2, 3
    li $a3, 3
    jal draw_rect
    
    li $t4, 0xFFFFFFFF
    li $a0, 6
    li $a1, 10
    li $a2, 1
    li $a3, 3
    jal draw_rect
    
    li $t4, 0xFFFFFFFF
    li $a0, 7
    li $a1, 13
    li $a2, 1
    li $a3, 1
    jal draw_rect
    
    li $t4, 0xFFFFFFFF
    li $a0, 8
    li $a1, 14
    li $a2, 1
    li $a3, 1
    jal draw_rect
    
    li $t4, 0xFFFFFFFF
    li $a0, 9
    li $a1, 13
    li $a2, 1
    li $a3, 1
    jal draw_rect
    
    li $t4, 0xFFFFFFFF
    li $a0, 10
    li $a1, 10
    li $a2, 1
    li $a3, 3
    jal draw_rect
    
    li $t4, 0xFFFFFFFF
    li $a0, 12
    li $a1, 10
    li $a2, 5
    li $a3, 5
    jal draw_rect
    
    li $t4, 0x00000000
    li $a0, 13
    li $a1, 11
    li $a2, 4
    li $a3, 1
    jal draw_rect
    
    li $t4, 0x00000000
    li $a0, 13
    li $a1, 13
    li $a2, 4
    li $a3, 1
    jal draw_rect
    
    li $t4, 0xFFFFFFFF
    li $a0, 18
    li $a1, 10
    li $a2, 5
    li $a3, 5
    jal draw_rect
    
    li $t4, 0x00000000
    li $a0, 19
    li $a1, 11
    li $a2, 3
    li $a3, 1
    jal draw_rect
    
    li $t4, 0x00000000
    li $a0, 19
    li $a1, 13
    li $a2, 4
    li $a3, 2
    jal draw_rect
    
    li $t4, 0xFFFFFFFF
    li $a0, 20
    li $a1, 13
    li $a2, 1
    li $a3, 1
    jal draw_rect
    
    li $t4, 0xFFFFFFFF
    li $a0, 20
    li $a1, 13
    li $a2, 2
    li $a3, 1
    jal draw_rect
    
    li $t4, 0xFFFFFFFF
    li $a0, 21
    li $a1, 14
    li $a2, 2
    li $a3, 1
    jal draw_rect
    
    lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	j waiting_for_retry

    waiting_for_retry:
    lw $t0, ADDR_KBRD               # $t0 = base address for keyboard
    lw $t8, 0($t0)                  # Load first word from keyboard
    beq $t8, 1, check_if_r          # If first word 1, key is pressed
    b waiting_for_retry

    check_if_r:                     # A key is pressed
    lw $a0, 4($t0)                  # Load second word from keyboard
    beq $a0, 0x72, restart_game     # Check if the key
    li $v0, 10                      # Quit gracefully
	syscall
    
    restart_game:
    lw $t0, ADDR_DSPL  
    jal empty_screen
    j main
    
    
empty_screen:
    li $t4, 0x00000000	# load the color of the background
	addi $a0, $zero, 0   # set the X coordinate for this line
	addi $a1, $zero, 0	  # set the Y coordinate for this line
	addi $a2, $zero, 64   # initialize $t6 to the final value for the loop variable.
	addi $a3, $zero, 64   # initialize $t6 to the final value for the loop variable.
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal draw_rect 
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

game_loop:
    # 1a. Check if key has been pressed
    jal get_current_time
    lw $t0, initial_time
    subu $a0, $a0, $t0
    lw $t1, speed_increase_time
    bgeu $a0, $t1, increase_speed
    j time_initialization
    
    
	increase_speed:
	lw $t1, current_speed
    addi $t1, $t1, -50
    bltu $t1, 100, change_current_speed_to_100
    after_change_current_speed_to_min:
    sw $t1, current_speed
    lw $t1, speed_increase_time
    addi $t1, $t1, 5000
    sw $t1, speed_increase_time
    j time_initialization
    
    change_current_speed_to_100:
    li $t1, 100
    sw $t1, current_speed
    j after_change_current_speed_to_min
    
    time_initialization:
    beq $s6, $zero, initialize_s6
    beq $s7, $zero, initialize_s7
    check_time_difference:
    subu $t0, $s7, $s6
    lw $t1, current_speed
    bgeu $t0, $t1, set_gravity_enable
    j check_user_input
    
    initialize_s6:
    jal get_current_time
    move $s6, $a0
    j check_user_input
    
    initialize_s7:
    jal get_current_time
    move $s7, $a0
    j check_time_difference
    
    get_current_time:
    li 	$v0, 30
	syscall
	jr $ra
	
	set_gravity_enable:
	li $t1, 1
	sw $t1, gravity_enable
    j check_user_input
	
	
    check_user_input:
    lw $t1, ADDR_KBRD               # $t0 = base address for keyboard
    lw $t8, 0($t1)                  # Load first word from keyboard
    bne $t8, 1, check_if_is_paused     # If first word 1, key is pressed
    j keyboard_input
    check_if_is_paused:
    lw $t0, is_paused
    li $t2, 1
    beq $t0, $t2, check_user_input
    j gravity_handling
    gravity_handling:
    lw $t2, gravity_enable
    beq $t2, 1, apply_gravity
    j initialize_s7


    # 1b. Check which key has been pressed
	keyboard_input:                 # A key is pressed
    lw $a0, 4($t1)                  # Load second word from keyboard
	move $s4, $s2					# save $s2 to $s4 for collision
	move $s5, $s3					# save $s3 to $s5 for collision
	j responses_to_keys
	
	apply_gravity:
	move $s6, $s7
    move $s7, $zero
    lw $t2, gravity_enable
    sw $zero, gravity_enable
    li $a0, 0x73
    
    responses_to_keys:
    li $t4, 0x00000000
    lw $t0, is_paused
    li $t1, 1
    bne $t0, $t1, check_for_keys_normal
    check_if_Q_is_pressed:
	beq $a0, 0x70, respond_to_P     # Check if the key q was pressed
	j check_user_input
	
	check_for_keys_normal:
    beq $a0, 0x77, respond_to_W     # Check if the key w was pressed
	beq $a0, 0x73, respond_to_S     # Check if the key s was pressed
	beq $a0, 0x61, respond_to_A     # Check if the key a was pressed
	beq $a0, 0x64, respond_to_D     # Check if the key d was pressed
	beq $a0, 0x71, respond_to_Q     # Check if the key q was pressed
	beq $a0, 0x70, respond_to_P     # Check if user wants to pause the game
	jr $ra

    li $v0, 1                       # ask system to print $a0
    syscall
    b game_loop
    
    respond_to_P:
    lw $t0, is_paused
    xori $t0, $t0, 1
    sw $t0, is_paused
    li $t1, 1
    beq $t0, $t1, pause
    j resume_game
    
    pause:
    li $t0, 1
    sw $t0, is_paused
    jal display_pause
    j check_user_input
    
    
    display_pause:
    lw $t0, ADDR_DSPL
    la $t1, display_buffer
    li $t2, 0
    save_loop_start:
    lw $t3, 0($t0)
    sw $t3, 0($t1)
    addi $t0, $t0, 4
    addi $t1, $t1, 4
    addi $t2, $t2, 1
    bne $t2, 4096, save_loop_start
    save_loop_end:
    move $a0, $zero
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    jal draw_pause_message_on_screen
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
    
    draw_pause_message_on_screen:
    lw $t0, ADDR_DSPL
	li $t4, 0x00000000	# load the color of the background

	# Draw Pause
	addi $a0, $zero, 0   # set the X coordinate for this line
	addi $a1, $zero, 0	  # set the Y coordinate for this line
	addi $a2, $zero, 64   # initialize $t6 to the final value for the loop variable.
	addi $a3, $zero, 64   # initialize $t6 to the final value for the loop variable.
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal draw_rect         # call the rectangle drawing function
	li $t4, 0xFFFFFFFF	# load the color of the background
	addi $a0, $zero, 0   # set the X coordinate for this line
	addi $a1, $zero, 5	  # set the Y coordinate for this line
	addi $a2, $zero, 5   # initialize $t6 to the final value for the loop variable.
	addi $a3, $zero, 5   # initialize $t6 to the final value for the loop variable.
	jal draw_rect
	addi $a0, $zero, 0   # set the X coordinate for this line
	addi $a1, $zero, 5	  # set the Y coordinate for this line
	addi $a2, $zero, 1   # initialize $t6 to the final value for the loop variable.
	addi $a3, $zero, 10   # initialize $t6 to the final value for the loop variable.
	jal draw_rect
	
	li $t4, 0x00000000	# load the color of the background
	addi $a0, $zero, 1   # set the X coordinate for this line
	addi $a1, $zero, 6	  # set the Y coordinate for this line
	addi $a2, $zero, 3   # initialize $t6 to the final value for the loop variable.
	addi $a3, $zero, 3   # initialize $t6 to the final value for the loop variable.
	jal draw_rect
	
	li $t4, 0xFFFFFFFF	# load the color of the background
	addi $a0, $zero, 6   # set the X coordinate for this line
	addi $a1, $zero, 5	  # set the Y coordinate for this line
	addi $a2, $zero, 6   # initialize $t6 to the final value for the loop variable.
	addi $a3, $zero, 10   # initialize $t6 to the final value for the loop variable.
	jal draw_rect
	
	li $t4, 0x00000000	# load the color of the background
	addi $a0, $zero, 7   # set the X coordinate for this line
	addi $a1, $zero, 6	  # set the Y coordinate for this line
	addi $a2, $zero, 4   # initialize $t6 to the final value for the loop variable.
	addi $a3, $zero, 3   # initialize $t6 to the final value for the loop variable.
	jal draw_rect
	
	addi $a0, $zero, 7   # set the X coordinate for this line
	addi $a1, $zero, 10	  # set the Y coordinate for this line
	addi $a2, $zero, 4   # initialize $t6 to the final value for the loop variable.
	addi $a3, $zero, 5   # initialize $t6 to the final value for the loop variable.
	jal draw_rect
	
	li $t4, 0xFFFFFFFF	# load the color of the background
	addi $a0, $zero, 13   # set the X coordinate for this line
	addi $a1, $zero, 5	  # set the Y coordinate for this line
	addi $a2, $zero, 6   # initialize $t6 to the final value for the loop variable.
	addi $a3, $zero, 10   # initialize $t6 to the final value for the loop variable.
	jal draw_rect
	
	li $t4, 0x00000000	# load the color of the background
	addi $a0, $zero, 14   # set the X coordinate for this line
	addi $a1, $zero, 5	  # set the Y coordinate for this line
	addi $a2, $zero, 4   # initialize $t6 to the final value for the loop variable.
	addi $a3, $zero, 9   # initialize $t6 to the final value for the loop variable.
	jal draw_rect
	
	li $t4, 0xFFFFFFFF	# load the color of the background
	addi $a0, $zero, 20   # set the X coordinate for this line
	addi $a1, $zero, 5	  # set the Y coordinate for this line
	addi $a2, $zero, 6   # initialize $t6 to the final value for the loop variable.
	addi $a3, $zero, 10   # initialize $t6 to the final value for the loop variable.
	jal draw_rect
	
	li $t4, 0x00000000	# load the color of the background
	addi $a0, $zero, 21   # set the X coordinate for this line
	addi $a1, $zero, 6	  # set the Y coordinate for this line
	addi $a2, $zero, 5   # initialize $t6 to the final value for the loop variable.
	addi $a3, $zero, 3   # initialize $t6 to the final value for the loop variable.
	jal draw_rect
	
	li $t4, 0x00000000	# load the color of the background
	addi $a0, $zero, 20   # set the X coordinate for this line
	addi $a1, $zero, 10	  # set the Y coordinate for this line
	addi $a2, $zero, 5   # initialize $t6 to the final value for the loop variable.
	addi $a3, $zero, 4   # initialize $t6 to the final value for the loop variable.
	jal draw_rect
	
	li $t4, 0xFFFFFFFF	# load the color of the background
	addi $a0, $zero, 27   # set the X coordinate for this line
	addi $a1, $zero, 5	  # set the Y coordinate for this line
	addi $a2, $zero, 5   # initialize $t6 to the final value for the loop variable.
	addi $a3, $zero, 10   # initialize $t6 to the final value for the loop variable.
	jal draw_rect
	
	li $t4, 0x00000000	# load the color of the background
	addi $a0, $zero, 28   # set the X coordinate for this line
	addi $a1, $zero, 6	  # set the Y coordinate for this line
	addi $a2, $zero, 4   # initialize $t6 to the final value for the loop variable.
	addi $a3, $zero, 3   # initialize $t6 to the final value for the loop variable.
	jal draw_rect
	
	li $t4, 0x00000000	# load the color of the background
	addi $a0, $zero, 28   # set the X coordinate for this line
	addi $a1, $zero, 10	  # set the Y coordinate for this line
	addi $a2, $zero, 4   # initialize $t6 to the final value for the loop variable.
	addi $a3, $zero, 4   # initialize $t6 to the final value for the loop variable.
	jal draw_rect
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
    
    
    
    resume_game:
    lw $t0, ADDR_DSPL
    la $t1, display_buffer
    li $t2, 0
    resume_loop_start:
    lw $t3, 0($t1)
    sw $t3, 0($t0)
    addi $t0, $t0, 4
    addi $t1, $t1, 4
    addi $t2, $t2, 1
    bne $t2, 4096, resume_loop_start
    resume_loop_end:
    j check_user_input
    
    

	respond_to_Q:
	li $v0, 10                      # Quit gracefully
	syscall

	respond_to_W:	# rotate
	sub $t5, $s3, $s2				# store the difference of $s3 - $s2 to the register $t5
	li $t6, 128
	beq $t5, $t6, rotate_to_right	# if the difference = 128
	li $t6, -4
	beq $t5, $t6, rotate_to_down	# if the difference = -4
	li $t6, -128
	beq $t5, $t6, rotate_to_left	# if the difference = -128
	li $t6, 4
	beq $t5, $t6, rotate_to_top		# if the difference = 4
	
	respond_to_S:	# drop
	lw $t8, state
	li $t9, 1
	beq $t8, $t9, respond_to_S_Type1
	li $t9, 2
	beq $t8, $t9, respond_to_S_Type2
	li $t9, 3
	beq $t8, $t9, respond_to_S_Type3
	li $t9, 4
	beq $t8, $t9, respond_to_S_Type4

	respond_to_S_Type1:
	# check whether the move is valid
	addi $t3, $s3, 128
	lw $t1, 0($t3)
	bne $t1, $t4, check_landing	
	j respond_to_S_continue

	respond_to_S_Type2:
	addi $t2, $s2, 128
	addi $t3, $s3, 128
	lw $t0, 0($t2)
	lw $t1, 0($t3)
	bne $t0, $t4, check_landing
	bne $t1, $t4, check_landing
	j respond_to_S_continue

	respond_to_S_Type3:
	addi $t2, $s2, 128
	lw $t0, 0($t2)
	bne $t0, $t4, check_landing
	j respond_to_S_continue

	respond_to_S_Type4:
	addi $t2, $s2, 128
	addi $t3, $s3, 128
	lw $t0, 0($t2)
	lw $t1, 0($t3)
	bne $t0, $t4, check_landing
	bne $t1, $t4, check_landing
	j respond_to_S_continue
	

	respond_to_S_continue:
	# if valid
	sw $t4, 0($s2)	# cover previous in black
	sw $t4, 0($s3)	# cover previous in black
	addi $s2, $s2, 128
	addi $s3, $s3, 128
	sw $s0, 0($s2)
	sw $s1, 0($s3)
	j check_for_walls
	
	respond_to_A:	# move left
	lw $t8, state
	li $t9, 1
	beq $t8, $t9, respond_to_A_Type1
	li $t9, 2
	beq $t8, $t9, respond_to_A_Type2
	li $t9, 3
	beq $t8, $t9, respond_to_A_Type3
	li $t9, 4
	beq $t8, $t9, respond_to_A_Type4


	respond_to_A_Type1:
	addi $t2, $s2, -4
	addi $t3, $s3, -4
	lw $t0, 0($t2)
	lw $t1, 0($t3)
	bne $t0, $t4, check_landing
	bne $t1, $t4, check_landing
	j respond_to_A_continue	

	
	respond_to_A_Type2:
	addi $t3, $s3, -4
	lw $t1, 0($t3)
	bne $t1, $t4, check_landing
	j respond_to_A_continue	

	
	respond_to_A_Type3:
	addi $t2, $s2, -4
	addi $t3, $s3, -4
	lw $t0, 0($t2)
	lw $t1, 0($t3)
	bne $t0, $t4, check_landing
	bne $t1, $t4, check_landing
	j respond_to_A_continue	

	
	respond_to_A_Type4:
	addi $t2, $s2, -4
	lw $t0, 0($t2)
	bne $t0, $t4, check_landing
	j respond_to_A_continue	


	respond_to_A_continue:
	# if valid
	sw $t4, 0($s2)	# cover previous in black
	sw $t4, 0($s3)	# cover previous in black
	addi $s2, $s2, -4
	addi $s3, $s3, -4
	sw $s0, 0($s2)
	sw $s1, 0($s3)
	j check_for_walls
	

	respond_to_D:	# move right
	lw $t8, state
	li $t9, 1
	beq $t8, $t9, respond_to_D_Type1
	li $t9, 2
	beq $t8, $t9, respond_to_D_Type2
	li $t9, 3
	beq $t8, $t9, respond_to_D_Type3
	li $t9, 4
	beq $t8, $t9, respond_to_D_Type4


	respond_to_D_Type1:
	addi $t2, $s2, 4
	addi $t3, $s3, 4
	lw $t0, 0($t2)
	lw $t1, 0($t3)
	bne $t0, $t4, check_landing
	bne $t1, $t4, check_landing
	j respond_to_D_continue
	
	respond_to_D_Type2:
	addi $t2, $s2, 4
	lw $t0, 0($t2)
	bne $t0, $t4, check_landing
	j respond_to_D_continue


	respond_to_D_Type3:
	addi $t2, $s2, 4
	addi $t3, $s3, 4
	lw $t0, 0($t2)
	lw $t1, 0($t3)
	bne $t0, $t4, check_landing
	bne $t1, $t4, check_landing
	j respond_to_D_continue
	

	respond_to_D_Type4:
	addi $t3, $s3, 4
	lw $t1, 0($t3)
	bne $t1, $t4, check_landing	
	j respond_to_D_continue


	respond_to_D_continue:
	# if valid
	sw $t4, 0($s2)	# cover previous in black
	sw $t4, 0($s3)	# cover previous in black
	addi $s2, $s2, 4
	addi $s3, $s3, 4
	sw $s0, 0($s2)
	sw $s1, 0($s3)
	j check_for_walls

	rotate_to_right:
	# check whether the move is valid
	addi $t2, $s2, 4
	lw $t0, 0($t2)
	bne $t0, $t4, check_landing

	# if valid
	sw $t4, 0($s2)	# cover previous in black
	sw $t4, 0($s3)	# cover previous in black
	sw $s1, 0($s2)
	add $s3, $s2, $zero
	addi $s2, $s2, 4
	sw $s0, 0($s2)

	# update the state to Type 2
	li $t0, 2
	sw $t0, state
	
	j check_for_walls

	rotate_to_down:
	# check whether the move is valid
	addi $t3, $s3, 128
	lw $t1, 0($t3)
	bne $t1, $t4, check_landing

	# if valid
	sw $t4, 0($s2)	# cover previous in black
	addi $s2, $s3, 128
	sw $s0, 0($s2)

	# update the state to Type 3
	li $t0, 3
	sw $t0, state
	
	j check_for_walls

	rotate_to_left:
	# check whether the move is valid
	addi $t3, $s3, 4
	lw $t1, 0($t3)
	bne $t1, $t4, check_landing

	# if valid
	sw $t4, 0($s2)	# cover previous in black
	sw $t4, 0($s3)	# cover previous in black
	sw $s0, 0($s3)
	move $s2, $s3
	addi $s3, $s2, 4
	sw $s1, 0($s3)

	# update the state to Type 4
	li $t0, 4
	sw $t0, state
	
	j check_for_walls

	rotate_to_top:
	# check whether the move is valid
	addi $t2, $s2, 128
	lw $t0, 0($t2)
	bne $t0, $t4, check_landing
	
	sw $t4, 0($s3)
	addi $s3, $s2, 128
	sw $s1, 0($s3)

	# update the state to Type 1
	li $t0, 1
	sw $t0, state   
    j check_for_walls

	# 2a. Check for collisions
	check_for_walls:
	# jal game_loop
	li $t6, 128
	lw $t8, ADDR_DSPL
	sub $t8, $s2, $t8
	div $t8, $t6
	mflo $t2		# store the row number of first half capsule into $t2
	mfhi $t3		# column number of the first capsule into $t3

	lw $t8, ADDR_DSPL
	sub $t8, $s3, $t8
	div $t8, $t6
	mflo $t4		# store the row number of second half capsule into $t4
	mfhi $t5		# column number of second capsule into $t5

	check_max_row:
	bge $t2, $t4, check_max_row_s2
	bge $t4, $t2, check_max_row_s3
	check_min_col:
	ble $t3, $t5, check_min_col_s2_max_col_s3
	ble $t5, $t3, check_min_col_s3_max_col_s2


	check_max_row_s2:
	li $t7, 28
	beq $t2, $t7, check_landing_continue
	j check_min_col

	check_max_row_s3:
	li $t7, 28
	beq $t4, $t7, check_landing_continue
	j check_min_col

	check_min_col_s2_max_col_s3:
	li $t7, 8
	ble $t3, $t7, restore_move
	li $t7, 80
	beq $t5, $t7, restore_move
	j check_landing
		
	check_min_col_s3_max_col_s2:
	li $t7, 8
	ble $t5, $t7, restore_move
	li $t7, 80
	beq $t3, $t7, restore_move
	j check_landing
	
	restore_move:
	li $t5, 0x00808080	# load the color of the background
	sw $t5, 0($s2)		# restore the wall
	sw $t5, 0($s3)		# restore the wall
	move $s2, $s4
	move $s3, $s5
	sw $s0, 0($s2)	# cover previous in black
	sw $s1, 0($s3)	# cover previous in black
	j game_loop

	check_landing:
	li $t4, 0x00000000
	lw $t8, state
	li $t9, 1
	beq $t8, $t9, check_landing_Type1
	li $t9, 2
	beq $t8, $t9, check_landing_Type2
	li $t9, 3
	beq $t8, $t9, check_landing_Type3
	li $t9, 4
	beq $t8, $t9, check_landing_Type4
	j check_for_walls
    
	check_landing_Type1:
	addi $t0, $s3, 128
	lw $t1, 0($t0)
	bne $t1, $t4, check_landing_continue
	j game_loop
	
	check_landing_Type2:
	addi $t0, $s2, 128
	lw $t1, 0($t0)
	bne $t1, $t4, check_landing_continue
	addi $t0, $s3, 128
	lw $t1, 0($t0)
	bne $t1, $t4, check_landing_continue
	j game_loop
	
	check_landing_Type3:
	addi $t0, $s2, 128
	lw $t1, 0($t0)
	bne $t1, $t4, check_landing_continue
	j game_loop
	
	check_landing_Type4:
	addi $t0, $s2, 128
	lw $t1, 0($t0)
	bne $t1, $t4, check_landing_continue
	addi $t0, $s3, 128
	lw $t1, 0($t0)
	bne $t1, $t4, check_landing_continue
	j game_loop
	
	check_landing_continue:
	
	case1:
	move $a0, $s2
	li $a1, 128
	jal check_line_of_four_blocks
	move $s4, $a0
	
	move $a0, $s2
	li $a1, -128
	jal check_line_of_four_blocks
	add $t1, $s4, $a0
	
	li $t0, 2
	ble $t1, $t0, case2
	move $a2, $a0
	li $a1, -128
	move $a0, $s2
	addi $a2, $a2, 1
	jal remove_line_of_four_blocks
	move $a0, $s2
	li $a1, 128
	move $a2, $s4
	addi $a2, $a2, 1
	jal remove_line_of_four_blocks
	jal change_s2_state
	
	li $t0, 1
	sw $t1, is_dropped
	beq $t0, $t1, set_change
	
	
	j case2
	
	
	case2:
	# Case 3
	move $a0, $s2
	li $a1, -4
	jal check_line_of_four_blocks
	move $s4, $a0
	
	move $a0, $s2
	li $a1, 4
	jal check_line_of_four_blocks
	add $t1, $s4, $a0
	
	li $t0, 2
	ble $t1, $t0, case3
	move $a2, $a0
	li $a1, 4
	move $a0, $s2
	addi $a2, $a2, 1
	jal remove_line_of_four_blocks
	move $a0, $s2
	li $a1, -4
	move $a2, $s4
	addi $a2, $a2, 1
	jal remove_line_of_four_blocks
	jal change_s2_state
	
	
	li $t0, 1
	sw $t1, is_dropped
	beq $t0, $t1, set_change
	j case3
	
	case3:
	move $a0, $s3
	li $a1, 128
	jal check_line_of_four_blocks
	move $s4, $a0
	
	move $a0, $s3
	li $a1, -128
	jal check_line_of_four_blocks
	add $t1, $s4, $a0
	
	li $t0, 2
	ble $t1, $t0, case4
	move $a2, $a0
	li $a1, -128
	move $a0, $s3
	addi $a2, $a2, 1
	jal remove_line_of_four_blocks
	move $a0, $s3
	li $a1, 128
	move $a2, $s4
	addi $a2, $a2, 1
	jal remove_line_of_four_blocks
	jal change_s3_state
	
	li $t0, 1
	sw $t1, is_dropped
	beq $t0, $t1, set_change
	j case4
	
	
	case4:
	move $a0, $s3
	li $a1, -4
	jal check_line_of_four_blocks
	move $s4, $a0
	
	move $a0, $s3
	li $a1, 4
	jal check_line_of_four_blocks
	add $t1, $s4, $a0
	
	li $t0, 2
	ble $t1, $t0, set_change
	move $a2, $a0
	li $a1, 4
	move $a0, $s3
	addi $a2, $a2, 1
	jal remove_line_of_four_blocks
	move $a0, $s3
	li $a1, -4
	move $a2, $s4
	addi $a2, $a2, 1
	jal remove_line_of_four_blocks
	jal change_s3_state

	li $t0, 1
	sw $t1, is_dropped
	beq $t0, $t1, set_change
	
    j set_change

	set_change:
	lw $t9, s2_change
	bne $t9, $zero, change_s2
	after_change_s2:
	lw $t9, s3_change
	bne $t9, $zero, change_s3
	after_change_s3:
	j check_entrance_blocked
	
	change_s2:
	li $t9, 0x00000000
	sw $t9, 0($s2)
	sw $zero, s2_change
	j after_change_s2
	
	change_s3:
	li $t9, 0x00000000
	sw $t9, 0($s3)
	sw $zero, s3_change
	j after_change_s3
	
	# 2b. Update locations (capsules)
	# 3. Draw the screen
	# 4. Sleep
	
    # 5. Go back to Step 1
    j game_loop

### helper functions below ###
get_random_position:
    # generate a random row number between 0 and 16
	li $v0, 42
	li $a0, 0
	li $a1, 17
	syscall
	move $t0, $a0
	addi $t0, $t0, 12
	
	# generate a random column number between 0 and 13
	li $v0, 42
	li $a0, 0
	li $a1, 14
	syscall
	addi $a0, $a0, 6
	
	mult $t0, $t0, 128
	mult $a0, $a0, 4
	add $a0, $a0, $t0
	jr $ra


# functions
get_random_color:
	# generate a random number between 0 and 2
	li $v0, 42
	li $a0, 0
	li $a1, 3
	syscall

	# initialize t1 and t2 to be the 1 and 2 respective for branching
	addi $t1, $zero, 1
	addi $t2, $zero, 2

	beq $a0, $zero, blue
	beq $a0, $t1, green
	beq $a0, $t2, orange
	
blue:
	# load the color blue to $t1
	li $a0, 0x000000FF
	jr $ra
	
	
green:
	# load the color green to $t1
	li $a0, 0x0000FF00
	jr $ra


orange:
	# load the color orange to $t1
	li $a0, 0x00FFA500
	jr $ra


####################################
## The rectangle drawing function ##
####################################
## Note: The issue has been fixed
# Input parameters:
# - $a0: X coordinate of the top left corner of the rectangle
# - #a1: Y coordinate of the top left corner of the rectangle
# - $a2: Width of the rectangle
# - $a3: Height of the rectangle
draw_rect:
add $t5, $zero, $zero           # set my loop variable to zero
line_draw_start:

addi $sp, $sp, -4               # Move the stack pointer to an empty location
sw $t5, 0($sp)                  # Store $t5 onto the stack
addi $sp, $sp, -4               # Move the stack pointer to an empty location
sw $a1, 0($sp)                  # Store $a1 onto the stack
addi $sp, $sp, -4               # Move the stack pointer to an empty location
sw $ra, 0($sp)                  # Store $ra onto the stack
addi $sp, $sp, -4               # Move the stack pointer to an empty location
sw $a0, 0($sp)                  # Store $a0 onto the stack

jal draw_line                   # draw a line (using the X, Y and width parameters)

lw $a0, 0($sp)                  # Restore $ra from the stack.
addi $sp, $sp, 4                # Move the stack pointer to the top of the stack.
lw $ra, 0($sp)                  # Restore $ra from the stack.
addi $sp, $sp, 4                # Move the stack pointer to the top of the stack.
lw $a1, 0($sp)                  # Restore $a1 from the stack.
addi $sp, $sp, 4                # Move the stack pointer to the top of the stack.
lw $t5, 0($sp)                  # Restore $t5 from the stack.
addi $sp, $sp, 4                # Move the stack pointer to the top of the stack.

addi $t5, $t5, 1                # increment the loop variable
addi $a1, $a1, 1                # move the Y coordinate to the next row
beq $t5, $a3, line_draw_end     # break out of the loop if you hit the final row
j line_draw_start               # jump to the start of the row drawing loop
line_draw_end:  
jr $ra                          # return to the calling program


## The line drawing function ##
# Input parameters:
# - $a0: X coordinate of the start of the line
# - #a1: Y coordinate of the start of the line
# - $a2: Length of the line
draw_line:
# Main line drawing loop
add $t5, $zero, $zero       # initialize the loop variable $t5 to zero
sll $a1, $a1, 7             # calculate the vertical offset 
add $t7, $t0, $a1           # add the vertical offset to $t0
sll $a0, $a0, 2             # calculate the horizontal offset 
add $t7, $t7, $a0           # add the horizontal offset to $t7
pixel_draw_start:           # the starting label for the pixel drawing loop     
sw $t4, 0( $t7 )            # paint the current bitmap location.
addi $t5, $t5, 1            # increment the loop variable
addi $t7, $t7, 4            # move to the next pixel in the row.
beq $t5, $a2, pixel_draw_end    # break out of the loop if you hit the final pixel in the row
j pixel_draw_start          # otherwise, jump to the top of the loop
pixel_draw_end:             # the label for the end of the pixel drawing loop
jr $ra                   # return to calling program


## The line cancelling function ##
# Input parameters:
# - $a0: the location we want to check
# - $a1: the direction we want to check
check_line_of_four_blocks:
li $t0, 3      # minimum number of blocks to cancel
li $t1, 1      # an accumulator 
move $t3, $a0
check_line_while_start:
lw $t2, 0($a0)
add $t3, $t3, $a1
lw $t4, 0($t3)
beq $t4, $t2, update_count
addi $t1, $t1, -1
move $a0, $t1
jr $ra
update_count:
addi $t1, $t1, 1
ble $t1, $t0, check_line_while_start
bgt $t1, $t0, update_count_until_different_color
j after_count
update_count_until_different_color:
lw $t2, 0($a0)
add $t3, $t3, $a1
lw $t4, 0($t3)
beq $t4, $t2, update_count
li $t9, 0x00000000
beq $t4, $t9, after_count
j after_count
after_count:
addi $sp, $sp, -4
sw $ra, 0($sp)
move $a2, $t1
jal remove_line_of_four_blocks
lw $ra, 0($sp)
addi $sp, $sp, 4
beq $a0, $s2, change_s2_state
after_change_s2_state:
beq $a0, $s3, change_s3_state
after_change_s3_state:
jr $ra

change_s2_state:
li $t9, 1
sw $t9, s2_change
move $a0, $zero
j after_change_s2_state

change_s3_state:
li $t9, 1
sw $t9, s3_change
move $a0, $zero
j after_change_s3_state


remove_line_of_four_blocks:
## The line cancelling function ##
# Input parameters:
# - $a0: the location we want to check
# - $a1: the direction we want to check
# - $a2: the number of blocks towards location $a1 origin from $a0 we want to cancel
move $t0, $a2
li $t1, 1      # an accumulator 
move $t3, $a0
remove_line_while_start:
lw $t2, 0($a0)
add $t3, $t3, $a1
li $t4, 0x00000000
sw $t4, 0($t3)
# move $s7, $t3

# lw $t8, state
# li $t9, 1
# beq $t8, $t9, normal_remove_line
# li $t9, 3
# beq $t8, $t9, normal_remove_line


# check_for_unsupported_blocks:
# # dealing with unsupported blocks
# addi $sp, $sp, -4
# sw $t4, 0($sp)
# addi $sp, $sp, -4
# sw $t3, 0($sp)
# addi $sp, $sp, -4
# sw $t2, 0($sp)
# addi $sp, $sp, -4
# sw $t1, 0($sp)
# addi $sp, $sp, -4
# sw $t0, 0($sp)
# addi $sp, $sp, -4
# sw $a1, 0($sp)
# addi $sp, $sp, -4
# sw $a0, 0($sp)
# addi $sp, $sp, -4
# sw $ra, 0($sp)
# move $a0, $s7
# # update the state to Type 1
# li $t0, 1
# sw $t0, is_dropped
# jal calculate_drop_offset
# move $a1, $a0
# move $a0, $s7
# beq $a0, $zero, normal_remove_line

# jal drop_blocks_by_offsets

# lw $ra, 0($sp)
# addi $sp, $sp, 4
# lw $a0, 0($sp)
# addi $sp, $sp, 4
# lw $a1, 0($sp)
# addi $sp, $sp, 4
# lw $t0, 0($sp)
# addi $sp, $sp, 4
# lw $t1, 0($sp)
# addi $sp, $sp, 4
# lw $t2, 0($sp)
# addi $sp, $sp, 4
# lw $t3, 0($sp)
# addi $sp, $sp, 4
# lw $t4, 0($sp)
# addi $sp, $sp, 4
# normal_remove_line:


addi $t1, $t1, 1
blt $t1, $t0, remove_line_while_start 
jr $ra

# # if the current capsule if vertical
# lw $t8, state
# li $t9, 1
# beq $t8, $t9, last_vertical_block_cancelled
# li $t9, 3
# beq $t8, $t9, last_vertical_block_cancelled
# j remove_finished

# last_vertical_block_cancelled:
# addi $sp, $sp, -4
# sw $ra, 0($sp)
# addi $sp, $sp, -4
# sw $a0, 0($sp)
# move $a0, $s7
# jal calculate_drop_offset
# move $a1, $a0
# lw $a0, 0($sp)
# addi $sp, $sp, 4
# jal drop_blocks_by_offsets
# lw $ra, 0($sp)
# addi $sp, $sp, 4
# remove_finished:



# calculate_drop_offset:
# ####################################
# ## The calculate drop offset function ##
# ####################################
# # Input parameters:
# # - $a0: the block we are about to cancel
# ####################################
# # we want to find the offset 
# li $t0, 128
# li $t3, 1
# li $t2, 20
# move $t9, $a0
# li $t1, 0x00000000
# addi $t9, $t9, -128
# calculate_drop_offset_while_start:
# lw $t8, 0($t9)
# beq $t3, $t2, return_back
# beq $t8, $t1, increment_offset
# return_back:
# move $a0, $t0
# jr $ra
# increment_offset:
# addi $t0, $t0, 128
# addi $t9, $t9, -128
# addi $t3, $t3, 1
# j calculate_drop_offset_while_start



# drop_blocks_by_offsets:
# ####################################
# ## The drop blocks by offsets function ##
# ####################################
# # Input parameters:
# # - $a0: the block we are about to cancel
# # - $a1: the offset we want all the unsupported blocks to drop by
# ####################################
# li $t0, 0x00000000
# li $t7, 0
# li $t9, 20
# move $t1, $a0
# drop_blocks_while_start:
# addi $t1, $t1, -128
# lw $t2, 0($t1)
# beq $t7, $t9, return_drop_offsets
# bne $t2, $t0, apply_offset
# return_drop_offsets:
# jr $ra
# apply_offset:
# sw $t0, 0($t1)     # color the unsupported block to black
# add $t3, $t1, $a1  # apply the offset and store the value to $t3
# sw $t2, 0($t3)
# addi $t7, $t7, 1
# j drop_blocks_while_start
