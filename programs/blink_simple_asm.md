#asm
```assembly
# RAM_SIZE = 4096B = 1024x32b
# IO_SIZE = 16B = 4x32b
.text
.globl main

j main

define_io:
    # LED addresses (LED_ADDRESS -> RAM_SIZE)
    li t3, 4096

    # LED directions
    # 32 output pins
    sw zero, 0(t3)
    # LED values
    sw zero, 4(t3)

    # SWITCH addresses (SWITCH_ADDRESS -> RAM_SIZE + LED_SIZE)
    # 4096 + 16
    addi t4, t3, 16
    # SWITCH directions
    lui t5, 0xFFFFF
    ori t5, t5, -1
    sw t5, 0(t4)

    # return
    jr ra

reset_counter:
    li t0, 0
    j loop

main:
    # define io
    jal define_io

    # citac
    li t0, 0 # time
    li t1, 12 # strida
    li t2, 25 # max time

    loop:    
        # inkrementuj citac o switch
        lw s0, 8(t4)
        add t0, t0, s0

        # zapis do led
        slt s1, t0, t1
        sw s1, 4(t3)

        # resetuj citac
        bge t0, t2, reset_counter

        # loop
        j loop
    
    # ukonceni programu
    ecall
```