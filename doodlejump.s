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
# - Display height in pixels: 512
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
	.eqv TRUE                1
	.eqv FALSE               0
	.eqv SCREEN_WIDTH                      32
	.eqv SCREEN_HEIGHT                     64 
	.eqv PLATFORM_WIDTH                    12
	.eqv SCREEN_BYTE_AREA                8192
	.eqv SCREEN_BYTE_AREA_WITH_BUFFER    8320 	# Add an extra row on the bottom as a buffer (If we draw a platfrom on the very bottom row) 

	# Defining some colors to be used and their pallate
	.eqv BLUE         0x11bffe 
	.eqv YELLOW       0xdad830
	.eqv BLACK        0x000000
	.eqv DGREEN       0x0c8f50
	.eqv LGREEN       0x64bb12
	.eqv TRANSPARENT -1

	colors: .word BLUE, YELLOW, BLACK, DGREEN, LGREEN, TRANSPARENT


	# The start address for the bitmap display
	displayAddress: .word  0x10008000
	# The buffer where where the bitmap is stored before being drawn to the screen
	displayBuffer:  .space SCREEN_BYTE_AREA_WITH_BUFFER


	# The bitmap for the doodler
	doodlerArrayR:.word 5,5,1,1,5,5,5,5
                  .word 5,1,1,1,1,5,5,1
				 .word 1,1,2,1,2,1,1,1
				 .word 1,1,1,1,1,1,5,1
				 .word 3,3,3,3,3,3,5,5
				 .word 1,1,1,1,1,1,5,5
				 .word 2,5,5,5,2,5,5,5
				 .word 2,2,5,5,2,2,5,5

	doodlerArrayL:.word 5,5,5,5,1,1,5,5
				 .word 1,5,5,1,1,1,1,5
				 .word 1,1,1,2,1,2,1,1
				 .word 1,5,1,1,1,1,1,1
				 .word 5,5,3,3,3,3,3,3
				 .word 5,5,1,1,1,1,1,1
				 .word 5,5,5,2,5,5,5,2
				 .word 5,5,2,2,5,5,2,2
				 
	# The bitmap for a platform
	platformArray:.word 4,4,4,4,4,4,4,4,4,4,4,4
				 .word 5,5,4,4,4,4,4,4,4,4,5,5
	
	# The bitmap for the sky (An array of 32x32 zeros)		 		 
	skyArray:     .space SCREEN_BYTE_AREA
	
	# Strings
	newLine:      .asciiz "\n"
	message1:     .asciiz "You are on a platform\n\n"
	
	# Variables
	doodlerX:              .word 6
	doodlerY:              .word 50
	hDirection:            .word 0
	timeLeftInAir:         .word 6
	jumpHeight:		      .word 6
	
	rowsSinceRandPlatform: .word 0
	
	

	# Every even idxex is left value is position, every odd idnxex is right value and values are platform value
	#platformPositions: .space 256 # (64 rows * 4 bytes)
	platformPositions: .word 1,0, 0,0, 10,0, 0,0, 4,0, 0,0, 0,0, 2,0, 0,0, 21,0, 0,0, 0,7, 0,0, 0,0, 14,0, 0,0,6 ,0, 0,2, 0,0, 0,0, 0,0, 18,0, 0,0, 2,0, 0,0, 11,0, 0,0, 0,0, 0,3, 5,0, 0,0, 1,0		# Temmp
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
		

			# Check for doodler colisions (with platform)	
			jal doodlerOnPlatform
			add $t9, $zero, $v0			# 0 if you are not on a platform, 1 if you are
			
			#Implements the falling
			lw $t1, timeLeftInAir       #$t1 is the time left in the air
			sle $t2, $t1, $zero			# True if you are falling, false otherwise
			and $t9, $t9, $t2 		 	# You are falling and you hit a platform
			
			beqz $t9, else_on_platform	# You are either still jumping or you don't hit a platform, so don't just again
			if_on_platform:
				# Once you land on a platform, set your timeInTheAir value to jumpheight
				
				lw $t1, jumpHeight
				sw $t1, timeLeftInAir
				
				j fi_on_platform
			else_on_platform:
				# decrement your time left in the air by 1
				addi $t1, $t1, -1
				sw $t1, timeLeftInAir
				j fi_on_platform
			fi_on_platform:
			
			# Move doodler
			lw $t1, timeLeftInAir
			lw $t2, doodlerY
			bltz $t1, else_jumping
			if_jumping: # Currently moving up
				addi $t2, $t2, -1
				j fi_jumping
			else_jumping: # Curretnly alling
				addi $t2, $t2, 1
			fi_jumping:	
			sw $t2, doodlerY


		# Update location of platforms and other objects 													#todo
		
		jal shiftPlatformsDownIfNeeded
		
		
		
		# Redraw the screen
			# Draw the blue background 
			draw (SCREEN_HEIGHT, SCREEN_WIDTH, 0, 0 skyArray)

			# Draw platforms to buffer
			jal drawPlatforms
			
			# The position of the Doodler is (doodlerX, doodlerY)
			lw $t1, doodlerY
			lw $t2, doodlerX
			# Draws the left facing (hDirection == 0) or right facting (hDirection != 1) doodler to the buffer
			lw $t3, hDirection
			beqz  $t3, if_hDirectionIsLeft
				draw(8,8,$t1, $t2, doodlerArrayR)
				j fi_hDirectionIsLeft
			if_hDirectionIsLeft:
				draw(8,8,$t1, $t2, doodlerArrayL)
			fi_hDirectionIsLeft:
			
			# Draw the bitmap display from the buffer
			jal copyFromDisplayBuffer
			
		# Sleep
		li $v0, 32
		li $a0, 1 # 1/3 second sleep
		syscall
		
		j mainLoop
	
	exitLoop:
		# End the program
		li $v0, 10
		syscall 
#######################################################
shiftPlatformsDownIfNeeded:
	la $t0, platformPositions
	lw $t1, doodlerY
	
	bgt $t1, 25, fi_platforms_should_drop		# IF the doodler is above than Y = 25, drop the platforms
	if_platforms_should_drop:
		add $t2, $zero, 252					# i = 252 (63*4)
		for_platform_shift:				
			add $t3, $t0, $t2				# The adresss we're updating
			lw 	$t4, -4($t3)                 # 1 word before the address, where we get the data
			sw  $t4, 0($t3)					# t3 = arrayAdress + offset into array
			add $t2, $t2, -4						# i -= 4
			beq $t2, 0, exit_platform_shift		# Exit if ==4
			
			j for_platform_shift
		exit_platform_shift:
		
		# Randomly generate platforms
		lw $t1 jumpHeight
		lw $t2 rowsSinceRandPlatform
		
		
		# E(rowsSinceRandPlatform) = -rowsSinceRandPlatform + (jumpHeight + 1)			This equation will be used to calculate the end random value for the chances to make a platform
		
		mul  $t5, $t2, -1						# $t5 = -rowsSinceRandPlatform
		addi $t1, $t1, 1							# $t1 = (jumpHeight + 1)+1
		add $t1, $t1, $t5						# t1 = E(rowsSinceRandPlatform)
		
		li  $v0, 42								# A random number between 1 to E(rowsSinceRandPlatform)
		add $a1, $zero, $t1	
		syscall
		add $t1, $zero, $a0
		
		bne $t1, 0, else_makePlatform				# If you generate a 0, make a platform
		blt $t2, 6, else_makePlatform				# Never have platforms closer than 4 units apart
		if_makePlatform:
			li $v0, 42
			li $a1, 19  # 31 -12
			syscall
		
			addi $t4, $a0,1
			sw  $t4, 0($t0)	
		
			addi $t2, $zero, 0			# Sets the rows since random platform generation to 0
			j fi_makePlatform
		else_makePlatform:
			sw  $zero, 0($t0)	
		
		fi_makePlatform:
		addi $t2, $t2, 1
		sw $t2, rowsSinceRandPlatform
		
		
		
	fi_platforms_should_drop:
	jr $ra


#######################################################
doodlerOnPlatform:																										# FIXME: You have hang off the right edge by the nose
	lw $t0, doodlerX
	lw $t1, doodlerY
	la $t2, platformPositions
	
	addi $t1, $t1, 8 								# Standing on a platform, means we need to look 8 units under the Y to see if we are on it
	mul $t3, $t1, 4									# Multiply by 4 (bytes) to get the correct mem address
	add $t3, $t3, $t2
	lw  $t3, ($t3)									# Store the value of platform array[i] in t3

	bnez  $t3, if_possiblePlatformCollison 			# If the value is non-zero then it is the x-coord for a platform in row i
	beqz  $t3, fi_collisionDetected 					# If the value is zero then there is no platform in this row
	if_possiblePlatformCollison:
		addi $t3, $t3, -1 							# The x-value is off by 1 and so must be decremented to the correct value
		
		# IF X >= t3-8 AND X <+ t3 +(12-1) ==> COLLISON
		addi $t4, $t3, -7				#t4 = t3-8
		addi $t5, $t3, 11				#t5 = t3+11	
		sle $t4, $t4, $t0				# t4 = t3-8 <= X
		sle $t5, $t0, $t5				# t5 = X >= t3+12
		and $t3, $t4, $t5
		bnez $t3, if_collisionDetected
		beqz $t3 fi_collisionDetected
		if_collisionDetected:
			li $v0, 1			# You are on a platform
			
			j fi_possiblePlatformCollison
		fi_collisionDetected:
			li $v0, 0			# You are not on a platform
			j fi_possiblePlatformCollison
		fi_possiblePlatformCollison:
		
		jr $ra
	

#######################################################
# Draws a bitmap of size x-size by y-size in position (X,Y) on the bitmap display unit	
drawBitMap:
	lw  $t0, 0($sp)            # The bitmap address is the first element on the stack
	la  $t1, displayBuffer    # Stores the buffer address for display
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
	    																												
	    		
	    		bltz $s1, fi_not_transparent	# Only draw if the color value > 0 (-1 == Transparent)
	    		if_not_transparent:																																																			# if transparent, don't draw anything
	    			sw   $s1 ($s0)          # Draw color in $s1 at position $s0	
	    		fi_not_transparent:	
	    		
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
drawPlatforms:
	addi $sp, $sp, -4				    # Store the return address on the stack
	sw   $ra, ($sp) 

	addi $t0, $zero, SCREEN_HEIGHT 		# i = 64
	la   $t1, platformPositions           # stores the return address on the stack on the stack

	forPlatformRow:
		addi $t0, $t0, -1                 #i--
		
		mul $t2, $t0, 4					# 4i 
		add $t2, $t2, $t1
		lw  $t2, ($t2)					# $t2 is the value of platformPositions[i]
		
		bnez  $t2, if_rowHasPlatform 				# If the value is non-zero then it is the x-coord for a platform in row i
		beqz  $t2, fi_rowHasPlatform 				# If the value is zero then there is no platform in this row
		if_rowHasPlatform:
			addi $t2, $t2, -1 					# The x-value is off by 1 and so must be decremented to the correct value
			
			addi $sp, $sp, -8					# Allocated stack space
	 		sw   $t0, ($sp) 						# Stores i on the stack
	 		sw   $t1, 4($sp)						# Stores platformPositions on the stack
			
			draw(2, PLATFORM_WIDTH, $t0,$t2,platformArray)		# draw platform 

			lw   $t0, ($sp) 
			lw   $t1, 4($sp)						
			addi $sp, $sp, 8							# Deallocated stack space after restoring values
		
		fi_rowHasPlatform:
		
	
		beqz $t0, exitPlatformRow		# exit if i == 0
		j forPlatformRow
	
	exitPlatformRow:
		lw   $ra, 0($sp)     	# Restores the return address and dealocated the memory					
         addi $sp, $sp, 4
	
		jr $ra
#######################################################	
# Copy the displayBuffer to the display address
copyFromDisplayBuffer:
	lw  $t0, displayAddress
	la  $t1, displayBuffer
	
	addi $t2, $zero, 0
	for_copy_display_buffer:
		beq $t2, SCREEN_BYTE_AREA,exit_for_copy_display_buffer # Exit if i == 64*32*4 == 8192
		
		add $t3, $t1, $t2 									# $t3 = displayBuffer + offset i
		add $t4, $t0, $t2
		lw $t3, ($t3)									    # $t3 = displayAddress + offset i
		sw $t3, ($t4)										# Copy the value

		addi $t2, $t2, 4
		j for_copy_display_buffer								# i += 4
	exit_for_copy_display_buffer:
	jr $ra
######################################################

