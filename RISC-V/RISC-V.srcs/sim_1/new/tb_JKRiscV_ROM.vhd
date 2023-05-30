----------------------------------------------------------------------------------
-- Company: TUL
-- Engineer: Rozhovec
-- 
-- Create Date: 20.04.2023 09:49:58
-- Design Name: 
-- Module Name: tb_JKRiscV_ROM - Behavioral
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

entity tb_JKRiscV_ROM is
--  Port ( );
end tb_JKRiscV_ROM;

architecture Behavioral of tb_JKRiscV_ROM is

    COMPONENT JKRiscV_ROM
        PORT(
            clka      : IN  STD_LOGIC;
            rsta      : IN  STD_LOGIC;
            ena       : IN  STD_LOGIC;
            wea       : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
            addra     : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            dina      : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            douta     : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            clkb      : IN  STD_LOGIC;
            rstb      : IN  STD_LOGIC;
            enb       : IN  STD_LOGIC;
            web       : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
            addrb     : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            dinb      : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            doutb     : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            rsta_busy : OUT STD_LOGIC;
            rstb_busy : OUT STD_LOGIC
        );
    END COMPONENT;
    signal clkp : STD_LOGIC := '0';
    signal RAM_selected : STD_LOGIC := '0';
    signal mem_wren : STD_LOGIC_VECTOR(3 DOWNTO 0) := (others => '0');
    signal RAM_address : STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
    signal mem_data_in : STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
    signal ram_data_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
    
    signal clk : STD_LOGIC := '0';
    signal debug_enb : STD_LOGIC := '1';
    signal debug_web : STD_LOGIC_VECTOR(3 DOWNTO 0) := (others => '0');
    signal debug_addrb : STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
    signal debug_dinb : STD_LOGIC_VECTOR(31 DOWNTO 0) := (others => '0');
    signal debug_doutb : STD_LOGIC_VECTOR(31 DOWNTO 0);
    
    signal CLK_P : time := 10 ns;
    signal b_ram_data_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal b_debug_doutb : STD_LOGIC_VECTOR(31 DOWNTO 0);

begin
    
    clk <= not clk after CLK_P / 2;
    
        RAM : JKRiscV_ROM
        PORT MAP(
            clka      => clkp,
            rsta      => '0',
            ena       => RAM_selected,
            wea       => mem_wren,
            addra     => RAM_address,
            dina      => mem_data_in,
            douta     => ram_data_out,
            clkb      => clk,
            rstb      => '0',
            enb       => debug_enb,
            web       => debug_web,
            addrb     => debug_addrb,
            dinb      => debug_dinb,
            doutb     => debug_doutb,
            rsta_busy => open,
            rstb_busy => open
        );
        
        RAMb : entity work.bram_xpm_wrapper
            generic map(
                MEMORY_SIZE_BYTES => 4096,
                MEMORY_INIT_FILE  => "program.mem"
            )
            port map(
                clka  => clkp,
                ena   => RAM_selected,
                wea   => mem_wren,
                addra => RAM_address,
                dina  => mem_data_in,
                douta => b_ram_data_out,
                clkb  => clk,
                enb   => debug_enb,
                web   => debug_web,
                addrb => debug_addrb,
                dinb  => debug_dinb,
                doutb => b_debug_doutb
            );
        

    process
    begin
        debug_enb <= '1';
        for i in 0 to 1024 loop
            debug_addrb <= std_logic_vector(to_unsigned(i, debug_addrb'length));
            wait for CLK_P;
        end loop;
        wait; 
    end process;

end Behavioral;
