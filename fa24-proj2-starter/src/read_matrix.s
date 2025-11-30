.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
#   - If malloc returns an error,
#     this function terminates the program with error code 26
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fread error or eof,
#     this function terminates the program with error code 29
# ==============================================================================
read_matrix:
    # Prologue
    addi sp, sp, -28
    sw s0, 0(sp) #store filename
    sw s1, 4(sp) #store rows
    sw s2, 8(sp) #store cols
    sw s3, 12(sp) #file descriptor
    sw s4, 16(sp) #bytes of contents
    sw s5, 20(sp) #matrix pointer
    sw ra, 24(sp)

    #store pointer
    mv s1, a1
    mv s2, a2

    #open file
    mv a1, x0
    jal ra, fopen
    blt a0, x0, fopenError
    mv s3, a0 #s3 stores the file descriptor


    #read row
    mv a0, s3
    mv a1, s1
    addi a2, x0, 4
    jal ra, fread
    addi a2, x0, 4
    bne a2, a0, freadError

    #read col
    mv a0, s3
    mv a1, s2
    addi a2, x0, 4
    jal ra, fread
    addi a2, x0, 4
    bne a2, a0, freadError

    #calculate the bytes of matrix
    lw t0, 0(s1)
    lw t1, 0(s2)
    mul t0, t0, t1 #number of ints
    addi s4, x0, 4
    mul s4, s4, t0 #bytes to read

    #malloc
    mv a0, s4
    jal ra, malloc
    mv s5, a0
    ebreak
    beq a0, x0, mallocError
    

    #read later contents
     mv a0, s3
     mv a1, s5
     mv a2, s4
     jal ra, fread

    mv a2, s4
    bne a2, a0, freadErrorTwo

    #close file
    mv a0, s3
    jal ra, fclose
    blt a0, x0, fcloseError
    
    # Epilogue
    mv a0, s5

    lw s0, 0(sp) #store filename
    lw s1, 4(sp) #store rows
    lw s2, 8(sp) #store cols
    lw s3, 12(sp) #file descriptor
    lw s4, 16(sp) #bytes of contents
    lw s5, 20(sp) #matrix pointer
    lw ra, 24(sp)
    addi sp, sp, 28

    jr ra


mallocError:
 li a0, 26
 j exit

fopenError:
 li a0, 27
 j exit

fcloseError:
 mv a0, s5
 jal free
 li a0, 28
 j exit

freadError:
 li a0, 29
 j exit

freadErrorTwo:
 mv a0, s5
 jal free
 li a0, 29
 j exit


