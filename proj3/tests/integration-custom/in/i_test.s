addi t0, x0, 1
addi t0, x0, 42
addi t0, x0, 256
addi t0, x0, 2047

andi t0, t1, 1
andi t0, x0, 42
andi t0, t2, 256
andi t1, t0, 2047

ori t0, t1, 1
ori t0, x0, 1
ori t0, x0, 2
ori t0, t1, 4

slli t0, t1, 1
slli t0, t1, 2
slli t0, t1, 3
slli t0, t1, 4


slti t0, t1, 1
slti t0, t1, 2
slti t0, t1, 3
slti t0, t1, 4

srai t0, t0, 1
srai t0, t0, 2
srai t0, t0, 3
srai t0, t0, 4

srli t0, t1, 1
srli t1, t0, 2
srli t2, t1, 3
srli t0, t2, 4

xori t0, x0, 0
xori t1, t0, 2
xori t0, x0, 3
xori t0, t0, 4
