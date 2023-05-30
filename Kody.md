# RISC-V32i Programy:

## Test aritmetiky
Pro základní test aritmetiky byl zvolen program výpočtu sumy. Vzniklo několik jeho variant. První varianta testuje pouze základní aritmetické operace a cyklus for. Druhá varianta testuje i volání funkce.
### Sum
```C
int main(void) {
    int sum = 0;
    for (int i = 0; i < 10; i++) {
        sum += i;
    }
    return sum;
}
```

![[sum_asm]]

#### S voláním funkce
```C
int sum(int n) {
    int sum = 0;
    for (int i = 0; i <= n; i++) {
        sum += i;
    }
    return sum;
}

int main(void) {
    int s = sum(10);
    return 0;
}
```

![[sum_func_asm]]

## Práce s pamětí
### mem test
Program testující práci s pamětí, které bude později využita při ukládání proměnných na zásobník a jejich čtení, nebo při komunikaci se zařízeními mapovanými do paměti. For cyklus postupně ukládá do paměti data, pak je čte a ověřuje zda jsou správná. Začne na čísle 0 a postupně inkrementuje až do velikosti paměti. S hodnotou proměnné se posouvá i adresa, na kterou se má data uložit. Pokud se někde vyskytne chyba, program se ukončí.

```C
int main(void) {
    int RAM_SIZE = 4096;
    int WORD_SIZE = 4;
    int *ptr = (int *) RAM_SIZE - WORD_SIZE;
    while (ptr > 256) {
        // uložení dat do paměti
        *ptr = ptr;
        // testování dat v paměti
        if (*ptr != ptr) {
            return 1;
        }
        // posunutí ukazatele na další adresu
        ptr--;
    }
    return 0;
}
```
![[mem_test_asm]]

### Fibonacci
Algoritmus Fibonacciho posloupnosti byl zvolen protože pro výpočet nepotřebuje operace násobení a dělení. Nejdříve byla využita jeho sekvenční verze, která využívá cyklus for, pro otestování základní funkčnosti. Následně byla využita rekurzivní verze, která využívá zásobník. 

$$
F(n) = 
\begin{cases}
	0, & \text{pro } n = 0; \\
	1, & \text{pro } n = 1; \\
	F(n−1)​+F(n−2) & \text{jinak.}​
\end{cases}
$$

#### for
```C
int main(void) {
    int last = 0;
    int current = 1;
    for (int i = 0; i < 10; i++) {
        int tmp = current;
        current += last;
        last = tmp;
    }
    return 0;
}
```

```assembly
.text
main:
    addi t0, zero, 10
    addi t1, zero, 0
    addi t2, zero, 1
    addi t3, zero, 0
loop:
    # tmp = current
    addi t4, t2, 0
    # current += last
    add t2, t2, t1
    # last = tmp
    addi t1, t4, 0
    # i++
    addi t3, t3, 1
    # i < 10
    bne t3, t0, loop
    # return
    addi a0, t2, 0
    ecall
```

#### rekurze
Testování rekurzivní volání funkcí a práce se zásobníkem (slouží také pro ověření správné práce s pamětí).
![C kód](./programs/fibonaci_rekurze_c.md)

Při syntéze RAM o velikosti 4kB se na stack se vejde 256 rámců (256 * 16B = 4kB). V každém rámci jsou 4B pro uložení adresy návratu a 12B pro uložení argumentů. Tedy maximálně 256 volání rekurze. Při volání výpočtu fib(10) je potřeba zavolat funkci 177 a to se s jistotou do paměti RAM vejde.

![asembly kód](fibonaci_rekurze_asm.md)

## I/O operace
Procesor je také napojen na vnější svět pomocí zařízení mapovaných do paměti. Je připojený na přepínače a ledky. Ledky jsou mapované na adresu 4096 a mají rozsah 128b. Přepínače na adresu 4224. Přepínače jsou nastaveny jako vstupní a ledky jako výstupní piny. 

### Zapnuti LED podle vzoru
Při spuštění programu se ledky rozsvítí podle nastavení. 
led_test.txt
```assembly
# RAM_SIZE = 4096B = 1024x32b
# IO_SIZE = 16B = 4x32b
.text

define_io:
    # LED addresses (RAM_SIZE -> RAM_SIZE + LED_SIZE -1)
    li t3, 4096   

    # LED directions
    # 32 output pins
    li t5, 0
    sw t5, 0(t3)
    # LED values
    lui t5, 0x0F0F0
    li t6, 0xF0F
    or t5, t5, t6

    sw zero, 4(t3)

    # SWITCH addresses
    # 4096 + 16
    addi t4, t3, 16
    # SWITCH directions
    lui t5, 0xFFFFF
    ori t5, t5, -1
    sw t5, 0(t4)

    # return
    #jr ra

# ukonceni programu
ecall
```

### Zobrazení stavu přepínačů na LED
Při přepnutí vypínače do polohy ON, začne svítit LED na desce. Při přepnutí vypínače do polohy OFF, LED zhasne.

![[switch_to_LED_asm]]

### Blikání LED
Při přepnutí vypínače do polohy ON, začne blikat LED na desce. Při přepnutí vypínače do polohy OFF, LED přestane blikat.

Frekvence procesoru je 50MHz. Tedy 1 cyklus trvá 20ns. Tedy 1/20ns = 50MHz.
Ledka bliká se střídou 50:50 a peridou 1s. Tedy svítí po dobu 500ms a to je 25 000 000 cyklů. Tedy 25 000 000 * 20ns = 500ms.

Zjednodušený program:
![jednoduchý kód pro blikání](./programs/blink_simple_asm)

Pokročilý program s voláním funkcí:
![pokročilý kód pro blikání](./programs/blink_complex_asm)
