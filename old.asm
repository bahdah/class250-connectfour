#
# FILE:        $File$
# AUTHOR:      S. Bahdah
#
#
# DESCRIPTION:
#
#
#
# ARGUMENTS:
#
#
#
# INPUTS:
#         No inputs.
#
#
# OUTPUTS:
#
#
#
#

#-------------------

#
# CONSTANTS
#


#-------------------
#
# DATA AREAS
#

        .data
        .align  2   # word data must be on word boundaries

# block for rows
# in each row, there are cols
# display template here

welcome:
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

# the byte location of spots you can fill.
grid_location:
        .word 67, 71, 75, 79, 83, 87, 91
        .word 131, 135, 139, 143, 147, 151, 155
        .word 195, 199, 203, 207, 211, 215, 219
        .word 259, 263, 267, 271, 275, 279, 283
        .word 323, 327, 331, 335, 339, 343, 347
        .word 387, 391, 395, 399, 403, 407, 411

newline:
        .asciiz "\n"
space:
        .asciiz " "
print_player_one:
        .asciiz "\nPlayer 1: select a row to place your coin (0-6 or -1 to quit):"
print_player_two:
        .asciiz "\nPlayer 2: select a row to place your coin (0-6 or -1 to quit):"
print_illegal_number:
        .asciiz "\nIllegal column number."
print_no_room:
        .asciiz "\nIllegal move, no more room in that column."
print_tie:
        .asciiz "\nThe game ends in a tie.\n"
print_one_winner:
        .asciiz "\nPlayer 1 wins!\n"
print_two_winner:
        .asciiz "\nPlayer 2 wins!\n"
print_one_quit:
        .asciiz "\nPlayer 1 quit.\n"
print_two_quit:
        .asciiz "\nPlayer 2 quit.\n"

### sample
prompt:
        .asciiz "Enter your age: "

message:
        .asciiz "\nYour input is "



#
# CODE AREAS
#
        .text         # this is program code
        .align  2     # instructions must be on word boundaries
        
        .globl  main  # main is the global label. program starts here



#
# Name:    main
#
# Description:
# Arguments:
# Returns:
# Destroys:
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


        #jal   display_intro
        
        #jal   loop_two_start
        #jal   loop_start
        #jal   test_input

        ## player toggle
        addi  $s0, $zero, 0
        jal   play_game
        jal   loop_start
        
#
# end the program
#
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
        jr    $ra   # return from main and exit spim

loop_start:
        la    $s1, grid_core
loop:
        lb    $a0, 0($s1)
        beq   $a0, $zero, loop_end
        li    $v0, 11
        syscall
        
        addi  $s1, $s1, 1
        j loop

loop_end:
        jr    $ra

loop_two_start:
        la    $s1, grid_location
        addi  $s2, $zero, 0
        addi  $s3, $zero, LENGTH

loop_two:
        lw    $a0, 0($s1)
        beq   $s2, $s3, loop_two_end
        # print value
        li    $v0, PRINT_INT
        syscall
        # print space
        li    $v0, PRINT_STRING
        la    $a0, space
        syscall

        addi  $s1, $s1, 4
        addi  $s2, $s2, 1
        j     loop_two

loop_two_end:
        jr    $ra

# input:  a0, the col index
# return: v0, 0 if false, 1 if true
# return: v1, index value
valid_check_col:
        addi $t9, $zero, -1
        addi $t8, $zero, -7
        addi $s1, $zero, 5  #counter for loop


        j    valid_check_loop

valid_check_loop:
        beq  $s1, $t9, valid_check_bad_end
        addi $s2, $zero, 7
        mult $s2, $s1   # 7 * row
        mflo $s2
        add  $s2, $s2, $a0  #(7*row) + input'a0'
        addi $t7, $zero, 4
        mult $s2, $t7
        mflo $s2


        # get grid location address
        la    $s3, grid_location
        add   $s3, $s3, $s2
        lw    $t7, 0($s3)        # get value[integer] in index
        
        # get grid core address
        la    $s4, grid_core
        add   $s4, $s4, $t7
        lb    $s5, 0($s4)        # get value in core grid
        


        # compare to check blank
        addi  $t6, $zero, 32
        beq   $s5, $t6, valid_check_good_end

        addi $s1, $s1, -1

valid_check_good_end:
        move $v1, $t7
        addi $v0, $zero, 1
        jr   $ra

valid_check_bad_end:
        addi $v0, $zero, 0
        jr   $ra

# print no room in col
no_room:
        move $t7, $a0
        li   $v0, PRINT_STRING
        la   $a0, print_no_room
        syscall
        beq  $t7, $zero, toggle_one
        j    toggle_two
        

# start the game
play_game:
        # start with player one
        # set s0 as the toggle
        beq   $s0, $zero, toggle_one
        j     toggle_two

# player one quit
one_quit:
        li    $v0, PRINT_STRING
        la    $a0, print_one_quit
        syscall

        jr    $ra

# player two quit
two_quit:
        li    $v0, PRINT_STRING
        la    $a0, print_two_quit
        syscall

        jr    $ra

# check valid range for player one
not_valid_range_one:
        li    $v0, PRINT_STRING
        la    $a0, print_illegal_number
        syscall
        j     toggle_one

# check valid range for player two
not_valid_range_two:
        li    $v0, PRINT_STRING
        la    $a0, print_illegal_number
        syscall
        j     toggle_two

# player one
toggle_one:
        # print player one
        li    $v0, PRINT_STRING
        la    $a0, print_player_one
        syscall

        # get user input
        li    $v0, READ_INT
        syscall
        
        move  $a0, $v0
        move  $t0, $v0
        # check quit
        addi  $t9, $zero, -1
        beq   $a0, $t9, one_quit
        addi  $t8, $zero, 6

        # check range
        slt   $t8, $t8, $a0 
        bne   $t8, $zero, not_valid_range_one   # if input > 6 error
        slt   $t9, $a0, $t9
        bne   $t9, $zero, not_valid_range_one   # if input < -1

        # check valid spot in col
        move  $a0, $t0   # input
        jal   valid_check_col
        
        addi  $a0, $zero, 0          # 0 for player one
        beq   $v0, $zero, no_room    # if 0, no slot. print

        # add 'X' to player one in index
        la    $s4, grid_core
        add   $s4, $s4, $v1
        addi  $t7, $zero, 88
        #sb    $t7, 0($s4)
        #move  $t0, $v1


        # display message
        li    $v0, PRINT_STRING
        la    $a0, message
        syscall

        # print input
        li    $v0, PRINT_INT
        move  $a0, $t0
        syscall

        # print new line
        li    $v0, PRINT_STRING
        la    $a0, newline
        syscall

        # end turn
        addi  $s0, $zero, 1
        j     play_game

#player two
toggle_two:
        # print player two
        li    $v0, PRINT_STRING
        la    $a0, print_player_two
        syscall

        # get user input
        li    $v0, READ_INT
        syscall

        move  $a0, $v0
        # check quit
        addi  $t9, $zero, -1
        beq   $a0, $t9, two_quit
        addi  $t8, $zero, 6

        # check range
        slt   $t8, $t8, $a0
        bne   $t8, $zero, not_valid_range_two   # if input > 6 error
        slt   $t9, $a0, $t9
        bne   $t9, $zero, not_valid_range_two   # if input < -1


        # display message
        li    $v0, PRINT_STRING
        la    $a0, message
        syscall

        # print input
        li    $v0, PRINT_INT
        move  $a0, $t0
        syscall

        # print new line
        li    $v0, PRINT_STRING
        la    $a0, newline
        syscall

        # end turn
        addi  $s0, $zero, 0
        j     play_game

end_game:
        jr    $ra

display_intro:
        # print 'Connect Four'
        li    $v0, PRINT_STRING    # system call code for printing string = 4
        la    $a0, welcome         # load address of string to be printed in $a0
        syscall

        # print new line
        li    $v0, PRINT_STRING
        la    $a0, newline
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

        # print new line
        li    $v0, PRINT_STRING
        la    $a0, newline
        syscall

        jr    $ra


