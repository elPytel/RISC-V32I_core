----------------------------------------------------------------------------------
-- Company: TUL
-- Engineer: Jaroslav Korner
-- 
-- Create Date: 29.03.2023 17:29:00
-- Design Name: 
-- Module Name: edge_detector - Behavioral
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

entity edge_detector is
    generic(
        C_RISING_EDGE : boolean := true
    );
    Port (
        clk : in std_logic;
        reset : in std_logic;
        input : in std_logic;
        output : out std_logic
    );
end edge_detector;

architecture Behavioral of edge_detector is
begin
    RISING_EDGE_MODE : if C_RISING_EDGE generate
        process(clk)
            variable last_input : std_logic := '0';
        begin
            if rising_edge(clk) then
                if reset = '1' then
                    last_input := '0';
                    output <= '0';
                else 
                    output <= input and not last_input;
                    last_input := input;
                end if;
            end if;
        end process;
    end generate;

    FALLING_EDGE_MODE : if not C_RISING_EDGE generate
        process(clk)
            variable last_input : std_logic := '0';
        begin
            if rising_edge(clk) then
                if reset = '1' then
                    last_input := '0';
                    output <= '0';
                else 
                    output <= not input and last_input;
                    last_input := input;
                end if;
            end if;
        end process;
    end generate;

end Behavioral;
