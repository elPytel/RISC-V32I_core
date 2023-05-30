----------------------------------------------------------------------------------
-- Company: TUL
-- Engineer: Jaroslav Korner
-- 
-- Create Date: 10.04.2023 16:51:01
-- Design Name: 
-- Module Name: memory_wraper - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

use work.JKRiscV_types.all;

/*
Memory mapped devices
Vezme vstupni adresu a odecte od ni base_address.
Pokud je vysledek v rozsahu 0 - (top_address - base_address), pak je selected = '1' a address_peripheral = vysledek.
Memory range: top_address - base_address
*/

entity memory_wraper is
    generic (
        C_ADDRESS_WIDTH : integer := 32;
        -- C_DATA_WIDTH : integer := 32;
        C_BASE_ADDRESS : std_logic_vector(C_ADDRESS_WIDTH -1 downto 0) := (others => '0');
        C_HIGH_ADDRESS : std_logic_vector(C_ADDRESS_WIDTH -1 downto 0) := (others => '1')
    );
    port (
        -- in
        -- clk : in std_logic;
        address_global : in std_logic_vector(C_ADDRESS_WIDTH -1 downto 0);
        -- out
        address_peripheral : out std_logic_vector(C_ADDRESS_WIDTH -1 downto 0);
        selected : out std_logic
    );
end memory_wraper;

architecture Behavioral of memory_wraper is
    constant address_range : unsigned := unsigned(C_HIGH_ADDRESS) - unsigned(C_BASE_ADDRESS);
    signal address_peripheral_unsigned : unsigned(C_ADDRESS_WIDTH -1 downto 0);
    
begin
    -- address_range: top_address - base_address
    -- address_peripheral : address_global - base_address
    address_peripheral_unsigned <= unsigned(address_global) - unsigned(C_BASE_ADDRESS);
    selected <= '1' when address_peripheral_unsigned <= address_range else '0';
    address_peripheral <= std_logic_vector(address_peripheral_unsigned) when selected = '1' else (others => '0');

end Behavioral;
