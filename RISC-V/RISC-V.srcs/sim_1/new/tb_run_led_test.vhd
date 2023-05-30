----------------------------------------------------------------------------------
-- Company: TUL
-- Engineer: Jaroslav Korner
-- 
-- Create Date: 11.05.2023 10:52:12
-- Design Name: 
-- Module Name: tb_run_led_test - Behavioral
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

entity tb_run_led_test is
--  Port ( );
end tb_run_led_test;

architecture Behavioral of tb_run_led_test is

    -- clock
    constant clk_period : time      := 10 ns;
    signal clk          : std_logic := '0';

    -- driving pins
    signal reset         : std_logic := '0';
    signal CPU_state_out : t_CPU_STATE;

    signal debug_ce    : std_logic                                       := '1';
    signal debug_enb   : STD_LOGIC                                       := '0';
    signal debug_web   : STD_LOGIC_VECTOR(3 DOWNTO 0)                    := (others => '0');
    signal debug_addrb : STD_LOGIC_VECTOR(C_MEM_ADDR_WIDTH - 1 DOWNTO 0) := (others => '0');
    signal debug_dinb  : STD_LOGIC_VECTOR(C_DATA_WIDTH - 1 DOWNTO 0)     := (others => '0');
    signal debug_doutb : STD_LOGIC_VECTOR(C_DATA_WIDTH - 1 DOWNTO 0);
    signal LEDS_T      : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
    signal LEDS_O      : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
    signal LEDS_I      : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
    signal SWITCH_T    : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
    signal SWITCH_O    : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
    signal SWITCH_I    : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
    signal GPIO_T      : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
    signal GPIO_O      : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
    signal GPIO_I      : std_logic_vector(C_DATA_WIDTH - 1 downto 0);

begin

    RISC_V : entity work.Computer
        generic map (
            G_PROGRAM_FILE => "switch_to_LED.mem"
        )
        port map(
            clk           => clk,
            reset         => reset,
            CPU_state_out => CPU_state_out,
            LEDS_T        => LEDS_T,
            LEDS_O        => LEDS_O,
            LEDS_I        => LEDS_I,
            SWITCH_T      => SWITCH_T,
            SWITCH_O      => SWITCH_O,
            SWITCH_I      => SWITCH_I,
            GPIO_T        => GPIO_T,
            GPIO_O        => GPIO_O,
            GPIO_I        => GPIO_I,
            debug_ce      => debug_ce,
            debug_enb     => debug_enb,
            debug_web     => debug_web,
            debug_addrb   => debug_addrb,
            debug_dinb    => debug_dinb,
            debug_doutb   => debug_doutb
        );

    clk <= not clk after clk_period / 2;

    tb : process
    begin
        -- reset
        reset <= '1';
        wait for clk_period * 10;
        reset <= '0';

        -- run program
        wait for clk_period * 80;

        SWITCH_I <= X"F0F0F0F0";

        -- wait for program to finish
        wait until CPU_state_out = EXCEPTION;
        wait for clk_period * 10;
        report "Done";
        wait;
    end process tb;

end Behavioral;

