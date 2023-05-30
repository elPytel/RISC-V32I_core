#asm
```assembly
# RAM_SIZE = 4096B = 1024x32b
# IO_SIZE = 16B = 4x32b
.text
.globl main

j main

define_io:
    # LED addresses (RAM_SIZE -> RAM_SIZE + LED_SIZE -1)
    li t3, 4096   

    # LED directions
    # 32 output pins
    li t5, 0
    sw t5, 0(t3)
    # LED values
    sw zero, 4(t3)

    # SWITCH addresses
    # 4096 + 16
    addi t4, t3, 16
    # SWITCH directions
    lui t5, 0xFFFFF
    ori t5, t5, -1
    sw t5, 0(t4)

    # return
    jr ra

main:
    # define io
    jal define_io

    loop:
        # nacteni stavu switchu
        lw s1, 8(t4)

        # zapis do led
        sw s1, 4(t3)

        j loop
    
    # ukonceni programu
    ecall
```