#asm
```assembly
.text
.globl main

# inicializace SP, 8192
li sp, 4096
addi sp, sp, -8

# Skok na hlavní funkci
j main

# Funkce fibonaci - vypočítá n-té číslo Fibonaciho posloupnosti
# Argumenty:
#   a0 - n (číslo, pro které chceme spočítat číslo Fibonaciho posloupnosti)
# Návratová hodnota:
#   a1 - n-té číslo Fibonaciho posloupnosti
fibonaci:
    # Test na n = 0
    beqz a0, fibonaci_return_0

    # Test na n = 1
    li t0, 1
    beq a0, t0, fibonaci_return_1

    # Výpočet fibonaci(n - 1)
    addi sp, sp, -16 
    addi a0, a0, -1
    sw ra, 12(sp)
    sw a0, 8(sp)
    jal ra, fibonaci
    sw a1, 0(sp)

    # Výpočet fibonaci(n - 2)
    lw a0, 8(sp)
    addi a0, a0, -1
    jal ra, fibonaci
    mv t2, a1

    # Návratová hodnota = fibonaci(n - 1) + fibonaci(n - 2)
    lw ra, 12(sp)
    lw t1, 0(sp)
    add a1, t1, t2
    addi sp, sp, 16
    jr ra

fibonaci_return_0:
    # Návratová hodnota pro n = 0 je 0
    li a1, 0
    jr ra

fibonaci_return_1:
    # Návratová hodnota pro n = 1 je 1
    li a1, 1
    jr ra

# Hlavní funkce
main:
    # Nastavení argumentu pro volání funkce fibonaci
    addi a0, zero, 10

    # Volání funkce fibonaci
    jal ra, fibonaci

    # Předání výsledku do registru a0
    mv  a0, a1
    # Konec programu
    ecall
```