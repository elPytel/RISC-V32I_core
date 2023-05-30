----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 29.03.2023 21:18:11
-- Design Name: 
-- Module Name: tb_edge_detection - Behavioral
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

entity tb_edge_detection is
    --  Port ( );
end tb_edge_detection;

architecture Behavioral of tb_edge_detection is

    -- clock
    constant clk_period : time      := 10 ns;
    signal clk          : std_logic := '0';

    -- driving pins
    signal reset  : std_logic := '0';
    signal input  : std_logic := '0';
    signal output : std_logic;

begin

    edge_detection : entity work.edge_detector
        generic map(
            C_RISING_EDGE => true
        )
        port map(
            clk    => clk,
            reset  => reset,
            input  => input,
            output => output
        );

    clk <= not clk after clk_period / 2;

    tb : process
    begin
        reset <= '1';
        wait for clk_period;
        reset <= '0';
        wait for clk_period;

        input <= '1';
        wait for clk_period;
        input <= '0';
        wait for clk_period;
        
        wait for clk_period / 2;
        input <= '1';
        wait for clk_period;
        input <= '0';
        wait for clk_period;

        wait for clk_period * 20;
        report "Done";
    end process tb;

end Behavioral;
