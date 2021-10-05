#
# FILE:        $connect4$
# AUTHOR:      S. Bahdah
#

#
# DATA AREAS
#
        .data
        .align  2   # word data must be on word boundaries

# 
print_welcome:
        .ascii  "   ************************\n"
        .ascii  "   **    Connect Four    **\n"
        .asciiz "   ************************\n"

grid_intro:
        .asciiz "   0   1   2   3   4   5   6\n"
grid_core:
        .ascii  "+-----------------------------+\n"
        .ascii  "|+---+---+---+---+---+---+---+|\n"
        .ascii  "||   |   |   |   |   |   |   ||\n"
        .ascii  "|+---+---+---+---+---+---+---+|\n"
        .ascii  "||   |   |   |   |   |   |   ||\n"
        .ascii  "|+---+---+---+---+---+---+---+|\n"
        .ascii  "||   |   |   |   |   |   |   ||\n"
        .ascii  "|+---+---+---+---+---+---+---+|\n"
        .ascii  "||   |   |   |   |   |   |   ||\n"
        .ascii  "|+---+---+---+---+---+---+---+|\n"
        .ascii  "||   |   |   |   |   |   |   ||\n"
        .ascii  "|+---+---+---+---+---+---+---+|\n"
        .ascii  "||   |   |   |   |   |   |   ||\n"
        .ascii  "|+---+---+---+---+---+---+---+|\n"
        .asciiz "+-----------------------------+\n"
grid_end:
        .asciiz "   0   1   2   3   4   5   6\n"


grid_location:
        .word 67, 71, 75, 79, 83, 87, 91
        .word 131, 135, 139, 143, 147, 151, 155
        .word 195, 199, 203, 207, 211, 215, 219
        .word 259, 263, 267, 271, 275, 279, 283
        .word 323, 327, 331, 335, 339, 343, 347
        .word 387, 391, 395, 399, 403, 407, 411


print_newline:
        .asciiz "\n"
print_space:
        .asciiz " "
print_player_one:
        .asciiz "\nPlayer 1: select a row to place your coin (0-6 or -1 to quit):"
print_player_two:
        .asciiz "\nPlayer 2: select a row to place your coin (0-6 or -1 to quit):"
print_illegal_number:
        .asciiz "Illegal column number."
print_no_room:
        .asciiz "Illegal move, no more room in that column."
print_tie:
        .asciiz "The game ends in a tie.\n"
print_one_winner:
        .asciiz "\nPlayer 1 wins!\n"
print_two_winner:
        .asciiz "\nPlayer 2 wins!\n"
print_one_quit:
        .asciiz "Player 1 quit.\n"
print_two_quit:
        .asciiz "Player 2 quit.\n"


#
# CODE AREAS
#
        .text         # this is program code
        .align  2     # instructions must be on word boundaries
        
        .globl  main  # main is the global label. program starts here



#
# Name:    main
#

LENGTH = 42
FRAMESIZE_48 = 48
PRINT_INT = 1    # code for syscall to print integer
PRINT_STRING = 4 # code for syscall to print a string
READ_INT = 5     # code for syscall to read an integer

main:
        # allocate stack frame
        addi  $sp, $sp, -FRAMESIZE_48
        sw    $ra, -4+FRAMESIZE_48($sp)
        sw    $s7, -8+FRAMESIZE_48($sp)
        sw    $s6, -12+FRAMESIZE_48($sp)
        sw    $s5, -16+FRAMESIZE_48($sp)
        sw    $s4, -20+FRAMESIZE_48($sp)
        sw    $s3, -24+FRAMESIZE_48($sp)
        sw    $s2, -28+FRAMESIZE_48($sp)
        sw    $s1, -32+FRAMESIZE_48($sp)
        sw    $s0, -36+FRAMESIZE_48($sp)

        jal   display_intro
        
        ## player toggle
        # zero is player 1
        # one  is player 2
        addi  $s0, $zero, 0
        jal   play_game_zero

        

        # end the program

        lw    $ra, -4+FRAMESIZE_48($sp)
        lw    $s7, -8+FRAMESIZE_48($sp)
        lw    $s6, -12+FRAMESIZE_48($sp)
        lw    $s5, -16+FRAMESIZE_48($sp)
        lw    $s4, -20+FRAMESIZE_48($sp)
        lw    $s3, -24+FRAMESIZE_48($sp)
        lw    $s2, -28+FRAMESIZE_48($sp)
        lw    $s1, -32+FRAMESIZE_48($sp)
        lw    $s0, -36+FRAMESIZE_48($sp)

        addi  $sp, $sp, FRAMESIZE_48
        jr    $ra   # return from main and exit

#
# start the game
#

play_game_zero:
        addi  $sp, $sp, -4
        sw    $ra, 0($sp)
        addi  $s7, $zero, 0    # counter for tie
        addi  $s6, $zero, 42

        j     play_game_one

play_game_one:
        # print player message
        beq   $s0, $zero, player_one_message
        j     player_two_message

player_one_message:
        # print player one
        li    $v0, PRINT_STRING
        la    $a0, print_player_one
        syscall
        j     play_game_two

player_two_message:
        # print player two
        li    $v0, PRINT_STRING
        la    $a0, print_player_two
        syscall
        j     play_game_two

play_game_two:
        # get user input
        la    $v0, READ_INT
        syscall
        move  $s1, $v0  #store user input

# check if player quits
        addi  $t0, $zero, -1
        beq   $s1, $t0, player_quits

# check valid range
        addi  $t0, $zero, -1
        addi  $t1, $zero, 6
# if 6 < input
        slt   $t1, $t1, $s1
        bne   $t1, $zero, not_valid_input
# if input < -1
        slt   $t0, $s1, $t0
        bne   $t0, $zero, not_valid_input

# check valid spot in col
        jal   check_valid_col
        # s2: is there space? s3: the address of value change
        bne   $s2, $zero, no_room
        # s2 no longer important after here
        # can reuse t0-9 from here

# add token based on player
        beq   $s0, $zero, place_x
        j     place_o

place_x:
        # player 1: X
        # add X to the blank
        addi  $t0, $zero, 88
        sb    $t0, 0($s3)     # change to 'X'
        addi  $s7, $s7, 1
        j     play_game_three

place_o:
        # player 2: O
        # add O to the blank
        addi  $t0, $zero, 79
        sb    $t0, 0($s3)     # change to 'O'
        addi  $s7, $s7, 1
        j     play_game_three


play_game_three:
        # display the board
        jal   display_board

# check tie condition
        beq   $s7, $s6, tie_and_end

# check winning condition

        # set a0 as player toggle
        move  $a0, $s0
        jal win_start
        # get v0 for win case
        beq   $v0, $zero, player_wins    # win



        j     play_game_four

play_game_four:
# change player and end turn
        beq   $s0, $zero, goto_player_two
        j     goto_player_one

goto_player_one:
        addi  $s0, $zero, 0
        j     play_game_one

goto_player_two:
        addi  $s0, $zero, 1
        j     play_game_one










# a0: player toggle
# check win condition
# v0: win
win_start:
        addi  $sp, $sp, -FRAMESIZE_48
        sw    $ra, -4+FRAMESIZE_48($sp)
        sw    $s7, -8+FRAMESIZE_48($sp)
        sw    $s6, -12+FRAMESIZE_48($sp)
        sw    $s5, -16+FRAMESIZE_48($sp)
        sw    $s4, -20+FRAMESIZE_48($sp)
        sw    $s3, -24+FRAMESIZE_48($sp)
        sw    $s2, -28+FRAMESIZE_48($sp)
        sw    $s1, -32+FRAMESIZE_48($sp)
        sw    $s0, -36+FRAMESIZE_48($sp)

        addi  $s0, $zero, 6   # row
        addi  $s1, $zero, 7   # col


        beq   $a0, $zero, win_x

        j     win_o
#
# toggle player
#
win_x:
        addi  $s2, $zero, 88  # X
        j     hor_loop_zero

win_o:
        addi  $s2, $zero, 79  # O 
        j     hor_loop_zero

#
# Check horizontal locations for win
#
hor_loop_zero:
        # set counter for row and col
        addi  $s5, $s1, -3
        addi  $s6, $zero, 0 # counter row
        addi  $s7, $zero, 0 # counter col

        j     hor_loop_one

hor_loop_one:
        # col
        beq   $s7, $s5, end_hor_loop_one
        j     hor_loop_two


hor_loop_two:
        # row
        beq   $s6, $s0, end_hor_loop_two
        j     hor_if_one

#####
# the if statements
hor_if_one:
# math (7 * r) + c + 0
        mult  $s1, $s6    # (7 * counter row)
        mflo  $t0
        add   $t0, $t0, $s7  # result + counter col
        addi  $t0, $t0, 0   # result + 0
        addi  $t1, $zero, 4   #4 bytes
        mult  $t0, $t1
        mflo  $t0
# get value from address
        la    $t2, grid_location
        add   $t0, $t0, $t2
        lw    $t0, 0($t0)      # grid location
        la    $t2, grid_core
        add   $t0, $t0, $t2
        lb    $t0, 0($t0)      # grid core char value
# compare value: t0 is value from board
        beq   $t0, $s2, hor_if_two

        j     hor_else

hor_if_two:
# math (7 * r) + c + 1
        mult  $s1, $s6    # (7 * counter row)
        mflo  $t0
        add   $t0, $t0, $s7  # result + counter col
        addi  $t0, $t0, 1   # result + 1
        addi  $t1, $zero, 4   #4 bytes
        mult  $t0, $t1
        mflo  $t0
# get value from address
        la    $t2, grid_location
        add   $t0, $t0, $t2
        lw    $t0, 0($t0)      # grid location
        la    $t2, grid_core
        add   $t0, $t0, $t2
        lb    $t0, 0($t0)      # grid core char value
# compare value: t0 is value from board
        beq   $t0, $s2, hor_if_three
        j     hor_else

hor_if_three:
# math (7 * r) + c + 2
        mult  $s1, $s6    # (7 * counter row)
        mflo  $t0
        add   $t0, $t0, $s7  # result + counter col
        addi  $t0, $t0, 2   # result + 2
        addi  $t1, $zero, 4   #4 bytes
        mult  $t0, $t1
        mflo  $t0
# get value from address
        la    $t2, grid_location
        add   $t0, $t0, $t2
        lw    $t0, 0($t0)      # grid location
        la    $t2, grid_core
        add   $t0, $t0, $t2
        lb    $t0, 0($t0)      # grid core char value
# compare value: t0 is value from board
        beq   $t0, $s2, hor_if_four
        j     hor_else

hor_if_four:
# math (7 * r) + c + 3
        mult  $s1, $s6    # (7 * counter row)
        mflo  $t0
        add   $t0, $t0, $s7  # result + counter col
        addi  $t0, $t0, 3   # result + 3
        addi  $t1, $zero, 4   #4 bytes
        mult  $t0, $t1
        mflo  $t0
# get value from address
        la    $t2, grid_location
        add   $t0, $t0, $t2
        lw    $t0, 0($t0)      # grid location
        la    $t2, grid_core
        add   $t0, $t0, $t2
        lb    $t0, 0($t0)      # grid core char value
# compare value: t0 is value from board
        beq   $t0, $s2, hor_if_true
        j     hor_else

#####
hor_else:
        addi  $s6, $s6, 1
        j     hor_loop_two


end_hor_loop_two:
        addi  $s7, $s7, 1
        addi  $s6, $zero, 0

        j     hor_loop_one

end_hor_loop_one:
        # move on to the next check: vertical
        j     ver_loop_zero

hor_if_true:
        addi  $v0, $zero, 0
        j     win_end

#
# Check vertical locations for win
#
ver_loop_zero:
        # set counter for row and col
        addi  $s0, $zero, 6  # row
        addi  $s1, $zero, 7   # col
        addi  $s5, $s0, -3     # row - 3
        addi  $s6, $zero, 0  # counter row
        addi  $s7, $zero, 0  # counter col
        j     ver_loop_one

ver_loop_one:
        # col
        beq  $s7, $s1, end_ver_loop_one
        j    ver_loop_two

ver_loop_two:
        # row
        beq  $s6, $s5, end_ver_loop_two


# the if statements
ver_if_one:
# do math to $t0: (7 * (r + 0)) + c
        addi  $t0, $zero, 0
        add   $t0, $t0, $s6  # r + 0
        mult  $t0, $s1        # result * 7
        mflo  $t0
        add   $t0, $t0, $s7  # result + c
        addi  $t1, $zero, 4   #4 bytes
        mult  $t0, $t1
        mflo  $t0
# get value from address
        la    $t2, grid_location
        add   $t0, $t0, $t2
        lw    $t0, 0($t0)      # grid location
        la    $t2, grid_core
        add   $t0, $t0, $t2
        lb    $t0, 0($t0)      # grid core char value
# compare value: t0
        beq  $t0, $s2, ver_if_two
        j    ver_else


ver_if_two:
# do math to $t0: (7 * (r + 1)) + c
        addi  $t0, $zero, 1
        add   $t0, $t0, $s6  # r + 0
        mult  $t0, $s1        # result * 7
        mflo  $t0
        add   $t0, $t0, $s7  # result + c
        addi  $t1, $zero, 4   #4 bytes
        mult  $t0, $t1
        mflo  $t0
# get value from address
        la    $t2, grid_location
        add   $t0, $t0, $t2
        lw    $t0, 0($t0)      # grid location
        la    $t2, grid_core
        add   $t0, $t0, $t2
        lb    $t0, 0($t0)      # grid core char value
# compare value: t0
        beq  $t0, $s2, ver_if_three
        j    ver_else


ver_if_three:
# do math to $t0: (7 * (r + 2)) + c
        addi  $t0, $zero, 2
        add   $t0, $t0, $s6  # r + 0
        mult  $t0, $s1        # result * 7
        mflo  $t0
        add   $t0, $t0, $s7  # result + c
        addi  $t1, $zero, 4   #4 bytes
        mult  $t0, $t1
        mflo  $t0
# get value from address
        la    $t2, grid_location
        add   $t0, $t0, $t2
        lw    $t0, 0($t0)      # grid location
        la    $t2, grid_core
        add   $t0, $t0, $t2
        lb    $t0, 0($t0)      # grid core char value
# compare value: t0
        beq  $t0, $s2, ver_if_four
        j    ver_else


ver_if_four:
# do math to $t0: (7 * (r + 3)) + c
        addi  $t0, $zero, 3
        add   $t0, $t0, $s6  # r + 0
        mult  $t0, $s1        # result * 7
        mflo  $t0
        add   $t0, $t0, $s7  # result + c
        addi  $t1, $zero, 4   #4 bytes
        mult  $t0, $t1
        mflo  $t0
# get value from address
        la    $t2, grid_location
        add   $t0, $t0, $t2
        lw    $t0, 0($t0)      # grid location
        la    $t2, grid_core
        add   $t0, $t0, $t2
        lb    $t0, 0($t0)      # grid core char value
# compare value: t0
        beq  $t0, $s2, ver_if_true
        j    ver_else


ver_else:
        addi $s6, $s6, 1
        j    ver_loop_two

end_ver_loop_two:
        addi $s7, $s7, 1
        addi $s6, $zero, 0
        j    ver_loop_one

end_ver_loop_one:
        # move to the next check: pos diag

        j    pos_loop_zero


ver_if_true:
        addi $v0, $zero, 0
        j    win_end

#
# Check positively sloped diaganols
#
pos_loop_zero:
        # set counter for row and col
        addi  $s0, $zero, 6  # row
        addi  $s1, $zero, 7  # col
        addi  $s4, $s0, -3   # row - 3 = 3
        addi  $s5, $s1, -3   # col - 3 = 4
        addi  $s6, $zero, 0  # counter row
        addi  $s7, $zero, 0  # counter col
        j     pos_loop_one

pos_loop_one:
        # col
        beq  $s7, $s5, end_pos_loop_one
        j    pos_loop_two

pos_loop_two:
        # row
        beq  $s6, $s4, end_pos_loop_two
        j    pos_if_one

# the if statements
pos_if_one:
# do math to $t0: (7 * ((r + 0)) + c + 0
        addi  $t0, $zero, 0
        add   $t0, $t0, $s6  # r + 0
        mult  $t0, $s1        # result * 7
        mflo  $t0
        add   $t0, $t0, $s7  # result + c
        addi  $t0, $t0, 0    # result + 0
        addi  $t1, $zero, 4   #4 bytes
        mult  $t0, $t1
        mflo  $t0
# get value from address
        la    $t2, grid_location
        add   $t0, $t0, $t2
        lw    $t0, 0($t0)      # grid location
        la    $t2, grid_core
        add   $t0, $t0, $t2
        lb    $t0, 0($t0)      # grid core char value
# compare value: t0
        beq  $t0, $s2, pos_if_two
        j    pos_else

pos_if_two:
# do math to $t0: (7 * ((r + 1)) + c + 1
        addi  $t0, $zero, 1
        add   $t0, $t0, $s6  # r + 1
        mult  $t0, $s1        # result * 7
        mflo  $t0
        add   $t0, $t0, $s7  # result + c
        addi  $t0, $t0, 1    # result + 1
        addi  $t1, $zero, 4   #4 bytes
        mult  $t0, $t1
        mflo  $t0
# get value from address
        la    $t2, grid_location
        add   $t0, $t0, $t2
        lw    $t0, 0($t0)      # grid location
        la    $t2, grid_core
        add   $t0, $t0, $t2
        lb    $t0, 0($t0)      # grid core char value
# compare value: t0
        beq  $t0, $s2, pos_if_three
        j    pos_else

pos_if_three:
# do math to $t0: (7 * ((r + 2)) + c + 2
        addi  $t0, $zero, 2
        add   $t0, $t0, $s6  # r + 2
        mult  $t0, $s1        # result * 7
        mflo  $t0
        add   $t0, $t0, $s7  # result + c
        addi  $t0, $t0, 2    # result + 2
        addi  $t1, $zero, 4   #4 bytes
        mult  $t0, $t1
        mflo  $t0
# get value from address
        la    $t2, grid_location
        add   $t0, $t0, $t2
        lw    $t0, 0($t0)      # grid location
        la    $t2, grid_core
        add   $t0, $t0, $t2
        lb    $t0, 0($t0)      # grid core char value
# compare value: t0
        beq  $t0, $s2, pos_if_four
        j    pos_else

pos_if_four:
# do math to $t0: (7 * ((r + 3)) + c + 3
        addi  $t0, $zero, 3
        add   $t0, $t0, $s6  # r + 3
        mult  $t0, $s1        # result * 7
        mflo  $t0
        add   $t0, $t0, $s7  # result + c
        addi  $t0, $t0, 3    # result + 3
        addi  $t1, $zero, 4   #4 bytes
        mult  $t0, $t1
        mflo  $t0
# get value from address
        la    $t2, grid_location
        add   $t0, $t0, $t2
        lw    $t0, 0($t0)      # grid location
        la    $t2, grid_core
        add   $t0, $t0, $t2
        lb    $t0, 0($t0)      # grid core char value
# compare value: t0
        beq  $t0, $s2, pos_if_true
        j    pos_else


pos_else:
        addi $s6, $s6, 1
        j    pos_loop_two

end_pos_loop_two:
        addi $s7, $s7, 1
        addi $s6, $zero, 0
        j    pos_loop_one

end_pos_loop_one:
        # move to the next check: neg diag

        j    neg_loop_zero

pos_if_true:
        addi $v0, $zero, 0
        j    win_end


#
# Check negatively sloped diaganols
#
neg_loop_zero:
        # set counter for row and col
        addi  $s0, $zero, 6  # row
        addi  $s1, $zero, 7  # col

        addi  $s5, $s1, -3   # col - 3 = 4
        addi  $s6, $zero, 3  # counter row
        addi  $s7, $zero, 0  # counter col
        j     neg_loop_one

neg_loop_one:
        # col
        beq  $s7, $s5, end_neg_loop_one
        j    neg_loop_two

neg_loop_two:
        # row
        beq  $s6, $s0, end_neg_loop_two
        j    neg_if_one
    
# the if statements   
neg_if_one:
# do math to $t0: (7 * ((r - 0)) + c + 0
        addi  $t0, $zero, 0  # -0
        add   $t0, $t0, $s6  # r - 0
        mult  $t0, $s1        # result * 7
        mflo  $t0       
        add   $t0, $t0, $s7  # result + c
        addi  $t0, $t0, 0    # result + 0
        addi  $t1, $zero, 4   #4 bytes
        mult  $t0, $t1
        mflo  $t0
# get value from address
        la    $t2, grid_location
        add   $t0, $t0, $t2
        lw    $t0, 0($t0)      # grid location
        la    $t2, grid_core
        add   $t0, $t0, $t2
        lb    $t0, 0($t0)      # grid core char value
# compare value: t0
        beq  $t0, $s2, neg_if_two
        j    neg_else

neg_if_two:
# do math to $t0: (7 * ((r - 1)) + c + 1
        addi  $t0, $zero, -1  # -1
        add   $t0, $t0, $s6  # r - 1
        mult  $t0, $s1        # result * 7
        mflo  $t0       
        add   $t0, $t0, $s7  # result + c
        addi  $t0, $t0, 1    # result + 1
        addi  $t1, $zero, 4   #4 bytes
        mult  $t0, $t1
        mflo  $t0
# get value from address
        la    $t2, grid_location
        add   $t0, $t0, $t2
        lw    $t0, 0($t0)      # grid location
        la    $t2, grid_core
        add   $t0, $t0, $t2
        lb    $t0, 0($t0)      # grid core char value
# compare value: t0
        beq  $t0, $s2, neg_if_three
        j    neg_else

neg_if_three:
# do math to $t0: (7 * ((r - 2)) + c + 2
        addi  $t0, $zero, -2  # -2
        add   $t0, $t0, $s6  # r - 2
        mult  $t0, $s1        # result * 7
        mflo  $t0       
        add   $t0, $t0, $s7  # result + c
        addi  $t0, $t0, 2    # result + 2
        addi  $t1, $zero, 4   #4 bytes
        mult  $t0, $t1
        mflo  $t0
# get value from address
        la    $t2, grid_location
        add   $t0, $t0, $t2
        lw    $t0, 0($t0)      # grid location
        la    $t2, grid_core
        add   $t0, $t0, $t2
        lb    $t0, 0($t0)      # grid core char value
# compare value: t0
        beq  $t0, $s2, neg_if_four
        j    neg_else
            
neg_if_four:
# do math to $t0: (7 * ((r - 3)) + c + 3
        addi  $t0, $zero, -3  # -3
        add   $t0, $t0, $s6  # r - 3
        mult  $t0, $s1        # result * 7
        mflo  $t0       
        add   $t0, $t0, $s7  # result + c
        addi  $t0, $t0, 3    # result + 3
        addi  $t1, $zero, 4   #4 bytes
        mult  $t0, $t1
        mflo  $t0
# get value from address
        la    $t2, grid_location
        add   $t0, $t0, $t2
        lw    $t0, 0($t0)      # grid location
        la    $t2, grid_core
        add   $t0, $t0, $t2
        lb    $t0, 0($t0)      # grid core char value
# compare value: t0
        beq  $t0, $s2, neg_if_true
        j    neg_else


neg_else:
        addi $s6, $s6, 1
        j    neg_loop_two

end_neg_loop_two:
        addi $s7, $s7, 1
        addi $s6, $zero, 3
        j    neg_loop_one

end_neg_loop_one:
        # all check complete
        j    all_if_false

neg_if_true:
        addi $v0, $zero, 0
        j    win_end
#
# all check complete
#




all_if_false:
        addi  $v0, $zero, 1
        j     win_end
#
# v0: the winning condition
#
win_end:
        lw    $ra, -4+FRAMESIZE_48($sp)
        lw    $s7, -8+FRAMESIZE_48($sp)
        lw    $s6, -12+FRAMESIZE_48($sp)
        lw    $s5, -16+FRAMESIZE_48($sp)
        lw    $s4, -20+FRAMESIZE_48($sp)
        lw    $s3, -24+FRAMESIZE_48($sp)
        lw    $s2, -28+FRAMESIZE_48($sp)
        lw    $s1, -32+FRAMESIZE_48($sp)
        lw    $s0, -36+FRAMESIZE_48($sp)

        addi  $sp, $sp, FRAMESIZE_48
        jr    $ra









#
# check tie condition
#
tie_and_end:
        li   $v0, PRINT_STRING
        la   $a0, print_tie
        syscall

        lw    $ra, 0($sp)
        addi  $sp, $sp, 4
        jr    $ra










#
# check valid spot in colume
# input-> s1: user input
check_valid_col:
        addi  $sp, $sp, -4
        sw    $ra, 0($sp)

        addi  $t0, $zero, -1   # the top
        addi  $t1, $zero, 5    # counter from bottom
        j     check_valid_col_loop

check_valid_col_loop:
        beq   $t1, $t0, valid_check_bad_end
        addi  $t2, $zero, 7
        mult  $t2, $t1      # 7 * row
        mflo  $t2
        add   $t2, $t2, $s1   # (7*row) + input
        addi  $t3, $zero, 4   # the size 4 byte
        mult  $t2, $t3
        mflo  $t2             # the amount needed to add for index

# get grid location address
        la    $t3, grid_location
        add   $t3, $t3, $t2   # base + index
        lw    $t3, 0($t3)     # get value[integer] in index

# get grid core address
        la    $t2, grid_core
        add   $t2, $t2, $t3
        lb    $t3, 0($t2)     # get value in core grid

# compare to check blank
        addi  $t4, $zero, 32
        beq   $t3, $t4, valid_check_good_end

        addi  $t1, $t1, -1  # go up a row

        j     check_valid_col_loop

valid_check_good_end:
        move  $s3, $t2   # hold on to the address to change value
        addi  $s2, $zero, 0

        lw    $ra, 0($sp)
        addi  $sp, $sp, 4
        jr    $ra

valid_check_bad_end:
        addi  $s2, $zero, 1

        lw    $ra, 0($sp)
        addi  $sp, $sp, 4
        jr    $ra










#
# print no room in col
#
no_room:
        # print no room
        li   $v0, PRINT_STRING
        la   $a0, print_no_room
        syscall
        j    play_game_one










#       
# check valid input
#
not_valid_input:
        # check valid range for players
        li    $v0, PRINT_STRING
        la    $a0, print_illegal_number
        syscall
        j     play_game_one










#
# check win
#
player_wins:
        # winning confirmed
        # check who the player is
        beq   $s0, $zero, player_one_wins
        j     player_two_wins

player_one_wins:
        # player one wins
        li    $v0, PRINT_STRING
        la    $a0, print_one_winner
        syscall

        lw    $ra, 0($sp)
        addi  $sp, $sp, 4
        jr    $ra

player_two_wins:
        # player two quits
        li    $v0, PRINT_STRING
        la    $a0, print_two_winner
        syscall

        lw    $ra, 0($sp)
        addi  $sp, $sp, 4
        jr    $ra










#
# check quit
#
player_quits:
        # quiting confirmed
        # check who the player is
        beq   $s0, $zero, player_one_quits
        j     player_two_quits

player_one_quits:
        # player one quits
        li    $v0, PRINT_STRING
        la    $a0, print_one_quit
        syscall

        lw    $ra, 0($sp)
        addi  $sp, $sp, 4
        jr    $ra

player_two_quits:
        # player two quits
        li    $v0, PRINT_STRING
        la    $a0, print_two_quit
        syscall

        lw    $ra, 0($sp)
        addi  $sp, $sp, 4
        jr    $ra










#
#   Display the intro
#
display_intro:
        addi  $sp, $sp, -4
        sw    $ra, 0($sp)

# print 'Connect Four'
        li    $v0, PRINT_STRING    # system call code for printing string = 4
        la    $a0, print_welcome   # load address of string to be printed in $a0
        syscall

# print new line
        li    $v0, PRINT_STRING
        la    $a0, print_newline
        syscall

# print part 1 of board
        li    $v0, PRINT_STRING
        la    $a0, grid_intro
        syscall

# print part 2 of board
        li    $v0, PRINT_STRING
        la    $a0, grid_core
        syscall

# print part 3 of board
        li    $v0, PRINT_STRING
        la    $a0, grid_end
        syscall



        lw    $ra, 0($sp)
        addi  $sp, $sp, 4
        jr    $ra










#
# Display the board
#
display_board:
        addi  $sp, $sp, -4
        sw    $ra, 0($sp)

# print new line
        li    $v0, PRINT_STRING
        la    $a0, print_newline
        syscall

# print part 1 of board
        li    $v0, PRINT_STRING
        la    $a0, grid_intro
        syscall

# print part 2 of board
        li    $v0, PRINT_STRING
        la    $a0, grid_core
        syscall

# print part 3 of board
        li    $v0, PRINT_STRING
        la    $a0, grid_end
        syscall

        lw    $ra, 0($sp)
        addi  $sp, $sp, 4
        jr    $ra



