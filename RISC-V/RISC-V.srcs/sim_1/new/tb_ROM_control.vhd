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

use work.JKRiscV_types.all;

entity tb_ROM_control is
    --  Port ( );
end tb_ROM_control;

architecture Behavioral of tb_ROM_control is

    -- clock
    constant clk_period : time      := 10 ns;
    signal clk          : std_logic := '0';

    -- driving pins
    signal reset  : std_logic := '0';
    signal enable : std_logic := '0';
    signal addr : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
    signal dout : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
    signal done : std_logic;
    signal rom_rst_busy : std_logic;

begin

    -- clock
    clk <= not clk after clk_period / 2;

    ROM : entity work.ROM_controler
        port map(
            clk  => clk,
            rst  => reset,
            en   => enable,
            addr => addr,
            dout => dout,
            done => done
        ) ;
    

    tb : process
    begin
    
        reset <= '1';
        wait for clk_period*10;
        reset <= '0';
        
        
        addr <= x"00000000";
        enable <= '1';
        wait for clk_period;
        enable <= '0';
        wait for clk_period * 4;
        
        addr <= x"00000000";
        enable <= '1';
        wait for clk_period;
        enable <= '0';
        wait for clk_period * 4;

        addr <= x"00000004";
        enable <= '1';
        wait for clk_period;
        enable <= '0';
        wait for clk_period * 4;
        
        addr <= x"00000008";
        enable <= '1';
        wait for clk_period;
        enable <= '0';
        wait for clk_period * 4;
        
        addr <= x"0000000c";
        enable <= '1';
        wait for clk_period;
        enable <= '0';
        wait for clk_period * 4;
        
        addr <= x"00000010";
        enable <= '1';
        wait for clk_period;
        enable <= '0';
        wait for clk_period * 4;

        wait for clk_period * 200;
        report "Done";
    end process tb;

end Behavioral;
