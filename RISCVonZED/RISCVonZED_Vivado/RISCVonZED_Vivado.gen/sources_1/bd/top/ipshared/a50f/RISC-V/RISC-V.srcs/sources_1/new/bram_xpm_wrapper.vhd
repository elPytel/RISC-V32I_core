library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.math_real.all;
use work.JKRiscV_types.all;

library xpm;
use xpm.vcomponents.all;

entity bram_xpm_wrapper is
    generic(
        -- Specify size of RAM in bytes
        MEMORY_SIZE_BYTES : integer := 4096;
        -- When using in a project, add this *.MEM file to the Vivado project as a design source
        MEMORY_INIT_FILE  : string  := ""
    );
    port(
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
end bram_xpm_wrapper;

architecture Behavioral of bram_xpm_wrapper is

    constant READ_DATA_WIDTH_A  : integer := C_DATA_WIDTH;
    constant READ_DATA_WIDTH_B  : integer := C_DATA_WIDTH;
    constant WRITE_DATA_WIDTH_A : integer := C_DATA_WIDTH;
    constant WRITE_DATA_WIDTH_B : integer := C_DATA_WIDTH;

    constant ADDR_WIDTH_A : integer := integer(ceil(log2(real(MEMORY_SIZE_BYTES * 8 / READ_DATA_WIDTH_A))));
    constant ADDR_WIDTH_B : integer := integer(ceil(log2(real(MEMORY_SIZE_BYTES * 8 / READ_DATA_WIDTH_B))));

    constant MEMORY_SIZE_BITS : integer := MEMORY_SIZE_BYTES * 8;

--    function resolve_init_param(init_file : string)
--    return string is
--    begin
--        if init_file = "" then
--            return "0";
--        else
--            return "";
--        end if;
--    end function resolve_init_param;

    constant MEMORY_INIT_PARAM : string := "0";

begin

    xpm_memory_tdpram_inst : xpm_memory_tdpram
        generic map(
            ADDR_WIDTH_A            => ADDR_WIDTH_A, -- DECIMAL
            ADDR_WIDTH_B            => ADDR_WIDTH_B, -- DECIMAL
            AUTO_SLEEP_TIME         => 0, -- DECIMAL
            BYTE_WRITE_WIDTH_A      => 8, -- DECIMAL
            BYTE_WRITE_WIDTH_B      => 8, -- DECIMAL
            CASCADE_HEIGHT          => 0, -- DECIMAL
            CLOCKING_MODE           => "independent_clock", -- String
            ECC_MODE                => "no_ecc", -- String
            MEMORY_INIT_FILE        => MEMORY_INIT_FILE, -- String
            MEMORY_INIT_PARAM       => MEMORY_INIT_PARAM, -- String
            MEMORY_OPTIMIZATION     => "true", -- String
            MEMORY_PRIMITIVE        => "auto", -- String
            MEMORY_SIZE             => MEMORY_SIZE_BITS, -- DECIMAL
            MESSAGE_CONTROL         => 0, -- DECIMAL
            READ_DATA_WIDTH_A       => READ_DATA_WIDTH_A, -- DECIMAL
            READ_DATA_WIDTH_B       => READ_DATA_WIDTH_B, -- DECIMAL
            READ_LATENCY_A          => 2, -- DECIMAL
            READ_LATENCY_B          => 2, -- DECIMAL
            READ_RESET_VALUE_A      => "0", -- String
            READ_RESET_VALUE_B      => "0", -- String
            RST_MODE_A              => "SYNC", -- String
            RST_MODE_B              => "SYNC", -- String
            SIM_ASSERT_CHK          => 0, -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
            USE_EMBEDDED_CONSTRAINT => 0, -- DECIMAL
            USE_MEM_INIT            => 1, -- DECIMAL
            USE_MEM_INIT_MMI        => 0, -- DECIMAL
            WAKEUP_TIME             => "disable_sleep", -- String
            WRITE_DATA_WIDTH_A      => WRITE_DATA_WIDTH_A, -- DECIMAL
            WRITE_DATA_WIDTH_B      => WRITE_DATA_WIDTH_B, -- DECIMAL
            WRITE_MODE_A            => "no_change", -- String
            WRITE_MODE_B            => "no_change", -- String
            WRITE_PROTECT           => 1 -- DECIMAL
        )
        port map(
            dbiterra       => open,     -- 1-bit output: Status signal to indicate double bit error occurrence
                                        -- on the data output of port A.

            dbiterrb       => open,     -- 1-bit output: Status signal to indicate double bit error occurrence
                                        -- on the data output of port A.

            douta          => douta,    -- READ_DATA_WIDTH_A-bit output: Data output for port A read operations.
            doutb          => doutb,    -- READ_DATA_WIDTH_B-bit output: Data output for port B read operations.
            sbiterra       => open,     -- 1-bit output: Status signal to indicate single bit error occurrence
                                        -- on the data output of port A.

            sbiterrb       => open,     -- 1-bit output: Status signal to indicate single bit error occurrence
                                        -- on the data output of port B.

            addra          => addra(ADDR_WIDTH_A + 1 downto 2), -- ADDR_WIDTH_A-bit input: Address for port A write and read operations.
            addrb          => addrb(ADDR_WIDTH_B + 1 downto 2), -- ADDR_WIDTH_B-bit input: Address for port B write and read operations.
            clka           => clka,     -- 1-bit input: Clock signal for port A. Also clocks port B when
                                        -- parameter CLOCKING_MODE is "common_clock".

            clkb           => clkb,     -- 1-bit input: Clock signal for port B when parameter CLOCKING_MODE is
                                        -- "independent_clock". Unused when parameter CLOCKING_MODE is
                                        -- "common_clock".

            dina           => dina,     -- WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
            dinb           => dinb,     -- WRITE_DATA_WIDTH_B-bit input: Data input for port B write operations.
            ena            => ena,      -- 1-bit input: Memory enable signal for port A. Must be high on clock
                                        -- cycles when read or write operations are initiated. Pipelined
                                        -- internally.

            enb            => enb,      -- 1-bit input: Memory enable signal for port B. Must be high on clock
                                        -- cycles when read or write operations are initiated. Pipelined
                                        -- internally.

            injectdbiterra => '0',      -- 1-bit input: Controls double bit error injection on input data when
            -- ECC enabled (Error injection capability is not available in
            -- "decode_only" mode).

            injectdbiterrb => '0',      -- 1-bit input: Controls double bit error injection on input data when
            -- ECC enabled (Error injection capability is not available in
            -- "decode_only" mode).

            injectsbiterra => '0',      -- 1-bit input: Controls single bit error injection on input data when
            -- ECC enabled (Error injection capability is not available in
            -- "decode_only" mode).

            injectsbiterrb => '0',      -- 1-bit input: Controls single bit error injection on input data when
            -- ECC enabled (Error injection capability is not available in
            -- "decode_only" mode).

            regcea         => '1',      -- 1-bit input: Clock Enable for the last register stage on the output
                                        -- data path.

            regceb         => '1',      -- 1-bit input: Clock Enable for the last register stage on the output
                                        -- data path.

            rsta           => '0',      -- 1-bit input: Reset signal for the final port A output register
            -- stage. Synchronously resets output port douta to the value specified
            -- by parameter READ_RESET_VALUE_A.

            rstb           => '0',      -- 1-bit input: Reset signal for the final port B output register
            -- stage. Synchronously resets output port doutb to the value specified
            -- by parameter READ_RESET_VALUE_B.

            sleep          => '0',      -- 1-bit input: sleep signal to enable the dynamic power saving feature.
            wea            => wea,      -- WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A-bit input: Write enable vector
                                        -- for port A input data port dina. 1 bit wide when word-wide writes
                                        -- are used. In byte-wide write configurations, each bit controls the
                                        -- writing one byte of dina to address addra. For example, to
                                        -- synchronously write only bits [15-8] of dina when WRITE_DATA_WIDTH_A
                                        -- is 32, wea would be 4'b0010.

            web            => web       -- WRITE_DATA_WIDTH_B/BYTE_WRITE_WIDTH_B-bit input: Write enable vector
                                        -- for port B input data port dinb. 1 bit wide when word-wide writes
                                        -- are used. In byte-wide write configurations, each bit controls the
                                        -- writing one byte of dinb to address addrb. For example, to
                                        -- synchronously write only bits [15-8] of dinb when WRITE_DATA_WIDTH_B
                                        -- is 32, web would be 4'b0010.

        );

end Behavioral;
