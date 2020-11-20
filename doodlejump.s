#####################################################################
#
# CSC258H5S Fall 2020 Assembly Final Project
# University of Toronto, St. George
#
# Student: Ryan Goldberg, 1005873734
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestone is reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 1/[2]/3/4/5 (choose the one the applies)
#
# Which approved additional features have been implemented?
# (See the assignment handout for the list of additional features)
# 1. (fill in the feature, if any)
# 2. (fill in the feature, if any)
# 3. (fill in the feature, if any)
# ... (add more if necessary)
#
# Any additional information that the TA needs to know:
# - (write here, if any)
#
#####################################################################
.data
	# Defining constants
	.eqv TRUE      0
	.eqv FALSE     1
	.eqv DATA_SIZE 4   # Size of an integer in bytes
	.eqv SCREEN_SIZE 32

	.eqv BLUE      0x11bffe 
	.eqv YELLOW    0xdad830
	.eqv BLACK     0x000000
	.eqv DGREEN    0x0c8f50
	.eqv LGREEN    0x64bb12

	colors: .word BLUE, YELLOW, BLACK, DGREEN, LGREEN


	# The start address for the bitmap display
	displayAddress: .word 0x10008000


	# The bitmap for the doodler
	doodlerArrayR:.word 0,0,1,1,0,0,0,0
                  .word 0,1,1,1,1,0,0,1
				 .word 1,1,2,1,2,1,1,1
				 .word 1,1,1,1,1,1,0,1
				 .word 3,3,3,3,3,3,0,0
				 .word 1,1,1,1,1,1,0,0
				 .word 2,0,0,0,2,0,0,0
				 .word 2,2,0,0,2,2,0,0

	doodlerArrayL:.word 0,0,0,0,1,1,0,0
				 .word 1,0,0,1,1,1,1,0
				 .word 1,1,1,2,1,2,1,1
				 .word 1,0,1,1,1,1,1,1
				 .word 0,0,3,3,3,3,3,3
				 .word 0,0,1,1,1,1,1,1
				 .word 0,0,0,2,0,0,0,2
				 .word 0,0,2,2,0,0,2,2
				 
				 
	platformArray:.word 4,4,4,4,4,4,4,4,4,4,4,4
				 .word 0,0,4,4,4,4,4,4,4,4,0,0
				 
	skyArray:     .space 4096 # An array of 32x32 zeros
	
	newLine:      .asciiz "\n"
	
	doodlerX:     .word 10
	doodlerY:     .word 22
	hDirection:   .word 0

.text
# Defining some useful macros
	.macro draw (%x_size, %y_size, %x_pos, %y_pos, %bitmap)
	    addi $sp, $sp, -4
		addi $a0, $zero, %x_size
		addi $a1, $zero, %y_size
		add $a2, $zero, %x_pos
		add $a3, $zero, %y_pos
		la $t0, %bitmap
		sw $t0, 0($sp)
		jal drawBitMap    
		addi $sp, $sp, 4
	.end_macro

	main:
		mainLoop:
		
		# Check for keyboard input
		lw $t0, 0xffff0000				   # Check if a key has been pressed (a 1 is stored here)
		beq $t0, 1, if_keyboard_input		   # if $t0 == 1 go to if_keyboard_input	 
		beq $t0, 0, fi_keyboard_input		   # else go to fi_keyboard_input	
			if_keyboard_input:
				lw $t2, 0xffff0004		   # Load the keyboard input into $t2
				
				# If statments for differnt letter inputs
				beq $t2, 0x6A, respond_to_J 	
				beq $t2, 0x6B, respond_to_K
				beq $t2, 0x73, respond_to_S
				beq $t2, 0x63, respond_to_C
				j fi_keyboard_input		   # If they input is none of the accepted characters exit the if statement
				
				respond_to_J:
				
					# doodlerX--, and wrap around if x < 0
					lw $t1, doodlerX
					addi $t1, $t1, -1

					blt $t1, 0, if_wrapAroundLeft
					bge $t1, 0, fi_wrapAroundLeft
					if_wrapAroundLeft:
						addi $t1, $zero, 24
					fi_wrapAroundLeft:
					
					sw $t1, doodlerX
					sw $zero, hDirection # Sets the direction as left
					j fi_keyboard_input  # Exit if statement
				respond_to_K:
					# doodlerX++, and wrap around if x > 24 (i.e nose touches right)
					lw $t1, doodlerX
					addi $t1, $t1, 1
					
					bgt  $t1, 24, if_wrapAroundRight
					ble  $t1, 24, fi_wrapAroundRight
					if_wrapAroundRight:
						addi $t1, $zero, 0
					fi_wrapAroundRight:
 
					sw $t1, doodlerX
					li $t1, 1
					sw $t1, hDirection # Sets the direction as right
					j fi_keyboard_input  # Exit if statement
				respond_to_S:
					li $v0, 1
					addi, $a0, $zero, 0
					syscall
					j fi_keyboard_input  # Exit if statement
				respond_to_C:
					j  exitLoop
				
			fi_keyboard_input:
		
			# Update location 
			# Check for colliosons
			
		# Update location of platforms and other objects
		
		# Redraw the screen
		
			# Draw the blue background 
			draw (32, 32, 0, 0 skyArray)

			draw(2, 12, 30,5,platformArray)
			
			draw(2, 12, 18,5,platformArray)

			draw(2, 12, 10,12,platformArray)
		
			# Draw the Doodler at (doodlerX, doodlerY)
			lw $t1, doodlerY
			lw $t2, doodlerX
			
			# Draws the left facing (hDirection == 0) or right facting (hDirection != 1) doodler
			lw $t3, hDirection
			
			li $v0, 1
			move $a0, $t3
			syscall
			
			beqz  $t3, if_hDirectionIsLeft
				draw(8,8,$t1, $t2, doodlerArrayR)
				j fi_hDirectionIsLeft
			if_hDirectionIsLeft:
				draw(8,8,$t1, $t2, doodlerArrayL)
			fi_hDirectionIsLeft:
			
			
		# Sleep
		li $v0, 32
		li $a0, 333 # 1/3 second sleep
		syscall
		
		j mainLoop
	
	exitLoop:
		# End the program
		li $v0, 10
		syscall 
		
#######################################################
# Draws a bitmap of size x-size by y-size in position (X,Y) on the bitmap display unit	
drawBitMap:
	lw  $t0, 0($sp)            # The bitmap address is the first element on the stack
	lw  $t1, displayAddress    # Stores the base address for display
	add $t2, $zero, $a0        # Stores the x-size
	add $t3, $zero, $a1        # Stores the y-size
	add $t4, $zero, $a2        # Store the X pos in the new array
	add $t5, $zero, $a3        # Store the Y pos in the new array
	
	add $t6, $zero, $t4        #i = Y
	add $t7, $zero, $t5        #j = X
	
	add $t2, $t2, $t4		  #$t3 = size + Y
	add $t3, $t3, $t5          #$t4 = size + X
	
	forI:
	    beq $t6, $t2 , exitForI         # branch to ExitForI if i == size+Y
	    forJ:
	    		beq $t7, $t3 , exitForJ     # branch to ExitForJ if j == size+X

	    	    # We draw at mem address 128*i + 4 * j    
	    	    mul $s1, $t6, 128          # $s1 = 128 * i
	    		mul $s2, $t7, 4            # $s2 = 4 * j
	    		add $s0, $s1, $s2         # $s0 = 128i+4j
	    		add $s0, $t1, $s0 

	    		# Get the color value
	        addi $sp, $sp, -24
	        sw   $t6, 0($sp)        # Store i on the stack
	        sw   $t7, 4($sp)        # stote j on the stack       
	        sub  $t9, $t3, $t5      # Removes the y offset to get Y-size
       	    sw   $t9, 8($sp)        # store y-size on the stack
	        sw   $t4, 12($sp)       # Store x-pos
	        sw   $t5, 16($sp)       # Store y-pos
	        sw   $ra, 20($sp)       # store $ra on the stack
	        
	    	    jal  setColor           # Put the color to drwa in $v0	
	    		move $s1, $v0	
	    		sw   $s1 ($s0)          # Draw color in $s1 at position $s0	
	    		
	       	lw   $t6, 0($sp)        # pop i off the stack
	        lw   $t7, 4($sp)        # pop j off the stack       
	        lw   $t4, 12($sp)       # pop x-pos off stack
	        lw   $t5, 16($sp)       # pop y-pos off stack
	        lw   $ra, 20($sp)       # pop $ra off the stack					
         	addi $sp, $sp, 24
	       	
	    		addi $t7, $t7, 1        # j++
	    		j forJ
	    #j forI REMOVE ME

		exitForJ:
			add  $t7, $zero, $t5    # j = X
			addi $t6, $t6, 1        # i++
			j forI	
	exitForI:
	    jr $ra                      # Return to the original call to draw

	setColor:
		lw $t6, 0($sp) # Store i on the stack
	    lw $t7, 4($sp) # stote j on the stack
	    lw $t9, 8($sp) # store y-size on the stack       
	    lw $t4, 12($sp) # Store x-pos
	    lw $t5, 16($sp) # Store y-pos
	    lw $t0, 24($sp) # Pop bitmap address
	
	
	   sub $t6, $t6, $t4        # Remove the x offset from i
	   sub $t7, $t7, $t5        # Remove the y offset from j
	
	
	   # Find the correct address in the bitmap to get the color
	   mul $t9, $t9, 4         # s3 = 4* size
       mul $t9, $t9, $t6       # s3 = 4 * size * i
	   mul $t7, $t7, 4         # s4 = 4* j
	   add $t5, $t9, $t7      # t5 = 4 * size * i + 4 * j
	   add $t0, $t0, $t5 
	   
	
	    # the index of the color to draw taken from (i,j) on the bitmap
	    lw $s1, ($t0)	 
		mul $s1, $s1, 4

		# Get the ($s7)th color from the array (We use $s7 since we needed to * 4)
	    la $s2, colors
	    add $s2, $s2, $s1
	   	
	    # Stores the correct color in $v0
	    lw $v0, ($s2)
	    jr $ra					
#######################################################
