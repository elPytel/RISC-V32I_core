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
    li t5, 0xffffffff
    sw t5, 0(t3)
    # LED values
    sw zero, 4(t3)

    # SWITCH addresses
    # 4096 + 16
    addi t4, t3, 16
    # SWITCH directions
    li t5, 0
    sw t5, 0(t4)

    # return
    jr ra

# args:
# a0 - index
# return:
# a1 - value
read_switch_from_index: # index
    # precteni periferie switch
    lw s1, 8(t4)
    # maskovani pres index pro cteni
    and s1, a0, s1
    # je vetsi nez 0?
    # navratova hodnota do a1
    sltu a1, zero, s1
    # navrat z funkce
    jr ra

# args:
# a0 - index
# a1 - value
set_led_from_index: # index, value
    # vycteni periferie led
    lw s1, 8(t3)
    # bit shift left
    sll a1, a0, s2
    slli 1, a0, s3
    # nulovani pres index pro zapis
    xor s1, s3, s1
    # nastaveni periferie led
    or s1, s2, s1
    # zapis do periferie led
    sw s1, 4(t3)
    # navrat z funkce
    jr ra

increment_time:
    # incrementace casu
    addi t0, t0, 1
    # je cas vetsi nez max cas?
    sltu t1, t2, t0
    # navrat z funkce
    jr ra

solve_led:
    # vypnuti led
    addi a1, zero, 0
    addi ra, t6, 0
    auipc ra, 8
    beq t1, zero, set_led_from_index

    # nastaveni periferie led
    addi a1, zero, 1
    auipc ra, 8
    beq t0, t1, set_led_from_index

    # navrat z funkce
    addi t6, ra, 0
    jr ra

main:
    # definice vstupu/vystupu
    jal ra, define_io

    # inicializace promennych
    addi t0, zero, 0 # time
    addi t1, zero, 0 # strida
    addi t2, zero, 0 # max time

    # index periferie
    addi a0, zero, 0
    loop:
        # cteni periferie switch
        jal ra, read_switch_index

        # incrementace casu
        auipc ra, 8
        bne a1, zero, increment_time

        # led
        jal ra, solve_led

        # podminka pro opakovani
        j loop

    # ukonceni programu
    ecall

```