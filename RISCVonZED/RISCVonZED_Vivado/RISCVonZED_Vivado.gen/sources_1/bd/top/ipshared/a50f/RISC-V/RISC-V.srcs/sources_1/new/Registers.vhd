----------------------------------------------------------------------------------
-- Company: TUL
-- Engineer: Jaroslav Korner
-- 
-- Create Date: 03.11.2022 07:29:18
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

entity registers is
    port(
        signal regwr, clk     : in  std_logic;
        signal rd, rs, rt     : in  std_logic_vector(C_REG_ADDR_WIDTH - 1 downto 0);
        signal wrdata         : in  std_logic_vector(C_DATA_WIDTH - 1 downto 0);
        signal rs1_data, rs2_data : out std_logic_vector(C_DATA_WIDTH - 1 downto 0)
    );
end entity registers;

architecture behavior of registers is
    type registerFile is array (0 to 2 ** C_REG_ADDR_WIDTH - 1) of std_logic_vector(C_DATA_WIDTH - 1 downto 0);
    signal r : registerFile := (others => (others => '0'));
begin

    writeReg : process(clk)
    begin
        if rising_edge(clk) then
            if regwr = '1' then
                r(to_integer(unsigned(rd))) <= wrdata;
            end if;
            r(0) <= (others => '0');
        end if;
    end process;

    readReg1 : process(rs, r)
    begin
        rs1_data <= r(to_integer(unsigned(rs)));
    end process;

    readReg2 : process(rt, r)
    begin
        rs2_data <= r(to_integer(unsigned(rt)));
    end process;

end architecture behavior;
