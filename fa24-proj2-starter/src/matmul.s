.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
#   d = matmul(m0, m1)
# Arguments:
#   a0 (int*)  is the pointer to the start of m0
#   a1 (int)   is the # of rows (height) of m0
#   a2 (int)   is the # of columns (width) of m0
#   a3 (int*)  is the pointer to the start of m1
#   a4 (int)   is the # of rows (height) of m1
#   a5 (int)   is the # of columns (width) of m1
#   a6 (int*)  is the pointer to the the start of d
# Returns:
#   None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 38
# =======================================================
matmul:

    # Error checks
    addi t0, x0, 1
    blt a1, t0, error
    blt a2, t0, error
    blt a4, t0, error
    blt a5, t0, error
    bne a2, a4, error

    # Prologue
addi sp, sp, -40
sw s0,0(sp)
sw s1,4(sp)
sw s2,8(sp)
sw s3,12(sp)
sw s4,16(sp)
sw s5,20(sp)
sw s6,24(sp)
sw s7,28(sp)
sw s8,32(sp)
sw ra,36(sp)


mv s0, a0 # store mo pointer
mv s1, a3  # store m1 pointer
mv s2, a6 # store d pointer
mv s3, a1  # store rows
mv s4, a5 # store cols
mv s5, x0 # store index of p
mv s6, x0 #let i = 0
mv s7, x0 #let j = 0
mv s8, a2 # number of elements for dot function


outer_loop_start:
    bge s6, s3, outer_loop_end
    mv a0, s0
    mv a1, s1 # second array start
    mv a2, s8 # number of elments per row
    addi a3, x0, 1 # stride of first array
    add a4, x0, s4 # stride of second array
    j inner_loop_start

inner_loop_start:
    bge s7, s4, inner_loop_end
    ebreak
    jal ra, dot
    sw a0,0(s2) #write value to p[index]

    #prepare for next loop
    addi s2, s2, 4 #increment p pointer
    addi s7, s7, 1 #j++

    #cal next col
    addi t0, x0, 4
    mul t0, t0, s7 #calculate offset
    add a1, s1, t0 #move to next col

    mv a0, s0
    mv a2, s8 # number of elments per row
    addi a3, x0, 1 # stride of first array
    add a4, x0, s4 # stride of second array

    j inner_loop_start

inner_loop_end:
    addi s6, s6, 1 # i++
    mv s7, x0 # let j = 0
    #move to next row
    addi t1, x0, 4 
    mul t1, t1, s8 #bytes per row
    add s0, s0, t1 # pointer of next row
    j outer_loop_start

outer_loop_end:
    # Epilogue

lw s0,0(sp)
lw s1,4(sp)
lw s2,8(sp)
lw s3,12(sp)
lw s4,16(sp)
lw s5,20(sp)
lw s6,24(sp)
lw s7,28(sp)
lw s8,32(sp)
lw ra,36(sp)
addi sp, sp, 40
    jr ra

error:
 li a0, 38
 j exit