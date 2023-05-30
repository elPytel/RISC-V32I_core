#asm
```assembly
# sekce .text pro hlavní část programu
.text
.globl main

main:
    # inicializace proměnných
    addi t0, zero, 0     # nastavení počáteční hodnoty na 0
    addi t2, zero, 0     # inicializace proměnné pro uložení součtu

    # iterace přes rozsah od 0 do 10
    addi t1, zero, 10  
    addi t3, zero, 0

    add_loop:
        add t2, t2, t3    # přidání aktuální hodnoty do součtu
        addi t3, t3, 1    # zvýšení aktuální hodnoty o 1
        blt t3, t1, add_loop  # pokračování v iteraci, pokud není dosaženo konce rozsahu

        # uložení výsledku do registru a0
        mv a0, t2

        # ukončení programu
        ecall        # zavolání systémového volání pro ukončení programu
```