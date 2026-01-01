.globl classify

.text
# =====================================
# COMMAND LINE ARGUMENTS
# =====================================
# Args:
#   a0 (int)        argc
#   a1 (char**)     argv
#   a1[1] (char*)   pointer to the filepath string of m0
#   a1[2] (char*)   pointer to the filepath string of m1
#   a1[3] (char*)   pointer to the filepath string of input matrix
#   a1[4] (char*)   pointer to the filepath string of output file
#   a2 (int)        silent mode, if this is 1, you should not print
#                   anything. Otherwise, you should print the
#                   classification and a newline.
# Returns:
#   a0 (int)        Classification
# Exceptions:
#   - If there are an incorrect number of command line args,
#     this function terminates the program with exit code 31
#   - If malloc fails, this function terminates the program with exit code 26
#
# Usage:
#   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>
classify:
    #argError
    addi t0, x0, 5
    bne a0, t0, argError

    addi sp, sp, -56
    sw s0, 0(sp) # arg
    sw s1, 4(sp) # m0 row
    sw s2, 8(sp) # m0 col
    sw s3, 12(sp)# m0 matrix
    sw s4, 16(sp)# m1 row
    sw s5, 20(sp)# m1 col
    sw s6, 24(sp)# m1 matrix
    sw s7, 28(sp)# input row
    sw s8, 32(sp)# input col
    sw s9, 36(sp)# input
    sw s10, 40(sp)# h
    sw s11, 44(sp)# 0
    sw ra, 48(sp)
    sw a2, 52(sp)

    
    mv s0, a1 #store arg
        
    
    
    # Read pretrained m0
        li a0, 4
        jal ra, malloc
        beq a0, x0, mallocError
        mv s1, a0 #pointer to m0 row

        li a0, 4
        jal ra, malloc
        beq a0, x0, mallocError
        mv s2, a0 #pointer to m0 col

        
        
        lw a0, 4(s0) # pointer to m0 filepath 
        mv a1, s1 
        mv a2, s2
        
        jal ra, read_matrix
        mv s3, a0 #pointer to store m0
        
    # Read pretrained m1
        li a0, 4
        jal ra, malloc
        beq a0, x0, mallocError
        mv s4, a0 #pointer to m1 row

        li a0, 4
        jal ra, malloc
        beq a0, x0, mallocError
        mv s5, a0 #pointer to m1 col

        lw a0, 8(s0) # pointer to m1 filepath 
        mv a1, s4
        mv a2, s5
        
        jal ra, read_matrix
        mv s6, a0 #pointer to store m1
        


    # Read input matrix
        li a0, 4
        jal ra, malloc
        beq a0, x0, mallocError
        mv s7, a0 #pointer to input row

        li a0, 4
        jal ra, malloc
        beq a0, x0, mallocError
        mv s8, a0 #pointer to input col

        lw a0, 12(s0) # pointer to input filepath 
        mv a1, s7
        mv a2, s8
        
        jal ra, read_matrix
        mv s9, a0 #pointer to store input


    # Compute h = matmul(m0, input)

    lw t0, 0(s1) # m0 row => h row
    lw t1, 0(s8) # input col => h col
    mul t0, t0, t1 # number
    li a0, 4
    mul a0, a0, t0
    jal ra, malloc
    beq a0, x0, mallocError
    mv s10, a0

    mv a0, s3
    lw a1, 0(s1)
    lw a2, 0(s2)
    mv a3, s9
    lw a4, 0(s7)
    lw a5, 0(s8)
    mv a6, s10
    jal ra, matmul


    # Compute h = relu(h)
    
    mv a0, s10
    lw t0, 0(s1)
    lw t1, 0(s8)
    mul a1, t0, t1 #number of integers in the array
    jal ra, relu

    # Compute o = matmul(m1, h)
        #malloc space
        lw t0, 0(s4) #m1 row
        lw t1, 0(s8)#h col = input col
        mul t0, t0, t1 #number
        li a0, 4
        mul a0, t0, a0 #bytes
        jal ra, malloc
        beq a0, x0, mallocError
        mv s11, a0

        #Compute
        mv a0, s6
        lw a1, 0(s4)
        lw a2, 0(s5)
        mv a3, s10
        lw a4, 0(s1)
        lw a5, 0(s8)
        mv a6, s11
        jal ra, matmul


    # Write output matrix o
    lw a0, 16(s0) #output filepath
    mv a1, s11
    lw a2, 0(s4) #o row = m1 row
    lw a3, 0(s8) #o col = h col = input col
    jal ra, write_matrix

    # Compute and return argmax(o)
    mv a0, s11
    lw t0, 0(s4) #o row = m1 row
    lw t1, 0(s8) #o col = h col = input col
    mul a1, t0, t1
    jal ra, argmax
    mv s0, a0

    lw t0, 52(sp)
    bne t0, x0, freeMalloc
    # If enabled, print argmax(o) and newline
    jal ra, print_int
    li a0, '\n'
    jal ra, print_char
    mv a0, s0

    #free malloc
    freeMalloc:
    mv a0, s1
    jal free

    mv a0, s2
    jal free

    mv a0, s3
    jal free

    mv a0, s4
    jal free

    mv a0, s5
    jal free

    mv a0, s6
    jal free

    mv a0, s7
    jal free

    mv a0, s8
    jal free

    mv a0, s9
    jal free

    mv a0, s10
    jal free

    mv a0, s11
    jal free

    mv a0, s0
    lw s0, 0(sp) 
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw s6, 24(sp)
    lw s7, 28(sp)
    lw s8, 32(sp)
    lw s9, 36(sp)
    lw s10, 40(sp)
    lw s11, 44(sp)
    lw ra, 48(sp)
    lw a2, 52(sp)
    addi sp, sp, 56


    jr ra




mallocError:
 li a0, 26
 j exit

argError:
 li a0, 31
 j exit