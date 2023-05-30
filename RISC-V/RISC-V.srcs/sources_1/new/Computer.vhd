----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.04.2023 19:50:13
-- Design Name: 
-- Module Name: Computer - Behavioral
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
library UNISIM;
use UNISIM.VComponents.all;

use work.JKRiscV_types.all;

entity Computer is
    generic(
        G_PROGRAM_FILE : string := "program.mem"
    );
    port(
        -- in
        clk           : in  std_logic;
        reset         : in  std_logic;
        -- out
        CPU_state_out : out t_CPU_STATE;
        -- GPIO
        LEDS_T        : out std_logic_vector(C_DATA_WIDTH - 1 downto 0);
        LEDS_O        : out std_logic_vector(C_DATA_WIDTH - 1 downto 0);
        LEDS_I        : in  std_logic_vector(C_DATA_WIDTH - 1 downto 0);
        SWITCH_T      : out std_logic_vector(C_DATA_WIDTH - 1 downto 0);
        SWITCH_O      : out std_logic_vector(C_DATA_WIDTH - 1 downto 0);
        SWITCH_I      : in  std_logic_vector(C_DATA_WIDTH - 1 downto 0);
        GPIO_T        : out std_logic_vector(C_DATA_WIDTH - 1 downto 0);
        GPIO_O        : out std_logic_vector(C_DATA_WIDTH - 1 downto 0);
        GPIO_I        : in  std_logic_vector(C_DATA_WIDTH - 1 downto 0);
        -- debug
        debug_ce      : in  std_logic;
        debug_enb     : in  STD_LOGIC;
        debug_web     : in  STD_LOGIC_VECTOR(3 DOWNTO 0);
        debug_addrb   : in  STD_LOGIC_VECTOR(C_MEM_ADDR_WIDTH - 1 DOWNTO 0);
        debug_dinb    : in  STD_LOGIC_VECTOR(C_DATA_WIDTH - 1 DOWNTO 0);
        debug_doutb   : out STD_LOGIC_VECTOR(C_DATA_WIDTH - 1 DOWNTO 0)
    );
end Computer;

architecture Behavioral of Computer is

    -- size in bytes
    constant WORD_BYTE_SIZE : integer := C_WORD_SIZE / C_BYTE_SIZE;
    constant RAM_SIZE       : integer := 4096; -- 4KB
    constant IO_SIZE        : integer := 128;

    constant IO_BUFFER_SIZE : integer := 4;
    constant LED_SIZE       : integer := WORD_BYTE_SIZE * IO_BUFFER_SIZE; -- out only
    constant SWITCH_SIZE    : integer := WORD_BYTE_SIZE * IO_BUFFER_SIZE; -- in only

    -- Core
    signal clkp           : std_logic;
    signal address_global : std_logic_vector(C_MEM_ADDR_WIDTH - 1 downto 0);
    signal mem_data_in    : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
    signal mem_data_out   : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
    signal reset_all      : std_logic;
    signal mem_en         : std_logic;

    -- RAM wraper
    signal RAM_selected : STD_LOGIC;
    signal RAM_address  : STD_LOGIC_VECTOR(C_MEM_ADDR_WIDTH - 1 DOWNTO 0);

    -- RAM
    signal ram_data_out : STD_LOGIC_VECTOR(C_DATA_WIDTH - 1 DOWNTO 0);
    signal mem_wren     : std_logic_vector(C_DATA_WIDTH / C_BYTE_SIZE - 1 downto 0);
    signal mem_done     : std_logic;

    COMPONENT JKRiscV_ROM
        PORT(
            clka  : IN  STD_LOGIC;
            ena   : IN  STD_LOGIC;
            wea   : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
            addra : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            dina  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            douta : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            clkb  : IN  STD_LOGIC;
            enb   : IN  STD_LOGIC;
            web   : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
            addrb : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            dinb  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            doutb : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT;

    -- mem FSM
    type t_MEM_STATE is (IDLE, WORKING, LOADED);
    signal mem_state      : t_MEM_STATE := IDLE;
    signal mem_next_state : t_MEM_STATE := IDLE;

    -- memory maped IO
    signal IO_address  : std_logic_vector(C_MEM_ADDR_WIDTH - 1 downto 0);
    signal IO_selected : std_logic;
    signal IO_in       : std_logic_vector(C_DATA_WIDTH - 1 downto 0) := (others => '0');
    signal GPIO_out    : std_logic_vector(C_DATA_WIDTH - 1 downto 0) := (others => '0');
    signal GPIO_done   : std_logic;

    -- LED
    signal LED_address  : std_logic_vector(C_MEM_ADDR_WIDTH - 1 downto 0) := (others => '0');
    signal LED_out      : std_logic_vector(C_DATA_WIDTH - 1 downto 0)     := (others => '0');
    signal LED_selected : std_logic;
    signal LED_done     : std_logic;

    -- SWITCH
    signal SWITCH_address  : std_logic_vector(C_MEM_ADDR_WIDTH - 1 downto 0) := (others => '0');
    signal SWITCH_out      : std_logic_vector(C_DATA_WIDTH - 1 downto 0)     := (others => '0');
    signal SWITCH_selected : std_logic;
    signal SWITCH_done     : std_logic;

begin

    cpu_clock : BUFGCE
        port map(
            O  => clkp,                 -- 1-bit output: Clock output
            CE => debug_ce,             -- 1-bit input: Clock enable input for I0
            I  => clk                   -- 1-bit input: Primary clock
        );

    RISC_V_Core : entity work.Core
        port map(
            clk           => clkp,
            reset         => reset,
            mem_done      => mem_done,
            data_from_mem => mem_data_out,
            CPU_state_out => CPU_state_out,
            mem_address   => address_global,
            data_to_mem   => mem_data_in,
            mem_en        => mem_en,
            mem_wren      => mem_wren,
            reset_all     => reset_all
        );

    RAM_wraper : entity work.memory_wraper
        generic map(
            C_ADDRESS_WIDTH => C_MEM_ADDR_WIDTH,
            C_BASE_ADDRESS  => std_logic_vector(to_unsigned(0, C_DATA_WIDTH)),
            C_HIGH_ADDRESS  => std_logic_vector(to_unsigned(RAM_SIZE - 1, C_DATA_WIDTH))
        )
        port map(
            address_global     => address_global,
            address_peripheral => RAM_address,
            selected           => RAM_selected
        );

    LED_wraper : entity work.memory_wraper
        generic map(
            C_ADDRESS_WIDTH => C_MEM_ADDR_WIDTH,
            C_BASE_ADDRESS  => std_logic_vector(to_unsigned(RAM_SIZE, C_DATA_WIDTH)),
            C_HIGH_ADDRESS  => std_logic_vector(to_unsigned(RAM_SIZE + LED_SIZE - 1, C_DATA_WIDTH))
        )
        port map(
            address_global     => address_global,
            address_peripheral => LED_address,
            selected           => LED_selected
        );

    SWITCH_wraper : entity work.memory_wraper
        generic map(
            C_ADDRESS_WIDTH => C_MEM_ADDR_WIDTH,
            C_BASE_ADDRESS  => std_logic_vector(to_unsigned(RAM_SIZE + LED_SIZE, C_DATA_WIDTH)),
            C_HIGH_ADDRESS  => std_logic_vector(to_unsigned(RAM_SIZE + LED_SIZE + SWITCH_SIZE - 1, C_DATA_WIDTH))
        )
        port map(
            address_global     => address_global,
            address_peripheral => SWITCH_address,
            selected           => SWITCH_selected
        );

    IO_wraper : entity work.memory_wraper
        generic map(
            C_ADDRESS_WIDTH => C_MEM_ADDR_WIDTH,
            C_BASE_ADDRESS  => std_logic_vector(to_unsigned(RAM_SIZE + LED_SIZE + SWITCH_SIZE, C_DATA_WIDTH)),
            C_HIGH_ADDRESS  => std_logic_vector(to_unsigned(RAM_SIZE + LED_SIZE + SWITCH_SIZE + IO_SIZE - 1, C_DATA_WIDTH))
        )
        port map(
            address_global     => address_global,
            address_peripheral => IO_address,
            selected           => IO_selected
        );

    mem_data_out <= ram_data_out when RAM_selected = '1' else
                    LED_out when LED_selected = '1' else
                    SWITCH_out when SWITCH_selected = '1' else
                    GPIO_out when IO_selected = '1' else
                    (others => '0');

    RAM : entity work.bram_xpm_wrapper
        generic map(
            MEMORY_SIZE_BYTES => RAM_SIZE,
            MEMORY_INIT_FILE  => G_PROGRAM_FILE
        )
        port map(
            clka  => clkp,
            ena   => RAM_selected,
            wea   => mem_wren,
            addra => RAM_address,
            dina  => mem_data_in,
            douta => ram_data_out,
            clkb  => clk,
            enb   => debug_enb,
            web   => debug_web,
            addrb => debug_addrb,
            dinb  => debug_dinb,
            doutb => debug_doutb
        );

    LED : entity work.GPIO
        port map(
            clk          => clk,
            rst          => reset_all,
            mem_done     => LED_done,
            mem_data_out => LED_out,
            mem_address  => LED_address,
            mem_data_in  => mem_data_in,
            mem_en       => LED_selected,
            mem_wren     => mem_wren,
            GPIO_T       => LEDS_T,
            GPIO_O       => LEDS_O,
            GPIO_I       => LEDS_I
        );

    SWITCH : entity work.GPIO
        port map(
            clk          => clk,
            rst          => reset_all,
            mem_done     => SWITCH_done,
            mem_data_out => SWITCH_out,
            mem_address  => SWITCH_address,
            mem_data_in  => mem_data_in,
            mem_en       => SWITCH_selected,
            mem_wren     => mem_wren,
            GPIO_T       => SWITCH_T,
            GPIO_O       => SWITCH_O,
            GPIO_I       => SWITCH_I
        );

    GPIO : entity work.GPIO
        port map(
            clk          => clk,
            rst          => reset_all,
            mem_done     => GPIO_done,
            mem_data_out => GPIO_out,
            mem_address  => IO_address,
            mem_data_in  => mem_data_in,
            mem_en       => IO_selected,
            mem_wren     => mem_wren,
            GPIO_T       => GPIO_T,
            GPIO_O       => GPIO_O,
            GPIO_I       => GPIO_I
        );

    shifter : entity work.shift_registr
        generic map(
            REGSIZE => 2
        )
        port map(
            clk   => clkp,
            reset => reset_all,
            d     => mem_en,
            q     => mem_done
        );

end Behavioral;
