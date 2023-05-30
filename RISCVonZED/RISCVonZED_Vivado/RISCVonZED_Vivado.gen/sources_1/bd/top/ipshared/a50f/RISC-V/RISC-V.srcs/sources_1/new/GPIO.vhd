----------------------------------------------------------------------------------
-- Company: TUL
-- Engineer: Rozkovec
-- 
-- Create Date: 13.04.2023 10:47:32
-- Design Name: 
-- Module Name: GPIO - Behavioral
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
use IEEE.numeric_std.all;

Library UNISIM;
use UNISIM.vcomponents.all;
use work.JKRiscV_types.all;

entity GPIO is
    port(
        clk          : in    std_logic;
        rst          : in    std_logic;
        mem_done     : out   std_logic;
        mem_data_out : out   std_logic_vector(C_DATA_WIDTH - 1 downto 0);
        mem_address  : in    std_logic_vector(C_DATA_WIDTH - 1 downto 0);
        mem_data_in  : in    std_logic_vector(C_DATA_WIDTH - 1 downto 0);
        mem_en       : in    std_logic;
        mem_wren     : in    std_logic_vector(3 downto 0);
        GPIO_T       : out std_logic_vector(C_DATA_WIDTH - 1 downto 0);
        GPIO_O       : out std_logic_vector(C_DATA_WIDTH - 1 downto 0);
        GPIO_I       : in  std_logic_vector(C_DATA_WIDTH - 1 downto 0)
    );
end GPIO;

architecture Behavioral of GPIO is

    signal values_in  : std_logic_vector(GPIO_I'range);
    signal values_out : std_logic_vector(GPIO_O'range);
    signal direction  : std_logic_vector(GPIO_T'range);

begin


    GPIO_T <= direction;
    values_in <= GPIO_I;
    GPIO_O <= values_out;
    

    process(clk)
        variable local_addr : unsigned(1 downto 0);
    begin
        if rising_edge(clk) then
            local_addr := unsigned(mem_address(3 downto 2));
            if rst = '1' then
                values_out  <= (others => '0');
                direction  <= (others => '0');
            elsif mem_en = '1' then
                case local_addr is
                    when "00" =>
                        for i in 0 to 3 loop
                            if mem_wren(i) = '1' then
                                direction(8 * (i + 1) - 1 downto 8 * i) <= mem_data_in(8 * (i + 1) - 1 downto 8 * i);
                            end if;
                        end loop;
                    when "01" =>
                        for i in 0 to 3 loop
                            if mem_wren(i) = '1' then
                                values_out(8 * (i + 1) - 1 downto 8 * i) <= mem_data_in(8 * (i + 1) - 1 downto 8 * i);
                            end if;
                        end loop;
                    when others =>
                        null;
                end case;
            end if;
        end if;
    end process;

    process(clk)
        variable local_addr : unsigned(1 downto 0);
    begin
        if rising_edge(clk) then
            local_addr   := unsigned(mem_address(3 downto 2));
            mem_data_out <= (others => '0');
            mem_done     <= mem_en;
            if rst = '1' then
                mem_data_out <= (others => '0');
                mem_done     <= '0';
            elsif mem_en = '1' then
                case local_addr is
                    when "00" =>
                        mem_data_out <= direction;
                    when "01" =>
                        mem_data_out <= values_out;
                    when "10" =>
                        mem_data_out <= values_in;
                    when others =>
                        null;
                end case;
            end if;
        end if;
    end process;

end Behavioral;
