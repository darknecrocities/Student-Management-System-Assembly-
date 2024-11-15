# Parejas, Arron Kian M.
# Marquez, Jian Kalel 
# Carreon, Jaycen John
# Jimenez, Graciella Mhervie
# Miranda, Josh Danielle

.data                       # Data segment
student_count:   .word 0     # Variable to store the count of students
students:        .space 320  # Allocate space for 10 students (ID: 4 bytes, Name: 20 bytes, Age: 4 bytes each) = 32 bytes per student, 320 total
menu:            .asciiz "\n1. Add Student\n2. Display Students\n3. Search Student by ID\n4. Exit\nChoose an option: "
id_prompt:       .asciiz "Enter Student ID (4 digits): "
name_prompt:     .asciiz "Enter Student Name (max 20 chars): "
age_prompt:      .asciiz "Enter Student Age: "
found_msg:       .asciiz "Student Found:\n"
not_found_msg:   .asciiz "Student Not Found\n"
display_format_name: .asciiz "\nName: "
display_format_id:   .asciiz "ID: "
display_format_age:  .asciiz "\nAge: "

.text                       # Code segment
.globl main                 # Declare main as a global symbol

main:                       # Main entry point
    la $t1, students         # Load the base address of students array into $t1

main_menu:                  # Main menu label
    li $v0, 4               # Print string syscall
    la $a0, menu            # Load address of menu string
    syscall                 # Display the menu

    li $v0, 5               # Read integer syscall
    syscall                 # Read user choice
    move $t2, $v0           # Move choice to $t2

    beq $t2, 1, add_student         # If choice is 1, go to add_student
    beq $t2, 2, display_students    # If choice is 2, go to display_students
    beq $t2, 3, search_student      # If choice is 3, go to search_student
    beq $t2, 4, exit                # If choice is 4, exit the program

    j main_menu                     # Jump back to main menu if invalid input

add_student:                        # Add student label
    la $t1, students                 # Reload base address of students array
    lw $t3, student_count            # Load current student count

    li $t0, 320                      # Check if 10 students (32 bytes per student * 10 students)
    mul $t4, $t3, 32                 # Calculate current student offset
    beq $t4, $t0, main_menu          # If student count is 10, go back to menu (no space for more)

    add $t1, $t1, $t4                # Move to current student slot based on count

    li $v0, 4                        # Print string syscall
    la $a0, id_prompt                # Prompt for ID
    syscall

    li $v0, 5                        # Read integer syscall for ID
    syscall
    sw $v0, 0($t1)                   # Store ID in students array

    li $v0, 4                        # Print string syscall
    la $a0, name_prompt              # Prompt for name
    syscall

    li $v0, 8                        # Read string syscall for name
    la $a0, 4($t1)                   # Load address of name field (4 bytes after ID)
    li $a1, 20                       # Maximum name length
    syscall

    li $v0, 4                        # Print string syscall
    la $a0, age_prompt               # Prompt for age
    syscall

    li $v0, 5                        # Read integer syscall for age
    syscall
    sw $v0, 24($t1)                  # Store age (24 bytes after ID and name)

    # Increment student count
    lw $t3, student_count            # Load current count
    addi $t3, $t3, 1                 # Increment count
    sw $t3, student_count            # Store new count

    j main_menu                      # Go back to main menu

display_students:                    # Display students label
    lw $t3, student_count            # Load current student count
    li $t4, 0                        # Initialize counter for displaying students
    la $t1, students                 # Reset base address of students array

display_loop:                        # Loop through students
    bge $t4, $t3, end_display        # If counter >= count, exit loop

    # Display student name
    li $v0, 4                        # Print string syscall
    la $a0, display_format_name       # "Name: " prompt
    syscall

    la $a0, 4($t1)                   # Load address of name field (4 bytes after ID)
    li $v0, 4                        # Print string syscall
    syscall                          # Display name

    # Display student ID
    li $v0, 4                        # Print string syscall
    la $a0, display_format_id         # "ID: " prompt
    syscall

    lw $t5, 0($t1)                   # Load student ID
    li $v0, 1                        # Print integer syscall
    move $a0, $t5                    # Move ID to $a0
    syscall                          # Display ID

    # Display student age
    li $v0, 4                        # Print string syscall
    la $a0, display_format_age        # "Age: " prompt
    syscall

    lw $t6, 24($t1)                  # Load student age (24 bytes after ID and name)
    li $v0, 1                        # Print integer syscall
    move $a0, $t6                    # Move age to $a0
    syscall                          # Display age

    addi $t1, $t1, 32                # Move to next student slot
    addi $t4, $t4, 1                 # Increment counter
    j display_loop                   # Repeat the loop

end_display:                         # End display label
    j main_menu                      # Go back to main menu

search_student:                      # Search student label
    li $v0, 4                        # Print string syscall
    la $a0, id_prompt                # Prompt for ID
    syscall

    li $v0, 5                        # Read integer syscall for ID
    syscall
    move $t5, $v0                    # Store searched ID in $t5
    la $t1, students                 # Reload base address of students

    lw $t3, student_count            # Load current student count
    li $t4, 0                        # Initialize search counter

search_loop:                         # Search loop label
    bge $t4, $t3, not_found          # If counter >= count, student not found

    lw $t6, 0($t1)                   # Load student ID
    beq $t6, $t5, student_found      # If ID matches, found

    addi $t1, $t1, 32                # Move to next student slot
    addi $t4, $t4, 1                 # Increment counter
    j search_loop                    # Repeat search

student_found:                       # Student found label
    li $v0, 4                        # Print string syscall
    la $a0, found_msg                # Load found message
    syscall

    # Display student name
    li $v0, 4                        # Print string syscall
    la $a0, display_format_name       # "Name: " prompt
    syscall

    la $a0, 4($t1)                   # Load address of name field (4 bytes after ID)
    li $v0, 4                        # Print string syscall
    syscall                          # Display name

    # Display student ID
    li $v0, 4                        # Print string syscall
    la $a0, display_format_id         # "ID: " prompt
    syscall

    lw $t6, 0($t1)                   # Load student ID
    li $v0, 1                        # Print integer syscall
    move $a0, $t6                    # Move ID to $a0
    syscall                          # Display ID

    # Display student age
    li $v0, 4                        # Print string syscall
    la $a0, display_format_age        # "Age: " prompt
    syscall

    lw $t6, 24($t1)                  # Load student age (24 bytes after ID and name)
    li $v0, 1                        # Print integer syscall
    move $a0, $t6                    # Move age to $a0
    syscall                          # Display age

    j main_menu                      # Go back to main menu

not_found:                           # Not found label
    li $v0, 4                        # Print string syscall
    la $a0, not_found_msg            # Load not found message
    syscall

    j main_menu                      # Go back to main menu

exit:                                # Exit label
    li $v0, 10                       # Exit syscall
    syscall                          # Exit program
