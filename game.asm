.data
    # Welcome to the code!
    # This is a simple turn-based RPG game written in MIPS assembly language.
    # The game allows two players to set up their characters and battle against each other.
    # Players can choose to attack, guard, or use a skill during their turn.
    # The game continues until one player is defeated.
    # Enjoy the game and feel free to modify it as you like!
    # Developed by Nash

    # Date: 2023-10-01
    # Version: 1.0
    # License: MIT
    # This code is provided as-is without any warranty. Use at your own risk.

    # How to play:
    # 1. Go to terminal and do (java -jar Mars4_5.jar game.asm) 
    # 2. Use MARS simulator to run the code.


    menu_title: .asciiz "\n=== TURN-BASED RPG GAME ===\n"
    menu_options: .asciiz "1. Play VERSUS\n2. Credits\n3. Quit\n"
    credits_msg1: .asciiz "\nGame developed by Nash. Enjoy!\n"
    quit_msg: .asciiz "\nThank you for playing!\n"

    # Skill and trait descriptions
    skill_list_part1: .asciiz "1. Fireball (+20 Attack)\n2. Heal (+30 HP)\n3. Shield (+15 Defense)\n"
    skill_list_part2: .asciiz "4. Double Strike (Attack Twice)\n5. Poison (Damage Over Time)\n"
    skill_list_part3: .asciiz "6. Stun (Skip Opponent's Turn)\n7. Counter (Reflect Damage)\n"
    skill_list_part4: .asciiz "8. Berserk (+50 Attack, -20 Defense)\n9. Regenerate (+10 HP/Turn)\n"
    skill_list_part5: .asciiz "10. Freeze (Opponent Can't Use Skills)\n"

    trait_list_part1: .asciiz "1. +10% Defense\n2. +10% Attack\n"
    trait_list_part2: .asciiz "3. First Turn Advantage\n4. Block One Attack\n"


    # Prompts
    choose_skills: .asciiz "Choose 3 skills by entering their numbers (1-10):\n"
    choose_traits: .asciiz "Choose 2 traits by entering their numbers (1-4):\n"
    invalid_choice: .asciiz "Invalid choice. Try again.\n"

    # Player selections
    player1_skills: .space 12  # 3 skills (4 bytes each)
    player2_skills: .space 12
    player1_traits: .space 8   # 2 traits (4 bytes each)
    player2_traits: .space 8

    newline: .asciiz "\n"
    
.text
main:
    # Display menu
    la $a0, menu_title
    li $v0, 4
    syscall

    la $a0, menu_options
    li $v0, 4
    syscall

    # Get user choice
    li $v0, 5
    syscall
    move $t0, $v0  # Store choice in $t0

    # Handle menu choice
    beq $t0, 1, play_versus
    beq $t0, 2, show_credits
    beq $t0, 3, quit_game
    j main  # Invalid choice, redisplay menu

play_versus:
    # Initialize player 1
    la $t0, player1_skills  # Load address of player1_skills into $t0
    la $t1, player1_traits  # Load address of player1_traits into $t1
    jal setup_player        # Call setup_player for Player 1

    # Initialize player 2
    la $t0, player2_skills  # Load address of player2_skills into $t0
    la $t1, player2_traits  # Load address of player2_traits into $t1
    jal setup_player        # Call setup_player for Player 2

    # Proceed to the game loop
    j game_loop

clear_console:
    li $t0, 20          # Number of newlines to print
clear_loop:
    la $a0, newline     # Load newline character
    li $v0, 4           # Print string syscall
    syscall
    subi $t0, $t0, 1    # Decrement counter
    bnez $t0, clear_loop
    jr $ra              # Return to caller

setup_player:
    addi $sp, $sp, -8    # Allocate space on the stack for 2 registers
    sw $t0, 0($sp)       # Save $t0 (skills array pointer)
    sw $t1, 4($sp)       # Save $t1 (traits array pointer)

    # Display skill list
    addi $sp, $sp, -4    # Allocate space for $ra
    sw $ra, 0($sp)       # Save return address
    jal clear_console     # Clear console
    lw $ra, 0($sp)       # Restore return address
    addi $sp, $sp, 4     # Deallocate space

    la $a0, skill_list_part1
    li $v0, 4
    syscall

    la $a0, skill_list_part2
    li $v0, 4
    syscall

    la $a0, skill_list_part3
    li $v0, 4
    syscall

    la $a0, skill_list_part4
    li $v0, 4
    syscall

    la $a0, skill_list_part5
    li $v0, 4
    syscall

    # Prompt for skills
    la $a0, choose_skills
    li $v0, 4
    syscall

    # Get 3 skill choices
    li $t2, 3           # Number of skills to pick
    lw $t0, 0($sp)      # Reload skills array pointer (was preserved on stack)
select_skills:
    li $v0, 5
    syscall
    blt $v0, 1, invalid_skill
    bgt $v0, 10, invalid_skill

    sw $v0, 0($t0)      # Store skill
    addi $t0, $t0, 4    # Move to the next skill slot
    subi $t2, $t2, 1
    bnez $t2, select_skills

    # Display trait list
    addi $sp, $sp, -4   # Allocate space for $ra
    sw $ra, 0($sp)      # Save return address
    jal clear_console    # Clear console
    lw $ra, 0($sp)      # Restore return address
    addi $sp, $sp, 4    # Deallocate space

    la $a0, trait_list_part1
    li $v0, 4
    syscall

    la $a0, trait_list_part2
    li $v0, 4
    syscall

    # Prompt for traits
    la $a0, choose_traits
    li $v0, 4
    syscall

    # Get 2 trait choices
    li $t2, 2           # Number of traits to pick
    lw $t1, 4($sp)      # Reload traits array pointer (was preserved on stack)
select_traits_loop:
    li $v0, 5
    syscall
    blt $v0, 1, invalid_trait
    bgt $v0, 4, invalid_trait
    sw $v0, 0($t1)      # Store trait
    addi $t1, $t1, 4    # Move to the next trait slot
    subi $t2, $t2, 1
    bnez $t2, select_traits_loop

    lw $t0, 0($sp)      # Restore $t0
    lw $t1, 4($sp)      # Restore $t1
    addi $sp, $sp, 8    # Deallocate space on the stack
    jr $ra

invalid_skill:
    la $a0, invalid_choice
    li $v0, 4
    syscall
    j select_skills

invalid_trait:
    la $a0, invalid_choice
    li $v0, 4
    syscall
    j select_traits_loop


show_credits:
    # Display credits
    la $a0, credits_msg1
    li $v0, 4
    syscall
    j main  # Return to menu

quit_game:
    # Display quit message and exit
    la $a0, quit_msg
    li $v0, 4
    syscall
    li $v0, 10
    syscall

game_loop:
    # Placeholder for game logic
    j main