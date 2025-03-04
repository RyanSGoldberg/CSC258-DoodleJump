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
# - Milestone 1/2/3/4/[5] (choose the one the applies)
#
# Which approved additional features have been implemented?
# (See the assignment handout for the list of additional features)
# 1. 4a - Score/scoreboard (1 point for every platform jumped on)
# 2. 4b - Game Over / retry
# 3. 5d - Fancier graphics (Doodler and platforms have somewhat fancy look, the shield has an animation with it so that it looks like it is moving)
# 4. 5b - More Platform Types: Regular (green), Fragile (Brown - break on landing), Moving (Blue), HotOne (Yellow - When landed on are primed), HotTwo (Fire - Kill the player when landed on)
# 5. 5c - Boosting: Springs (The grey Ts on platforms), Rockets (The little blue jetpack shape above some platforms). The jetpack adds an image to the doodler so it has a jetpack when 'flying' 
# 6. 5f - Background Music is played (Lost Woods from Zelda), and jump sound effect when the doodler jumps on anything
# 7. 5i - Oponents will randomly spawn. The play will begin falling if they collide from below. If they jump on the monster it will be killed , and the player gets a jump boost
# 8. 5j - Shields: When the doodler has an active shield it can jump through a monster and won't get knocked down. This is use up the shield. Note the shield only protects from above so hotTwo 
#					platfroms will still kill the played.
# 9. 4d - Dynamic changes to the platform types/boosts/items depending on the current score. The first few platforms are close to one another and are regular type (Green).
#					The medium distribution is mostly regular platforms with a few moving platforms and springs. The Hard distribution has all the platfroms/boosts/items. Hard occurs when score >= 20
# Any additional information that the TA needs to know:
# * The code requires a little endian architecture
# * The code uses some pseudo-instructions, so the pseudo-instruction setting must be enabled on mars
# * To end the game click "c", this will stop the main loop
#####################################################################
.data
	# Defining constants
	.eqv SCREEN_WIDTH                      32
	.eqv SCREEN_HEIGHT                     64 
	.eqv PLATFORM_WIDTH                    12
	.eqv SCREEN_BYTE_AREA                8192
	.eqv SCREEN_BYTE_AREA_WITH_BUFFER    8320 	# Add an extra row on the bottom as a buffer (If we draw a platfrom on the very bottom row) 

	# Defining some colors to be used and their pallate
	.eqv LBLUE        0x11bffe 
	.eqv YELLOW       0xdad830
	.eqv BLACK        0x000000
	.eqv DGREEN       0x0c8f50
	.eqv LGREEN       0x64bb12
	.eqv TRANSPARENT -1
	.eqv GREYBLUE     0x5ba0b7
	.eqv GREY		 0x7a7a7a
	.eqv DBLUE		 0x0021ff
	.eqv BROWN  	  	 0x974c01
	.eqv BYELLOW		 0xd3ff00
	.eqv RED			 0xff1900
	.eqv ORANGE		 0xff7900
	.eqv WHITE		 0xffffff
	
	colors: .word LBLUE, YELLOW, BLACK, DGREEN, LGREEN, TRANSPARENT, GREYBLUE, GREY, DBLUE, BROWN, BYELLOW, RED, ORANGE, WHITE

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
	
	# Bitmaps for the sheild and the rocketpack			 
	shieldArrayA: 	.word 5,13,8,13,8,13,8,13,8,5
				 	.word 13,5,5,5,5,5,5,5,5,8
				 	.word 8,5,5,5,5,5,5,5,5,13
					.word 13,5,5,5,5,5,5,5,5,8
			 		.word 8,5,5,5,5,5,5,5,5,13
				 	.word 13,5,5,5,5,5,5,5,5,8
				 	.word 8,5,5,5,5,5,5,5,5,13
				 	.word 13,5,5,5,5,5,5,5,5,8
				 	.word 8,5,5,5,5,5,5,5,5,13
	shieldArrayB: 	.word 5,8,13,8,13,8,13,8,13,5
			 		.word 8,5,5,5,5,5,5,5,5,13
			 		.word 13,5,5,5,5,5,5,5,5,8
			 		.word 8,5,5,5,5,5,5,5,5,13
			 		.word 13,5,5,5,5,5,5,5,5,8
			 		.word 8,5,5,5,5,5,5,5,5,13
			 		.word 13,5,5,5,5,5,5,5,5,8
			 		.word 8,5,5,5,5,5,5,5,5,13
			 		.word 13,5,5,5,5,5,5,5,5,8
	shieldArrays: 	.word shieldArrayA, shieldArrayB
	
	rocketArrayL:	.word 5,8,5,5,5,5,5,5,5,5,5,5
					.word 8,8,5,5,5,5,5,5,5,5,5,5
					.word 8,8,8,5,5,5,5,5,5,5,5,5
					.word 8,8,5,5,5,5,5,5,5,5,5,5
					.word 8,8,5,5,5,5,5,5,5,5,5,5
					.word 11,11,5,5,5,5,5,5,5,5,5,5
					
	rocketArrayR:    .word 5,5,5,5,5,5,5,5,5,5,8,5
					.word 5,5,5,5,5,5,5,5,5,5,8,8
					.word 5,5,5,5,5,5,5,5,5,8,8,8
					.word 5,5,5,5,5,5,5,5,5,5,8,8
					.word 5,5,5,5,5,5,5,5,5,5,8,8
					.word 5,5,5,5,5,5,5,5,5,5,11,11
	rocketArrays: 	.word rocketArrayR, rocketArrayL
						 	 
	# The bitmaps for the platforms / monsters / items
	regularPlatformArray: .word 4,4,4,4,4,4,4,4,4,4,4,4
				         .word 5,5,4,4,4,4,4,4,4,4,5,5
				 
	springPlatformArray: .word 7,7,7,4,7,7,7,7,4,7,7,7
				        .word 5,7,4,4,4,7,7,4,4,4,7,5
				        
	movingPlatformArray: .word 8,8,8,8,8,8,8,8,8,8,8,8
						.word 5,5,8,8,8,8,8,8,8,8,5,5
						
	brokenPlatformArray:
						.word 9,9,9,9,9,9,5,9,9,9,9,9
						.word 5,5,9,9,9,5,9,9,9,9,5,5
	
	hotOnePlatformArray: .word 10,10,10,10,10,10,10,10,10,10,10,10
						.word 5,5,10,10,10,10,10,10,10,10,5,5
	
	hotTwoPlatformArray: .word 11,11,12,12,10,13,13,10,12,12,11,11
						.word  5,11,11,12,12,10,10,12,12,11,11, 5
						
	monsterPlatformArray:.word 2, 2, 7, 7, 11,7, 7, 11, 7, 7, 2, 2
						.word 2, 5, 7, 7, 7, 13, 13, 7, 7, 7, 5, 2
						
	rocketPlatformArray: .word 5,5,5,5,5,8,5,5,5,5,5,5	
						.word 5,5,5,5,8,8,8,5,5,5,5,5
						.word 5,5,5,5,8,8,8,5,5,5,5,5
						.word 5,5,5,5,11,5,11,5,5,5,5,5
						.word 5,5,5,5,5,5,5,5,5,5,5,5
						.word 4,4,4,4,4,4,4,4,4,4,4,4
				        .word 5,5,4,4,4,4,4,4,4,4,5,5
				        
	shieldPlatformArray: .word 5,5,5,5,8,13,8,5,5,5,5,5	
						.word 5,5,5,5,13,8,13,5,5,5,5,5
						.word 5,5,5,5,8,13,8,5,5,5,5,5
						.word 5,5,5,5,5,8,5,5,5,5,5,5
						.word 5,5,5,5,5,5,5,5,5,5,5,5
						.word 4,4,4,4,4,4,4,4,4,4,4,4
				        .word 5,5,4,4,4,4,4,4,4,4,5,5
										
	# Array of the different platform arrays (Note movingPlatformArray is here twice for left = 2 and right = 3, likewise MonsterPlatformArray is 7/8)
	platformArrays:      .word regularPlatformArray, springPlatformArray, movingPlatformArray, movingPlatformArray, hotOnePlatformArray, hotTwoPlatformArray,
						.word brokenPlatformArray, monsterPlatformArray, monsterPlatformArray, rocketPlatformArray, shieldPlatformArray
	
	# The bitmap for the sky (An array of 32x32 zeros)		 		 
	skyArray:     .space SCREEN_BYTE_AREA
	
	#Bitmap for the banner
	bannerArray:  .word 6:256
	
	# The bitmap for GameOver
	gameOverArray:.word 5,5,5,2,2,2,5,5,5,5,5,2,5,5,5,5,2,5,2,5,5,5,2,2,2	
                  .word 5,5,2,5,5,5,2,5,5,5,2,5,2,5,5,2,5,2,5,2,5,2,5,5,5
                  .word 5,5,2,5,5,5,5,5,5,2,5,5,5,2,5,2,5,2,5,2,5,2,5,5,5
                  .word 5,5,2,5,5,2,2,2,5,2,5,5,5,2,5,2,5,2,5,2,5,2,2,2,2
                  .word 5,5,2,5,5,5,2,5,5,2,2,2,2,2,5,2,5,2,5,2,5,2,5,5,5
                  .word 5,5,2,5,5,5,2,5,5,2,5,5,5,2,5,2,5,2,5,2,5,2,5,5,5
                  .word 5,5,5,2,2,2,5,5,5,2,5,5,5,2,5,2,5,2,5,2,5,5,2,2,2
                  .word 5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5
                  .word 5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5
                  .word 5,5,5,2,2,2,5,5,5,2,5,5,5,2,5,5,2,2,2,5,5,5,2,2,5
                  .word 5,5,2,5,5,5,2,5,5,2,5,5,5,2,5,2,5,5,5,5,5,2,5,5,2
                  .word 5,5,2,5,5,5,2,5,5,2,5,5,5,2,5,2,5,5,5,5,5,2,5,5,2
                  .word 5,5,2,5,5,5,2,5,5,2,5,5,5,2,5,2,2,2,2,5,5,2,2,2,5
                  .word 5,5,2,5,5,5,2,5,5,2,5,5,5,2,5,2,5,5,5,5,5,2,2,5,5
                  .word 5,5,2,5,5,5,2,5,5,5,2,5,2,5,5,2,5,5,5,5,5,2,5,2,5
                  .word 5,5,5,2,2,2,5,5,5,5,5,2,5,5,5,5,2,2,2,5,5,2,5,5,2
     # the bitmap for "Click S to start"        
     clickSArray: .word 5,2,2,2,5,2,5,5,5,2,5,2,2,2,5,2,5,2,5,5,5,5,2,2,2,5,5
 				 .word 5,2,5,5,5,2,5,5,5,2,5,2,5,5,5,2,5,2,5,5,5,5,2,5,5,5,5
 				 .word 5,2,5,5,5,2,5,5,5,2,5,2,5,5,5,2,2,5,5,5,5,5,2,2,2,5,5
 				 .word 5,2,5,5,5,2,5,5,5,2,5,2,5,5,5,2,5,2,5,5,5,5,5,5,2,5,5
 				 .word 5,2,2,2,5,2,2,2,5,2,5,2,2,2,5,2,5,2,5,5,5,5,2,2,2,5,5
 				 .word 5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5
 				 .word 5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5
 				 .word 5,2,2,2,5,2,2,2,5,5,5,5,2,2,2,5,2,5,5,5,5,2,5,5,2,5,2
 				 .word 5,5,2,5,5,2,5,2,5,5,5,5,2,5,2,5,2,5,5,5,2,5,2,5,2,5,2
 				 .word 5,5,2,5,5,2,5,2,5,5,5,5,2,2,2,5,2,5,5,5,2,2,2,5,5,2,5
 				 .word 5,5,2,5,5,2,5,2,5,5,5,5,2,5,5,5,2,5,5,5,2,5,2,5,5,2,5
 				 .word 5,5,2,5,5,2,2,2,5,5,5,5,2,5,5,5,2,2,2,5,2,5,2,5,5,2,5
                  
    # Bitmaps of the numebrs 0-9
    zeroArray:  .word 2,2,2, 2,5,2, 2,5,2, 2,5,2, 2,2,2
    oneArray:   .word 2,2,5, 5,2,5, 5,2,5, 5,2,5, 2,2,2
    twoArray:   .word 2,2,2, 5,5,2, 2,2,2, 2,5,5, 2,2,2
    threeArray: .word 2,2,2, 5,5,2, 2,2,2, 5,5,2, 2,2,2
    fourArray:  .word 2,5,2, 2,5,2, 2,2,2, 5,5,2, 5,5,2
    fiveArray:  .word 2,2,2, 2,5,5, 2,2,2, 5,5,2, 2,2,2
    sixArray:   .word 2,2,2, 2,5,5, 2,2,2, 2,5,2, 2,2,2
    sevenArray: .word 2,2,2, 5,5,2, 5,5,2, 5,5,2, 5,5,2
    eightArray: .word 2,2,2, 2,5,2, 2,2,2, 2,5,2, 2,2,2
    nineArray:  .word 2,2,2, 2,5,2, 2,2,2, 5,5,2, 5,5,2
    numArray:   .word zeroArray,oneArray,twoArray,threeArray,fourArray,fiveArray,sixArray,sevenArray,eightArray,nineArray
    
    #Distrribution for how often the different platform types are created (0 = Reg, 1 = Spring, 2 = Move L, 3 = Move R, , 4 =HotOne, 6 = Broken, 7 = Moster L, 8 = Monster R, 9 = Rocket, 10 = Shield)
    # There are different distributions depending ont the score (Easy = All green, Med  = Green with a few blue/spring, Hard = Everything)
    distributionH: .word 7, 7, 7, 8, 8, 8, 4, 4, 4, 4, 4, 4, 4, 6, 6, 6, 6, 6, 6, 6, 10, 10, 10, 3, 3, 3, 3, 3, 3, 3, 2, 2, 2, 2, 2, 2, 9, 9, 9, 9, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    distributionM: .word 0:80
    				  .word 1:10
    				  .word 2:10
    
	# Strings
	newLine:      .asciiz "\n"
	
	# Variables
	gameState:			  .word 0			# 0 Is the start menu, 1 is playing the game
	gamesPlayed:           .word -1
	score:                 .word 0
	
	doodlerX:              .word 0			# The doodlers x pos
	doodlerY:              .word 0			# The doodler's y pos
	hDirection:            .word 0			# The direction the doodler is facing
	timeLeftInAir:         .word 6			# How many cycles the doodler has left in the air
	rowsSinceRandPlatform: .word 0			# The number of rows since a random platform was created
	shield:				  .word -1			# If there is an active shield
	rocket:				  .word -1			# If there is an active rocket pack
	

	# Every value > 1 is the x coord -1 if the platform, 0 means there is no platform
	initialPlatformPositions: .word  0,0,0,0,10,0,0,0,0,0,0,0,0,0,2,0,0,0,21,0,0,0,0,7,0,0,0,0,14,0,0,0,0,0,0,2,0,0,0,0,0,0,18,0,0,0,2,0,0,0,11,0,0,0,0,0,0,3,0,0,0,0,1,0
	startMenuPlatformPosition: .word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,10,0,0	
	platformPositions:		 .space 256
	
	# Data for the background music
	notesR: .word   65, 69, 71, 0, 65, 69, 71, 0, 65, 69, 71, 76, 74, 71, 72, 71, 67, 64, 0, 0, 0, 62, 64, 67, 64, 0, 0, 0, 65, 69, 71, 0, 65, 69, 71, 0, 65, 69, 71, 76, 74, 71, 72, 76, 71, 67, 0, 71, 67, 62, 64, 0, 0, 0, 62, 64, 65, 0, 67, 69, 71, 0, 72, 71, 64, 0, 0, 65, 67, 69, 0, 71, 69, 71, 0, 72, 74, 76, 0, 0, 0, 0, 0, 0, 62, 64, 65, 0, 67, 69, 71, 72, 71, 64, 0, 0, 0, 0, 0, 0, 65, 64, 69, 67, 71, 0, 69, 69, 71, 74, 72, 72, 74, 74, 72, 76, 72, 74, 76, 0, 0, 0, 76,-1
	notesL: .word   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 62, 64, 65, 0, 67, 72, 74, 0, 76, 77, 79, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 62, 60, 65, 64, 67, 0, 65, 72, 67, 71, 69, 76, 71, 77, 76, 71, 77, 69, 71, 0, 0, 0, 83
	.eqv noteLen    300  # The length of time a note is played
	.eqv instrument 17   #Organ
	currentNote: .word 0 # The note index in the arrays to be played
	noteDelay:   .word 0 # The count of loop cycles between notes
	 
.text
	# Draw a label bitmap to the screen
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

	# Draw an bitmap stored starting at address to the screen
	.macro drawR (%x_size, %y_size, %x_pos, %y_pos, %address)
	    addi $sp, $sp, -4
		add $a0, $zero, %x_size
		addi $a1, $zero, %y_size
		add $a2, $zero, %x_pos
		add $a3, $zero, %y_pos
		add $t0, $zero, %address
		sw $t0, 0($sp)
		jal drawBitMap    
		addi $sp, $sp, 4
	.end_macro

	main:
		jal setGameStateToZero # Set the gameStateToZero
	
		mainLoop:
		# Check for keyboard input
		lw $t0, 0xffff0000				   # Check if a key has been pressed (a 1 is stored here)
		beq $t0, 1, if_keyboard_input		   # if $t0 == 1 go to if_keyboard_input	 
		beq $t0, 0, fi_keyboard_input		   # else go to fi_keyboard_input	
			if_keyboard_input:
				lw $t2, 0xffff0004		   # Load the keyboard input into $t2
				
				# If statments for different letter inputs
				beq $t2, 0x6A, respond_to_J 	
				beq $t2, 0x6B, respond_to_K
				beq $t2, 0x73, respond_to_S
				beq $t2, 0x63, respond_to_C
				j fi_keyboard_input		   # If their input is none of the accepted characters exit the if statement
				
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
					jal setGameStateToOne		# Reset the game to the inital state
					j fi_keyboard_input      # Exit if statement
				respond_to_C:
					j  exitLoop
			fi_keyboard_input:
		
			# Check for doodler colisions (with platform)	
			jal doodlerOnPlatform
			add $t9, $zero, $v0			# 0 if you are not on a platform, 1 if you are
			add $t8, $zero, $v1			# Store the platform type in $t8
			
			#Implements the falling
			lw $t1, timeLeftInAir       #$t1 is the time left in the air
			sle $t2, $t1, $zero			# True if you are falling, false otherwise
			and $t9, $t9, $t2 		 	# You are falling and you hit a platform
			
			# Handle platform colissions
			beqz $t9, else_on_platform	# You are either still jumping or you don't hit a platform, so don't just again
			if_on_platform:
				beq $t8, 1, else_springJump		# If you're on a spring platform do a special jump
				beq $t8, 6, else_brokenJump		# If you're on a broken platform do fall and break the platform
				beq $t8, 4, else_hotOneJump		# If you're on a hotOne platform prime the platform for next time
				beq $t8, 5, else_hotTwoJump		# If you're on a hotTwo platform end the game since its 'hot'
				beq $t8, 7, else_monsterJump		# If you're on a monster platform kill the monster and jump away
				beq $t8, 8, else_monsterJump		# If you're on a monster platform kill the monster and jump awa
				beq $t8, 9, else_rocket			# If you land on a rocket, activate the ability and remove the item
				beq $t8, 10,else_shield			# If you land on a shield, activate the ability and remove the item
				
				if_regJump:	# Jump 6 units high on a regular jump
					addi $t1, $zero, 6
					sw   $t1, timeLeftInAir
					j fi_jumps
				else_springJump:	# Jump 10 units high when on a spring
					addi $t1, $zero, 10
					sw   $t1, timeLeftInAir
					j fi_jumps
				else_brokenJump:	# Keep falling if you land on a broken plaform and break the platform
					lw   $t1, timeLeftInAir
					addi $t1, $t1, -1
					sw   $t1, timeLeftInAir
					
					# Remove the platform once its jumped on
					lw   $t2, doodlerY
					addi $t2, $t2, 8					# The offet to the platform which the doodler is standing on
					mul $t2, $t2, 4
					la $t2, platformPositions($t2)	# The address spesifing the platform which the doodler is currently on
					sw $zero, ($t2)					# Remove the platform
					
					j fi_jumps
				else_hotOneJump: # Jump normally but set the platform to kill the player on the next landing
					addi $t1, $zero, 6
					sw   $t1, timeLeftInAir
				
					lw   $t2, doodlerY
					addi $t2, $t2, 8					# The offet to the platform which the doodler is standing on
					mul $t2, $t2, 4
					la $t2, platformPositions($t2)	# The address spesifing the platform which the doodler is currently on
					addi $t9, $zero, 5
					sb $t9, 1($t2)					# make the platform a type 2 hot
					j fi_jumps
				else_hotTwoJump: # Kill the player when it lands on the platform
					jal setGameStateToZero 	# Go to the menu
					j fi_jumps
				else_monsterJump: # Kill the monster and 'big jump' away
					addi $t1, $zero, 10
					sw   $t1, timeLeftInAir
				
					lw   $t2, doodlerY
					addi $t2, $t2, 8					# The offet to the platform which the doodler is standing on
					mul $t2, $t2, 4
					la $t2, platformPositions($t2)	# The address spesifing the platform which the doodler is currently on
					sw $zero, ($t2)					# Remove the platform
					
					j fi_jumps
				 else_rocket:
				 	addi $t1, $zero, 15				# Rocket Jump (15 units)
					sw   $t1, timeLeftInAir
				
					sw $zero, rocket				  # Activate the rocket drawing
				
					lw   $t2, doodlerY
					addi $t2, $t2, 8					# The offet to the platform which the doodler is standing on
					mul $t2, $t2, 4
					la $t2, platformPositions($t2)	# The address spesifing the platform which the doodler is currently on
					addi $t9, $zero, 5
					sb $zero, 1($t2)					# make the platform a regular
					
					j fi_jumps
				else_shield:	# Remove the item and get the ability
					addi $t1, $zero, 6		# Jump normally
					sw   $t1, timeLeftInAir
				
					sw $zero, shield			        # Activate the shield drawing
				
					lw   $t2, doodlerY
					addi $t2, $t2, 8					# The offet to the platform which the doodler is standing on
					mul $t2, $t2, 4
					la $t2, platformPositions($t2)	# The address spesifing the platform which the doodler is currently on
					addi $t9, $zero, 5
					sb $zero, 1($t2)					# make the platform a regular
				fi_jumps:
				
				# Increment the score by 1
				lw $t1, score
				addi $t1, $t1, 1
				sw $t1, score

				# Make a jump sound
				li $v0,31
				addi $a0, $zero, 75	# Pitch
				addi $a1, $zero, 150		# Duration (millis)
				addi $a2, $zero, 115		# Instrument (Steel drum)
				addi $a3, $zero, 70		# Volume
				syscall
				
				j fi_on_platform
			else_on_platform:
				# decrement your time left in the air by 1
				addi $t1, $t1, -1
				sw $t1, timeLeftInAir
				
				# Remove rocket pack since the doodelr is now falling
				bnez $t1, fi_on_platform
				if_upwards_velocity_is_zero:
					addi $t1, $zero, -1
					sw $t1, rocket
				fi_upwards_velocity_is_zero:
				j fi_on_platform
			fi_on_platform:
			
			# Updates the doodler if he hit a monster from the bottom i.e gets knocked down
			jal doodlerHitMonsterFromBelow
			
			# Checks if the doodler has fit the bottom row and the game is over
			jal isGameOver
			beqz $v0, fi_gameOver
			if_gameOver:
				jal setGameStateToZero 	# Go to the menu
			fi_gameOver:
			
			# Move doodler
			lw $t1, timeLeftInAir
			lw $t2, doodlerY
			bltz $t1, else_jumping
			if_jumping: # Currently moving up
				addi $t2, $t2, -1
				j fi_jumping
			else_jumping: # Curretnly falling
				addi $t2, $t2, 1
			fi_jumping:	
			sw $t2, doodlerY


		# Update location of platforms and other objects
		jal shiftPlatformsDownIfNeeded
		
		# Update the horizontal location of the platforms and monster
		jal movePlatformsHorizontally
		
		# Redraw the screen
			# Draw the blue background 
			draw (SCREEN_HEIGHT, SCREEN_WIDTH, 0, 0 skyArray)

			# Draw the screen differently depending on the game state (0 = menu, 1 = playing)
			lw $t0, gameState
			beqz  $t0, else_draw_gameElements
				# Draw the banner
				draw (8, SCREEN_WIDTH, 0, 0 bannerArray)
				
				# Draw platforms to buffer
				jal drawPlatforms
			
				# Draw the score on the screen
				jal drawScore
				j fi_draw_gameElements
			else_draw_gameElements:
				# Draw platforms to buffer
				jal drawPlatforms
				
				# Loads in the number of gamesPlayed
				lw   $t0, gamesPlayed

				# If gamesPlayed >= 1, then you have died so display gameOver
				bltz $t0, fi_gameLost
				if_gameLost:
					draw (16, 25, 1, 2 gameOverArray)
				fi_gameLost:
				draw (12, 27, 30, 1 clickSArray)
			fi_draw_gameElements:

			
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
			
			# Draw the shield if its active
			lw $t8, shield			# 0 or 4 mean the sheild is up, -1 means it is not
			bltz $t8, fi_shield
			if_shield:
				# Load in the X, Y and move up and left by 1 since the shield is just above the doodler
				lw $t1, doodlerY
				lw $t2, doodlerX
				addi $t1, $t1, -1
				addi $t2, $t2, -1
			
				# Load in either 0 or 1 
				lw $t9, shieldArrays+0($t8) 
				drawR(9,10,$t1, $t2, $t9)
			
				bnez $t8, else_shield_zero
				if_shield_zero:
					addi $t8, $zero, 4
					sw $t8, shield
					j fi_shield_zero
				else_shield_zero:
					addi $t8, $zero, 0
					sw $t8, shield
					j fi_shield_zero
				fi_shield_zero:
			fi_shield:
			
			
			# Draw the rocket pack, if it is active
			lw $t8, rocket			# 0 or 4 means the sheild is up, -1 means it is not
			bltz $t8, fi_rocket
			if_rocket:
				lw $t1, doodlerY			# Loads in the doodlers current position
				lw $t2, doodlerX
			
				lw $t3, hDirection		# Loads in the correct rocketpack into $t9 depending on the doodler's direction	
				mul $t3, $t3, 4
				lw $t9, rocketArrays($t3)
			
				addi $t1, $t1, -1		# The offset needs relative the the doodlers position
				addi $t2, $t2, -2
			
				drawR(6,12,$t1, $t2,$t9) # Draw the rocket pack
			fi_rocket:
			
			# Draw the bitmap display from the buffer
			jal copyFromDisplayBuffer
		
		# Play a note of music
		jal playNote
		
		
		# Sleep
		li $v0, 32
		li $a0, 3 # ~30 fps
		syscall
		
		j mainLoop
	
	exitLoop:
		# End the program
		li $v0, 10
		syscall 
#######################################################
playNote:
	lw $t9, noteDelay
	bne $t9, 2, exit_play_note		# Only play a note once every 2 main loop cycles
	add $t9, $zero, $zero			# Reset the noteDelay count to zero since a note is being played
	

	lw $t0, currentNote
	lw $t1, notesR($t0)
	lw $t2, notesL($t0)
	
	# Loop back to start of song if end (-1) is reached
	bne $t1, -1, fi_restart
	if_restart:
		addi $t0, $zero, 0
		lw $t1, notesR
		lw $t2, notesL
	fi_restart:

	# Either play a note or pause
	beqz $t1, else_pause
	if_pause:
		# Only play left if there is a note
		beqz $t2, fi_left
		if_left:
			li $v0,31
    			add $a0, $zero, $t2    	 	# Pitch
    			addi $a1, $zero, noteLen      # Duration (millis)
   	 		addi $a2, $zero,instrument    # Instrument
    			addi $a3, $zero, 34           # Volume
			syscall
		fi_left:
		
		# Right hand (There is never a right hand if left is pausing)
    		li $v0,31
    		add $a0, $zero, $t1     		# Pitch
    		addi $a1, $zero, noteLen      # Duration (millis)
   	 	addi $a2, $zero, instrument   # Instrument
    		addi $a3, $zero, 34           # Volume
		syscall
		
		j fi_pause
	else_pause:
		# take a pause for note length
		li $v0, 32
		addi $a0, $zero, noteLen
		#syscall
	
	fi_pause:

	addi $t0, $t0, 4
	sw $t0, currentNote

	exit_play_note:

	addi, $t9, $t9, 1		# Increment noteDelay
	sw $t9, noteDelay

	jr $ra
#######################################################
setGameStateToZero:	
	addi $t0, $zero, 0
	sw $t0, gameState 
	
	# Start menu X and Y position
	addi $t0, $zero, 11
	sw $t0, doodlerX 			# doodlerX = 11
	
	addi $t0, $zero, 50
	sw $t0, doodlerY 			# doodlerX = 11
	
	# Clear any active effects
	addi $t0, $zero, -1
	sw $t0, shield 			# shield = -1 (disabled)
	sw $t0, rocket 			# rocket = -1 (disabled)
	
	# Copy the start Menu platform positions to the platformPositions array
	la $t0, platformPositions
	la $t1, startMenuPlatformPosition
	
	add $t2, $zero, 252					# i = 252 (63*4)
	for_platform_copy_start_menu:				
		add $t3, $t0, $t2				# The address we're writing to
		add $t4, $t1, $t2				# The address we're reading from
		
		lw 	$t4, ($t4)                 # 1 word before the address, where we get the data
		sw  $t4, ($t3)					# t3 = arrayAdress + offset into array
		add $t2, $t2, -4						# i -= 4
		
		beq $t2, -4, exit_platform_copy_start_menu		# Exit if ==4	
		j for_platform_copy_start_menu
	exit_platform_copy_start_menu:
	jr $ra
	
#######################################################
setGameStateToOne:
	# Increment the number of games played
	lw   $t0, gamesPlayed
	addi $t0, $t0, 1
	sw $t0, gamesPlayed
	
	# Set the game state to 1
	addi $t0, $zero, 1
	sw $t0, gameState 

	add $t0, $zero , $zero

	sw $t0, hDirection			# hDirection=0
	sw $t0, score				# score = 0
	sw $t0, rowsSinceRandPlatform	# rowsSinceRandPlatform = 0

	addi $t0, $zero, 6
	sw $t0, doodlerX				# doodlerX = 6
	sw $t0, timeLeftInAir			# timeLeftInAir =6
	
	addi $t0, $zero, 50
	sw $t0, doodlerY 			# doodlerY = 50
	
	addi $t0, $zero, -1
	sw $t0, shield 			# shield = -1 (disabled)
	sw $t0, rocket 			# rocket = -1 (disabled)
	
	# Copy the initial platfrom positions to the platformPositions array
	la $t0, platformPositions
	la $t1, initialPlatformPositions
	
	add $t2, $zero, 252					# i = 252 (63*4)
	for_platform_copy:				
		add $t3, $t0, $t2				# The address we're writing to
		add $t4, $t1, $t2				# The address we're reading from
		
		lw 	$t4, ($t4)                 # 1 word before the address, where we get the data
		sw  $t4, ($t3)					# t3 = arrayAdress + offset into array
		add $t2, $t2, -4						# i -= 4
		
		beq $t2, -4, exit_platform_copy		# Exit if ==4	
		j for_platform_copy
	exit_platform_copy:
	jr $ra
	
#######################################################
drawScore:
	la $t9, numArray
	lw $t0, score				#t0 = current score
	
	add  $t1, $zero, $zero		# i = t1 = 0
	addi $t2, $zero, 1000		# t2 = 1000
	for_digit_in_score:
		beq $t1, 4, exit_digit_in_score
		
		div $t0, $t2				# $t3 = Score (with first i digits chopped off) // 10^i 
		
		mfhi $t0					# The remainder when dividing by 10^i
		mflo $t4					# The ith digit
		
		# Store the registers on the stack
		addi $sp, $sp, -20
	     sw   $ra, 0($sp)
	     sw   $t9, 4($sp)       
		 sw   $t0, 8($sp)
	     sw   $t1, 12($sp)
	     sw   $t2, 16($sp)
	      
	    # The offset into the numbers array of the current digit
	    mul $t4, $t4, 4
		add $t4, $t4, $t9
	     
	     # The x position of the number
	     mul  $t5,$t1, 4
	     addi $t5, $t5, 1
	     
	    # Draw the digit to the buffer array (We can't use the draw macro here since we don't pass in an bitmap label, but instead the address)
	    		addi $sp, $sp, -4
			addi $a0, $zero, 5
			addi $a1, $zero, 3
			add $a2, $zero, 1
			add $a3, $zero, $t5
			la $t0, ($t4)
			lw $t0, ($t0)
			sw $t0, 0($sp)
			jal drawBitMap    
			addi $sp, $sp, 4
	    
	    # Restore the values from the stack and dealocate the memory
	    lw   $ra, 0($sp)
	    lw   $t9, 4($sp)       
		lw   $t0, 8($sp)
	    lw   $t1, 12($sp)
	    lw   $t2, 16($sp)
	    addi $sp, $sp, 20
		
		div $t2, $t2, 10		# $t2  = $t2 /10
		addi $t1, $t1, 1		# i++
		j for_digit_in_score
	exit_digit_in_score:
		jr $ra
#######################################################
isGameOver:
	lw $t0, doodlerY
	sgt $v0, $t0, 55
	jr $ra
#######################################################
doodlerHitMonsterFromBelow:	
	lw $t0, doodlerX
	lw $t1, doodlerY
	la $t2, platformPositions
	
	mul $t3, $t1, 4									# Multiply by 4 (bytes) to get the correct mem address
	add $t3, $t3, $t2
	lb  $t9, 1($t3)									# Stores the platform type stored in array[i] 	
	lb  $t3, 0($t3)									# Store the value of platform array[i] byte 0 (The first byte is the platform position) in t3

	beq $t9, 7, if_possibleMonsterCollison
	bne $t9, 8, fi_possibleMonsterCollison									
	if_possibleMonsterCollison:
		addi $t3, $t3, -1 							# The x-value is off by 1 and so must be decremented to the correct value
		
		# IF X >= t3-8 AND X <+ t3 +(12-1) ==> COLLISON
		addi $t4, $t3, -7				#t4 = t3-8
		addi $t5, $t3, 11				#t5 = t3+11	
		sle $t4, $t4, $t0				# t4 = t3-8 <= X
		sle $t5, $t0, $t5				# t5 = X >= t3+12
		and $t3, $t4, $t5
		beqz $t3 fi_possibleMonsterCollison
		if_monsterDetected:
			lw $t9, shield				
			bltz $t9, fi_has_shield
			if_has_shield:
				addi $t9, $zero, -1
				sw $t9, shield					# Remove the shield
				j fi_possiblePlatformCollison		# Do not get knocked down
			fi_has_shield:
		
			addi $t0, $zero, -1							# If a monster is detected begin falling
			sw $t0, timeLeftInAir
			j fi_possiblePlatformCollison
	fi_possibleMonsterCollison:
	

	jr $ra
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
		lw $t2 rowsSinceRandPlatform
		
		
		# E(rowsSinceRandPlatform) = -rowsSinceRandPlatform + (regJumpHeight + 1)	This equation will be used to calculate the end random value for the chances to make a platform
		
		mul  $t5, $t2, -1						# $t5 = -rowsSinceRandPlatform	
		addi $t1, $zero, 6						# $t1 = (regJumpHeight + 1)
		
		add $t1, $t1, $t5						# t1 = E(rowsSinceRandPlatform)
		
		li  $v0, 42								# A random number between 1 to E(rowsSinceRandPlatform)
		li $a0, 0
		add $a1, $zero, $t1	
		syscall
		add $t1, $zero, $a0
		
		blt $t2, 5, else_makePlatform				# Never have platforms closer than 5 units apart
		bgt $t1, 1, else_makePlatform				# If you generate a 0/1, make a platform
		if_makePlatform:
			# The location of the platform
			li $v0, 42
			li $a0, 0
			li $a1, 19  # 31 -12
			syscall
			addi $t4, $a0,1
			
			# The type of platform
			li $v0, 42
			li $a0, 0
			li $a1, 99
			syscall
			
			# Apply the transformation from the uniformly distributed random number to the exponentially distributed one (A different distribution depending on the score)
			mul $t5, $a0, 4
			
			# Uses a differnt distribution, depending on the current score.
			lw $t9, score
			bgt $t9, 19, else_low_score
			if_low_score:
				lw $t5, distributionM+0($t5)
				j fi_low_score
			else_low_score:
				lw $t5, distributionH+0($t5)
				j fi_low_score
			fi_low_score:
				
			sb  $t4, 0($t0)	# Store the platform locatiom
			sb  $t5, 1($t0)	# store the platform type
		
			#Since brown platforms can't be jumped on, set rowsSinceRandPlatform to a 2 so its possible to keep playing
			bne $t5, 6, fi_brown
			if_brown:
				addi $t2, $zero, 2	
				j fi_makePlatform
			fi_brown:
			
			addi $t2, $zero, -1			# Sets the rows since random platform generation to 0
			j fi_makePlatform
		else_makePlatform:
			sw  $zero, 0($t0)			# Don't make a platform
		
		fi_makePlatform:
		addi $t2, $t2, 1
		sw $t2, rowsSinceRandPlatform
		
		
	fi_platforms_should_drop:
	jr $ra
#######################################################
movePlatformsHorizontally:
	add $t1, $zero, $zero
	for_platform_in_row:
		lb $t2, platformPositions+0($t1)		# Load the position of the platfrom (if there exits one)
		lb $t3, platformPositions+1($t1)		# Loads the platform type
		
		beq, $t3, 7, if_moving_platform_L		# Left moving mosnter
		bne, $t3, 2, else_moving_platform_R   # Not a left moving paltform
		if_moving_platform_L:
			# Move platfrom left by one, and if we hit the boundary switch its direction to right (6)
			addi $t2, $t2, -1
			
			bne $t2, 0, fi_left_side_reached
			if_left_side_reached:
				addi $t2, $zero, 1
				addi $t3, $t3, 1		# Switch to right moving
			fi_left_side_reached:
			j fi_moving_platform
		else_moving_platform_R:
		beq, $t3, 8, right_moving_monster
		bne, $t3, 3, fi_moving_platform
			right_moving_monster:
			# Move platfrom right by one, and if we hit the boundary switch its direction to right (6)
			addi $t2, $t2, 1

			bne $t2, 20, fi_right_side_reached
			if_right_side_reached:
				addi $t2, $zero, 21
				addi $t3, $t3, -1 		# Switch to left moving
			fi_right_side_reached:
		fi_moving_platform:
		# Store the updated values
		sb $t2, platformPositions+0($t1)
		sb $t3, platformPositions+1($t1)

		addi $t1, $t1, 4
		beq $t1, 256, exit_platform_in_row
		j for_platform_in_row
	exit_platform_in_row:
		jr $ra
#######################################################
doodlerOnPlatform:																										
	lw $t0, doodlerX
	lw $t1, doodlerY
	la $t2, platformPositions
	
	addi $t1, $t1, 8 								# Standing on a platform, means we need to look 8 units under the Y to see if we are on it
	mul $t3, $t1, 4									# Multiply by 4 (bytes) to get the correct mem address
	add $t3, $t3, $t2
	lb  $t9, 1($t3)									# Stores the platform type stored in array[i] 	
	lb  $t3, 0($t3)									# Store the value of platform array[i] byte 0 (The first byte is the platform position) in t3	


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
			li  $v0, 1			# You are on a platform
			add $v1, $zero, $t9	# Store the platform type in $v1
			
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
		lb  $t3, 1($t2)					# The type of platform being used
		add $s0, $t3, $zero				# A copy of the paltofrm type
		lb  $t2, ($t2)					# $t2 is the value of platformPositions[i]

		bnez  $t2, if_rowHasPlatform 				# If the value is non-zero then it is the x-coord for a platform in row i
		beqz  $t2, fi_rowHasPlatform 				# If the value is zero then there is no platform in this row
		if_rowHasPlatform:
			addi $t2, $t2, -1 					# The x-value is off by 1 and so must be decremented to the correct value
			
			addi $sp, $sp, -8					# Allocated stack space
	 		sw   $t0, ($sp) 						# Stores i on the stack
	 		sw   $t1, 4($sp)						# Stores platformPositions on the stack
			
			
			# Load the bitmap for the platform type being drawn into $t4
			la $t4, platformArrays
			mul $t3, $t3, 4
			add $t4, $t4, $t3
			lw $t4, ($t4)		# Loads the address into a register
			la $t4, ($t4)		# Loads the conents of the address
	
			
			# Draw the platform normally, unless its type > 8 --> It is a specials shape
			bgt $s0, 8, else_not_special
			if_not_special:
				drawR(2, PLATFORM_WIDTH, $t0,$t2,$t4)
				j fi_not_special
			else_not_special:
				addi $t9, $t0 -5						# Shift up to account for the special shape
				
				addi $t8, $zero, 7					# The height of the bitmap
				
				# Makes sure we don't draw over the top of the screen
				bgez $t9, fi_drawing_over_top
				if_drawing_over_top:
					add $t8, $t8, $t9	# The updated height of the bitmap
				
					mul $t5, $t9, -1		# The number of rows not to draw
					mul $t5, $t5, 48		# Each row is 48 bytes
					add $t4, $t4, $t5	# Offset the bitmap
				
					add $t9, $zero, $zero	# Draws at the top of the screen
					
				
				fi_drawing_over_top:
				
				drawR($t8, PLATFORM_WIDTH, $t9,$t2,$t4)
				j fi_not_special
			fi_not_special:	
	
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
