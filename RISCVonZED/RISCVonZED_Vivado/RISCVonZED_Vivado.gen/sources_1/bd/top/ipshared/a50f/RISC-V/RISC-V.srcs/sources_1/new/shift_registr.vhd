----------------------------------------------------------------------------------
-- Company: TUL
-- Engineer: Korner
-- 
-- Create Date: 23.04.2023 14:05:38
-- Design Name: 
-- Module Name: shift_registr - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity shift_registr is
    generic(
        REGSIZE : integer := 8
    );
    port(
        clk   : in  std_logic;
        reset : in  std_logic;
        d     : in  std_logic;
        q     : out std_logic
    );
end shift_registr;

architecture Behavioral of shift_registr is
    signal shift_reg : std_logic_vector(REGSIZE - 1 downto 0) := (others => '0');
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                shift_reg <= (others => '0');
            else
                shift_reg <= shift_reg(REGSIZE - 2 downto 0) & d;
            end if;
        end if;
    end process;
    q <= shift_reg(REGSIZE - 1);

end Behavioral;
