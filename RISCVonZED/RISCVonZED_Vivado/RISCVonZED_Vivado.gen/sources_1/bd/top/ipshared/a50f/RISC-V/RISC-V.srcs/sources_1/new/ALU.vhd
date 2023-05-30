----------------------------------------------------------------------------------
-- Company: TUL
-- Engineer: Jaroslav Korner
-- 
-- Create Date: 29.11.2022 07:29:18
-- Design Name: 
-- Module Name: top - Behavioral
-- Project Name: RISC-V
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

entity ALU is
    generic(
        C_OUTPUT_REG : boolean := false
    );
    port(
        clk   : in  std_logic;
        funct : in  t_ALUFUNC;
        x, y  : in  std_logic_vector(C_DATA_WIDTH - 1 downto 0);
        r     : out std_logic_vector(C_DATA_WIDTH - 1 downto 0)
    );
end entity ALU;

architecture structure of ALU is
    signal result : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
begin

    result <= ALU_solve(funct, x, y);

    OUTPUT_REG : if C_OUTPUT_REG generate
        process(clk)
        begin
            if rising_edge(clk) then
                r <= result;
            end if;
        end process;
    end generate;

    NO_OUTPUT_REG : if not C_OUTPUT_REG generate
        r <= result;
    end generate;

end architecture structure;
