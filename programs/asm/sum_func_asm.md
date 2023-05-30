#asm
```assembly
.text
.globl main

j main

# Definice funkce sum
sum:
    # Inicializace proměnných
    addi a1, zero, 0    # a1 = sum
    addi t0, zero, 0    # t0 = i
  
sum_loop:
    bgt t0, a0, sum_exit  # if (i > n) goto sum_exit
    add a1, a1, t0        # sum += i
    addi t0, t0, 1        # i++
    j sum_loop            # goto sum_loop
  
sum_exit:
    jr ra                 # Skočit na adresu uloženou v registru ra

# Hlavní funkce main
main:
    # Volání funkce sum
    addi a0, zero, 10     # a0 = n
    jal ra, sum           # Skočit do funkce sum a uložit návratovou adresu do ra
    
    # Ukončení programu
    mv a0, a1
    ecall
```