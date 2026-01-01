.globl argmax

.text
# =================================================================
# FUNCTION: Given a int array, return the index of the largest
#   element. If there are multiple, return the one
#   with the smallest index.
# Arguments:
#   a0 (int*) is the pointer to the start of the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   a0 (int)  is the first index of the largest element
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# =================================================================
argmax:
    # Prologue
addi t0, x0, 1
blt a1, t0, exception


lw t0, 0(a0) # t0 store the max value;
add t1, x0, x0 # t1 stores the index of max value;

addi t2, x0, 1 # i = 1
addi a0, a0, 4 # a0 store the address of array[i]

loop_start:
bge t2, a1, loop_end # if i >= a1, end
lw t3, 0(a0) # t3 = array[i]

# if max < array[i], max = array[i], maxIndex = i
bge t0, t3, loop_continue 
add t0, t3, x0
add t1, t2, x0

#i++
loop_continue:
addi a0, a0, 4
addi t2, t2, 1
j loop_start

loop_end:
    # Epilogue
    add a0, t1, x0
    jr ra

exception:
    li a0, 36
    j exit


