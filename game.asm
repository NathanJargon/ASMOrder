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
    trait_list_part2: .asciiz "3. First Turn Advantage\n"


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

    # Battle messages
    player1_turn_msg: .asciiz "\n=== Player 1's Turn ===\n"
    player2_turn_msg: .asciiz "\n=== Player 2's Turn ===\n"
    health_status: .asciiz "\nPlayer 1 HP: 100 | Player 2 HP: 100\n"
    attack_msg: .asciiz " attacks!\n"
    guard_msg: .asciiz " guards!\n"
    skill_msg: .asciiz " uses a skill!\n"
    player1_wins: .asciiz "\nPlayer 1 wins!\n"
    player2_wins: .asciiz "\nPlayer 2 wins!\n"
    turn_options: .asciiz "1. Attack\n2. Guard\n3. Use Skill\nChoose action: "
    no_skills_msg: .asciiz "No skills available!\n"

    player1_attack_msg: .asciiz "Player 1"
    player2_attack_msg: .asciiz "Player 2"

    # Player stats
    player1_hp: .word 100
    player2_hp: .word 100
    player1_defense: .word 10
    player2_defense: .word 10
    player1_attack: .word 15
    player2_attack: .word 15

    # Skill effect messages
    fireball_msg: .asciiz " casts Fireball! +20 Attack this turn!\n"
    heal_msg: .asciiz " uses Heal! +30 HP!\n"
    shield_msg: .asciiz " uses Shield! +15 Defense this turn!\n"
    double_strike_msg: .asciiz " uses Double Strike! Attacks twice!\n"
    poison_msg: .asciiz " uses Poison! Enemy takes damage over time!\n"
    stun_msg: .asciiz " uses Stun! Enemy skips next turn!\n"
    counter_msg: .asciiz " uses Counter! Will reflect damage!\n"
    berserk_msg: .asciiz " uses Berserk! +50 Attack, -20 Defense!\n"
    regenerate_msg: .asciiz " uses Regenerate! +10 HP per turn!\n"
    freeze_msg: .asciiz " uses Freeze! Enemy can't use skills next turn!\n"

    # Battle log messages
    battle_log_header: .asciiz "\n======== BATTLE LOG ========\n"
    battle_log_footer: .asciiz "===========================\n"
    damage_dealt_msg: .asciiz " dealt "
    damage_to_msg: .asciiz " damage to "
    hp_restored_msg: .asciiz " restored "
    hp_msg: .asciiz " HP!\n"
    defense_up_msg: .asciiz " increased defense by "
    attack_up_msg: .asciiz " increased attack by "
    newline_spaces: .asciiz "\n                         "

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
    addi $sp, $sp, -12    # Allocate space for 3 registers
    sw $t0, 0($sp)        # Save $t0 (skills array pointer)
    sw $t1, 4($sp)        # Save $t1 (traits array pointer)
    sw $s0, 8($sp)        # Save $s0 for temporary storage

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

    # Get 3 unique skill choices
    li $t2, 3           # Number of skills to pick
    lw $t0, 0($sp)      # Reload skills array pointer
    move $s0, $t0       # Keep original pointer in $s0

select_skills:
    li $v0, 5
    syscall
    blt $v0, 1, invalid_skill
    bgt $v0, 10, invalid_skill
    
    # Check if skill already chosen
    move $t3, $s0       # Start of array
    li $t4, 0           # Counter
skill_check_loop:
    beq $t4, $t2, skill_check_done  # Reached current count
    lw $t5, 0($t3)      # Load stored skill
    beq $t5, $v0, skill_already_chosen
    addi $t3, $t3, 4
    addi $t4, $t4, 1
    j skill_check_loop
    
skill_already_chosen:
    la $a0, invalid_choice
    li $v0, 4
    syscall
    j select_skills

skill_check_done:
    sw $v0, 0($t0)      # Store unique skill
    addi $t0, $t0, 4    # Move to next slot
    subi $t2, $t2, 1
    bnez $t2, select_skills

    # Display trait list
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

    # Get 2 unique trait choices
    li $t2, 2           # Number of traits to pick
    lw $t1, 4($sp)      # Reload traits array pointer
    move $s0, $t1       # Keep original pointer in $s0
    
select_traits_loop:
    li $v0, 5
    syscall
    blt $v0, 1, invalid_trait
    bgt $v0, 3, invalid_trait
    
    # Check if trait already chosen
    move $t3, $s0       # Start of array
    li $t4, 0           # Counter
trait_check_loop:
    beq $t4, $t2, trait_check_done  # Reached current count
    lw $t5, 0($t3)      # Load stored trait
    beq $t5, $v0, trait_already_chosen
    addi $t3, $t3, 4
    addi $t4, $t4, 1
    j trait_check_loop
    
trait_already_chosen:
    la $a0, invalid_choice
    li $v0, 4
    syscall
    j select_traits_loop
    
trait_check_done:
    sw $v0, 0($t1)      # Store unique trait
    addi $t1, $t1, 4    # Move to next slot
    subi $t2, $t2, 1
    bnez $t2, select_traits_loop

    lw $t0, 0($sp)      # Restore $t0
    lw $t1, 4($sp)      # Restore $t1
    lw $s0, 8($sp)      # Restore $s0
    addi $sp, $sp, 12   # Deallocate space
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
    # Initialize player stats
    li $t0, 100
    sw $t0, player1_hp
    sw $t0, player2_hp
    li $t0, 10
    sw $t0, player1_defense
    sw $t0, player2_defense
    li $t0, 15
    sw $t0, player1_attack
    sw $t0, player2_attack

    # Game loop
game_round:
    # Check if game over
    lw $t0, player1_hp
    blez $t0, player2_wins_game
    lw $t0, player2_hp
    blez $t0, player1_wins_game

    # Player 1s turn
    la $a0, player1_turn_msg
    li $v0, 4
    syscall
    jal display_health
    jal player_turn
    move $s0, $v0  # Save action choice

    # Apply Player 1s action
    li $a0, 1      # Player 1
    move $a1, $s0  # Action
    jal apply_action

    # Check if game over after Player 1s turn
    lw $t0, player2_hp
    blez $t0, player1_wins_game

    # Player 2s turn
    la $a0, player2_turn_msg
    li $v0, 4
    syscall
    jal display_health
    jal player_turn
    move $s0, $v0  # Save action choice

    # Apply Player 2s action
    li $a0, 2      # Player 2
    move $a1, $s0  # Action
    jal apply_action

    j game_round

player1_wins_game:
    la $a0, player1_wins
    li $v0, 4
    syscall
    j main

player2_wins_game:
    la $a0, player2_wins
    li $v0, 4
    syscall
    j main

display_health:
    la $a0, health_status
    li $v0, 4
    syscall
    
    # Display Player 1 HP
    lw $a0, player1_hp
    li $v0, 1
    syscall
    
    la $a0, newline
    li $v0, 4
    syscall
    
    # Display Player 2 HP
    lw $a0, player2_hp
    li $v0, 1
    syscall
    
    la $a0, newline
    li $v0, 4
    syscall
    
    jr $ra

player_turn:
    # Display options
    la $a0, turn_options
    li $v0, 4
    syscall

    # Get player choice
    li $v0, 5
    syscall

    # Validate choice
    blt $v0, 1, invalid_turn_choice
    bgt $v0, 3, invalid_turn_choice

    jr $ra

invalid_turn_choice:
    la $a0, invalid_choice
    li $v0, 4
    syscall
    j player_turn

apply_action:
    # $a0 = player number (1 or 2)
    # $a1 = action (1=attack, 2=guard, 3=skill)
    
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    beq $a1, 1, do_attack
    beq $a1, 2, do_guard
    beq $a1, 3, do_skill
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

do_attack:
    # Determine attacker and defender
    li $t0, 1
    beq $a0, $t0, player1_attacks
    
    # Player 2 attacks
    la $a0, player2_attack_msg
    li $v0, 4
    syscall
    
    lw $t0, player2_attack  # Attack power
    lw $t1, player1_defense # Defense
    
    # Calculate damage (attack - defense, minimum 1)
    sub $t2, $t0, $t1
    blez $t2, minimal_damage
    j apply_damage_player1
    
minimal_damage:
    li $t2, 1
    
apply_damage_player1:
    lw $t3, player1_hp
    sub $t3, $t3, $t2
    sw $t3, player1_hp
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
    
player1_attacks:
    la $a0, player1_attack_msg
    li $v0, 4
    syscall
    
    lw $t0, player1_attack  # Attack power
    lw $t1, player2_defense # Defense
    
    # Calculate damage (attack - defense, minimum 1)
    sub $t2, $t0, $t1
    blez $t2, minimal_damage2
    j apply_damage_player2
    
minimal_damage2:
    li $t2, 1
    
apply_damage_player2:
    lw $t3, player2_hp
    sub $t3, $t3, $t2
    sw $t3, player2_hp
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

do_guard:
    # Increase defense for this turn
    li $t0, 1
    beq $a0, $t0, player1_guards
    
    # Player 2 guards
    la $a0, guard_msg
    li $v0, 4
    syscall
    
    lw $t0, player2_defense
    addi $t0, $t0, 5  # Add 5 to defense when guarding
    sw $t0, player2_defense
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
    
player1_guards:
    la $a0, guard_msg
    li $v0, 4
    syscall
    
    lw $t0, player1_defense
    addi $t0, $t0, 5  # Add 5 to defense when guarding
    sw $t0, player1_defense
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

do_skill:
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $a0, 4($sp)   # Save player number
    sw $a1, 8($sp)   # Save action

    # Determine which players skills to show
    lw $t0, 4($sp)   # Load player number
    li $t1, 1
    beq $t0, $t1, show_player1_skills
    
    # Show Player 2 skills
    la $t2, player2_skills
    j display_skills
    
show_player1_skills:
    la $t2, player1_skills
    
display_skills:
    # Display available skills
    la $a0, newline
    li $v0, 4
    syscall
    
    # Skill 1
    lw $a0, 0($t2)
    jal print_skill_name
    la $a0, newline
    li $v0, 4
    syscall
    
    # Skill 2
    lw $a0, 4($t2)
    jal print_skill_name
    la $a0, newline
    li $v0, 4
    syscall
    
    # Skill 3
    lw $a0, 8($t2)
    jal print_skill_name
    la $a0, newline
    li $v0, 4
    syscall
    
    # Prompt for skill choice
    la $a0, choose_skills
    li $v0, 4
    syscall
    
    # Get skill choice (1-3)
    li $v0, 5
    syscall
    
    # Validate input (1-3)
    blt $v0, 1, invalid_skill_choice
    bgt $v0, 3, invalid_skill_choice
    
    # Calculate skill address (0, 4, or 8)
    addi $v0, $v0, -1
    sll $v0, $v0, 2
    add $t2, $t2, $v0
    lw $a0, 0($t2)  # Load skill ID
    
    # Apply the skill
    lw $a1, 4($sp)  # Load player number
    jal apply_skill_effect
    
    lw $ra, 0($sp)
    addi $sp, $sp, 12
    jr $ra

invalid_skill_choice:
    la $a0, invalid_choice
    li $v0, 4
    syscall
    j display_skills

print_skill_name:
    # $a0 contains skill ID
    li $t0, 1
    beq $a0, $t0, print_fireball
    li $t0, 2
    beq $a0, $t0, print_heal
    li $t0, 3
    beq $a0, $t0, print_shield
    li $t0, 4
    beq $a0, $t0, print_double_strike
    li $t0, 5
    beq $a0, $t0, print_poison
    li $t0, 6
    beq $a0, $t0, print_stun
    li $t0, 7
    beq $a0, $t0, print_counter
    li $t0, 8
    beq $a0, $t0, print_berserk
    li $t0, 9
    beq $a0, $t0, print_regenerate
    li $t0, 10
    beq $a0, $t0, print_freeze
    jr $ra

print_fireball:
    la $a0, fireball_msg
    j print_skill_msg
print_heal:
    la $a0, heal_msg
    j print_skill_msg
print_shield:
    la $a0, shield_msg
    j print_skill_msg
print_double_strike:
    la $a0, double_strike_msg
    j print_skill_msg
print_poison:
    la $a0, poison_msg
    j print_skill_msg
print_stun:
    la $a0, stun_msg
    j print_skill_msg
print_counter:
    la $a0, counter_msg
    j print_skill_msg
print_berserk:
    la $a0, berserk_msg
    j print_skill_msg
print_regenerate:
    la $a0, regenerate_msg
    j print_skill_msg
print_freeze:
    la $a0, freeze_msg
    j print_skill_msg

print_skill_msg:
    li $v0, 4
    syscall
    jr $ra

apply_skill_effect:
    # $a0 = skill ID
    # $a1 = player number (1 or 2)
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $a0, 4($sp)   # Save skill ID
    sw $a1, 8($sp)   # Save player number
    
    # Display battle log header
    la $a0, battle_log_header
    li $v0, 4
    syscall
    
    # Display player name
    lw $a0, 8($sp)
    li $t1, 1
    beq $a0, $t1, print_player1_name
    la $a0, player2_attack_msg
    j print_player_done
print_player1_name:
    la $a0, player1_attack_msg
print_player_done:
    li $v0, 4
    syscall
    
    # Apply skill effect based on ID
    lw $a0, 4($sp)   # Reload skill ID
    li $t0, 1
    beq $a0, $t0, skill_fireball
    li $t0, 2
    beq $a0, $t0, skill_heal
    li $t0, 3
    beq $a0, $t0, skill_shield
    li $t0, 4
    beq $a0, $t0, skill_double_strike
    li $t0, 5
    beq $a0, $t0, skill_poison
    li $t0, 6
    beq $a0, $t0, skill_stun
    li $t0, 7
    beq $a0, $t0, skill_counter
    li $t0, 8
    beq $a0, $t0, skill_berserk
    li $t0, 9
    beq $a0, $t0, skill_regenerate
    li $t0, 10
    beq $a0, $t0, skill_freeze
    
skill_done:
    # Display battle log footer
    la $a0, battle_log_footer
    li $v0, 4
    syscall
    
    la $a0, newline_spaces
    li $v0, 4
    syscall
    
    lw $ra, 0($sp)
    addi $sp, $sp, 12
    jr $ra

skill_fireball:
    la $a0, fireball_msg
    li $v0, 4
    syscall
    
    lw $t0, 8($sp)   # Player number
    li $t1, 1
    beq $t0, $t1, fireball_player1
    
    # Player 2 gets +20 attack
    lw $t0, player2_attack
    addi $t0, $t0, 20
    sw $t0, player2_attack
    j skill_done
    
fireball_player1:
    # Player 1 gets +20 attack
    lw $t0, player1_attack
    addi $t0, $t0, 20
    sw $t0, player1_attack
    j skill_done

skill_heal:
    la $a0, heal_msg
    li $v0, 4
    syscall
    
    lw $t0, 8($sp)   # Player number
    li $t1, 1
    beq $t0, $t1, heal_player1
    
    # Player 2 heals 30 HP (cap at 100)
    lw $t0, player2_hp
    addi $t0, $t0, 30
    li $t1, 100
    ble $t0, $t1, no_cap_p2
    move $t0, $t1
no_cap_p2:
    sw $t0, player2_hp
    j skill_done
    
heal_player1:
    # Player 1 heals 30 HP (cap at 100)
    lw $t0, player1_hp
    addi $t0, $t0, 30
    li $t1, 100
    ble $t0, $t1, no_cap_p1
    move $t0, $t1
no_cap_p1:
    sw $t0, player1_hp
    j skill_done

skill_shield:
    la $a0, shield_msg
    li $v0, 4
    syscall
    
    lw $t0, 8($sp)   # Player number
    li $t1, 1
    beq $t0, $t1, shield_player1
    
    # Player 2 gets +15 defense
    lw $t0, player2_defense
    addi $t0, $t0, 15
    sw $t0, player2_defense
    j skill_done

shield_player1:
    # Player 1 gets +15 defense
    lw $t0, player1_defense
    addi $t0, $t0, 15
    sw $t0, player1_defense
    j skill_done

skill_double_strike:
    la $a0, double_strike_msg
    li $v0, 4
    syscall
    
    # Attack twice by calling do_attack twice
    lw $a0, 8($sp)   # Player number
    li $a1, 1        # Attack action
    jal apply_action
    lw $a0, 8($sp)   # Player number
    li $a1, 1        # Attack action
    jal apply_action
    j skill_done

skill_poison:
    la $a0, poison_msg
    li $v0, 4
    syscall
    
    lw $t0, 8($sp)   # Player number
    li $t1, 1
    beq $t0, $t1, poison_player2  # Player 1 poisons player 2
    
    # Player 2 poisons player 1
    lw $t0, player1_hp
    subi $t0, $t0, 5
    sw $t0, player1_hp
    j skill_done

poison_player2:
    # Player 1 poisons player 2
    lw $t0, player2_hp
    subi $t0, $t0, 5
    sw $t0, player2_hp
    j skill_done

skill_berserk:
    la $a0, berserk_msg
    li $v0, 4
    syscall
    
    lw $t0, 8($sp)   # Player number
    li $t1, 1
    beq $t0, $t1, berserk_player1
    
    # Player 2 gets +50 attack, -20 defense
    lw $t0, player2_attack
    addi $t0, $t0, 50
    sw $t0, player2_attack
    
    lw $t0, player2_defense
    subi $t0, $t0, 20
    sw $t0, player2_defense
    j skill_done

berserk_player1:
    # Player 1 gets +50 attack, -20 defense
    lw $t0, player1_attack
    addi $t0, $t0, 50
    sw $t0, player1_attack
    
    lw $t0, player1_defense
    subi $t0, $t0, 20
    sw $t0, player1_defense
    j skill_done

skill_counter:
    la $a0, counter_msg
    li $v0, 4
    syscall
    
    # Set counter flag (would need to implement this properly)
    j skill_done

skill_freeze:
    la $a0, freeze_msg
    li $v0, 4
    syscall
    
    lw $t0, 8($sp)   # Player number
    li $t1, 1
    beq $t0, $t1, freeze_player2
    
    # Player 2 freezes player 1 (set flag)
    j skill_done

freeze_player2:
    # Player 1 freezes player 2 (set flag)
    j skill_done

skill_stun:
    la $a0, stun_msg
    li $v0, 4
    syscall
    
    lw $t0, 8($sp)   # Player number
    li $t1, 1
    beq $t0, $t1, stun_player2
    
    # Player 2 stuns player 1 (set flag)
    j skill_done

stun_player2:
    # Player 1 stuns player 2 (set flag)
    j skill_done

skill_regenerate:
    la $a0, regenerate_msg
    li $v0, 4
    syscall
    
    lw $t0, 8($sp)   # Player number
    li $t1, 1
    beq $t0, $t1, regenerate_player1
    
    # Player 2 regenerates HP (cap at 100)
    lw $t0, player2_hp
    addi $t0, $t0, 10
    li $t1, 100
    ble $t0, $t1, no_cap_p2_reg
    move $t0, $t1
no_cap_p2_reg:
    sw $t0, player2_hp
    j skill_done

regenerate_player1:
    # Player 1 regenerates HP (cap at 100)
    lw $t0, player1_hp
    addi $t0, $t0, 10
    li $t1, 100
    ble $t0, $t1, no_cap_p1_reg
    move $t0, $t1
no_cap_p1_reg:
    sw $t0, player1_hp
    j skill_done

# Add this to the end of apply_action (do_attack section)
add_battle_log:
    # Display battle log header
    la $a0, battle_log_header
    li $v0, 4
    syscall
    
    # Display attacker name
    lw $t0, 8($sp)   # Player number
    li $t1, 1
    beq $t0, $t1, log_player1_attack
    
    # Player 2 attacked
    la $a0, player2_attack_msg
    li $v0, 4
    syscall
    j log_damage
    
log_player1_attack:
    la $a0, player1_attack_msg
    li $v0, 4
    syscall
    
log_damage:
    # Display damage dealt
    la $a0, damage_dealt_msg
    li $v0, 4
    syscall
    
    move $a0, $t2    # Damage amount
    li $v0, 1
    syscall
    
    la $a0, damage_to_msg
    li $v0, 4
    syscall
    
    # Display defender name
    lw $t0, 8($sp)   # Player number
    li $t1, 1
    beq $t0, $t1, log_player2_defend
    
    # Player 1 defended
    la $a0, player1_attack_msg
    li $v0, 4
    syscall
    j log_end
    
log_player2_defend:
    la $a0, player2_attack_msg
    li $v0, 4
    syscall
    
log_end:
    la $a0, newline
    li $v0, 4
    syscall
    
    # Display battle log footer
    la $a0, battle_log_footer
    li $v0, 4
    syscall
    
    la $a0, newline_spaces
    li $v0, 4
    syscall
    
    jr $ra