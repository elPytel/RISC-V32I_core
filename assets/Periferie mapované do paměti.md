# Periferie mapované do paměti
RISC-V nemá žádné instrukce pro přímou komunikací s vnějšími periferiemi. Pro jejich ovládání se využívá přístupu zařízeních mapovaných do paměti. Na příslušném rozsahu adres jsou místo paměti RAM připojeny například GPIO I/O registry či frame buffer displeje, nebo jiné periferie. 

## GPI/O 32b
```vhdl
-- vnitrni signaly
signal values_in  : std_logic_vector(GPIO'range);
signal values_out : std_logic_vector(GPIO'range);
signal direction  : std_logic_vector(GPIO'range);

-- adresovani na urovni periferie
local_addr := unsigned(mem_address(3 downto 2));
case local_addr is
	when "00" =>
		mem_data_out <= direction;
	when "01" =>
		mem_data_out <= values_in;
	when "10" =>
		mem_data_out <= values_out;
	when others =>
		null;
end case;
```

V mém návrhu procesoru se využívá periferií LED a přepínačů. Při nahrání hodnoty 0 na příslušnou pozici v rozsahu adres **směru** se pin periferie na daném bitu nastaví jako výstupní. Při nahrání hodnoty 1 se nastaví jako vstupní. 

V paměti jsou reprezentovány jako 4x32b paměti, kdy:
- první 4B (adresa+0) jsou směr (direction: in/out) (nastavení vstupu/výstupu periferie), 
- další 4B (adresa+4) slouží pro zápis do periferie, 
- následné 4B(adresa+8) slouží pro vyčítání hodnot z periferie, 
- poslední 4B (adresa+12) nejsou obsazeny a jsou zde pouze pro zarovnání paměti na násobky 2.

Na periferie lze přistupovat stejně jako do pole, ukázka kódu.
```assembly
# LED addresses (LED_ADDRESS -> RAM_SIZE)
li t3, 4096   
# LED directions, 32 output pins
sw zero, 0(t3) 
# LED values OFF
sw zero, 4(t3) 

# SWITCH addresses (SWITCH_ADDRESS -> RAM_SIZE + LED_SIZE)
# 4096 + 16
addi t4, t3, 16
# SWITCH directions
lui t5, 0xFFFFF
ori t5, t5, -1
sw t5, 0(t4)

# nacteni hodnoty z prepinace
lw s0, 8(t4)
# zapis do led
sw s0, 4(t3)
```


- `"00"`
- `"01"`
- `"10"`
- `"11"`