.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int arrays
# Arguments:
#   a0 (int*) is the pointer to the start of arr0
#   a1 (int*) is the pointer to the start of arr1
#   a2 (int)  is the number of elements to use
#   a3 (int)  is the stride of arr0
#   a4 (int)  is the stride of arr1
# Returns:
#   a0 (int)  is the dot product of arr0 and arr1
# Exceptions:
#   - If the number of elements to use is less than 1,
#     this function terminates the program with error code 36
#   - If the stride of either array is less than 1,
#     this function terminates the program with error code 37
# =======================================================
dot:
    # Prologue
    addi t0, x0, 1
    blt a2, t0, numError
    blt a3, t0, strideError
    blt a4, t0, strideError

    #bytes offset for every stride of array
    addi t0, x0, 4
    mul a3, a3, t0
    mul a4, a4, t0 

    # store the product
    add t0, x0, x0 

loop_start:
    bge x0, a2, loop_end
    # nth value of array
    lw t1, 0(a0) 
    lw t2, 0(a1)

    # product and sum
    mul t1, t1, t2
    add t0, t0, t1

    # update and prepare for next loop
    add a0, a0, a3
    add a1, a1, a4
    addi a2, a2, -1
    j loop_start

loop_end:
    # Epilogue
    add a0, t0, x0
    jr ra

numError:
    li a0, 36
    j exit

strideError:
    li a0, 37
    j exit
 