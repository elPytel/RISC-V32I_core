#asm
```assembly
.text
.globl main

# RAM_SIZE = 1024, 2048, 4096
# (0 - 4095)
li sp, 4096 
# ptr = (int *) RAM_SIZE - WORD_SIZE
addi sp, sp, -8

j main

main:
    li t0, 256

    # while (ptr > 256)
    while_loop:
        # *ptr = ptr
        sw sp, 0(sp)

        # if (*ptr != ptr)
        lw t1, 0(sp)
        bne t1, sp, return_1

        # ptr--
        addi sp, sp, -4

        # if (ptr < 256)
        blt sp, t0, return_0

        # goto while_loop
        j while_loop

    return_0:
        li a0, 0
        ecall
    
    return_1:
        # return 1
        li a0, 1
        ecall
```