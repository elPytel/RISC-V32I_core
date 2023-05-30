----------------------------------------------------------------------------------
-- Company: TUL
-- Engineer: Jaroslav Korner
-- 
-- Create Date: 02.03.2023 21:24:33
-- Design Name: 
-- Module Name: tb_memory_control - Behavioral
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

use work.JKRiscV_types.all;

entity tb_memory_control is
end tb_memory_control;

architecture Behavioral of tb_memory_control is

    -- clock
    constant clk_period : time      := 10 ns;
    signal clk          : std_logic := '0';
    signal reset        : std_logic := '0';

    -- ALU
    signal alufunc      : t_ALUFUNC;
    signal data1, data2 : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
    signal ALU_result   : std_logic_vector(C_DATA_WIDTH - 1 downto 0);

    -- ControlUnit
    signal opcode    : t_OPCODE;
    signal CPU_state : t_CPU_STATE;
    signal reset_all : std_logic;

    -- instr fetch
    signal instruction  : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
    signal imm          : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
    signal rs2, rs1, rd : std_logic_vector(C_REG_ADDR_WIDTH - 1 downto 0);
    signal encoding     : t_ENCODING;

    -- registers
    signal regwr    : std_logic;
    signal wrdata   : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
    signal rs1_data : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
    signal rs2_data : std_logic_vector(C_DATA_WIDTH - 1 downto 0);

    -- RAM
    signal mem_done      : std_logic;
    signal data_from_mem : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
    signal data_to_mem   : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
    signal data_to_cpu   : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
    signal mem_address   : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
    signal mem_wren      : std_logic_vector(C_DATA_WIDTH / C_BYTE_SIZE - 1 downto 0);
    signal mem_en        : std_logic;
    -- debug mem
    signal debug_enb     : STD_LOGIC;
    signal debug_web     : STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal debug_addrb   : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal debug_dinb    : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal debug_doutb   : STD_LOGIC_VECTOR(31 DOWNTO 0);

    -- PC
    constant PC_error      : std_logic                                   := '0';
    signal PC_ce           : std_logic                                   := '0';
    signal PC              : std_logic_vector(C_DATA_WIDTH - 1 downto 0) := (others => '0');
    signal PC_jump_handler : std_logic                                   := '0';
    signal branche         : std_logic                                   := '0';

begin
    ALU : entity work.ALU
        port map(
            clk   => clk,
            funct => alufunc,
            x     => data1,
            y     => data2,
            r     => ALU_result
        );

    ControlUnit : entity work.ControlUnit
        port map(
            clk             => clk,
            reset_in        => reset,
            PC_error        => PC_error,
            PC              => PC,
            ALU_result      => ALU_result,
            data_from_mem   => instruction,
            data_from_cpu   => rs2_data,
            mem_done        => mem_done,
            reset_all       => reset_all,
            opcode          => opcode,
            alufunc         => alufunc,
            imm             => imm,
            mem_en          => mem_en,
            mem_address     => mem_address,
            data_to_mem     => data_to_mem,
            data_to_cpu     => data_to_cpu,
            mem_wren        => mem_wren,
            PC_ce           => PC_ce,
            PC_jump_handler => PC_jump_handler,
            branch         => branche,
            reg_write       => regwr,
            rs1             => rs1,
            rs2             => rs2,
            rd              => rd,
            CPU_state_out   => CPU_state
        );

    registers : entity work.registers
        port map(
            regwr    => regwr,
            clk      => clk,
            rd       => rd,
            rs       => rs1,
            rt       => rs2,
            wrdata   => wrdata,
            rs1_data => rs1_data,
            rs2_data => rs2_data
        );

    RAM : entity work.bram_xpm_wrapper
        generic map(
            MEMORY_SIZE_BYTES => 4096
        )
        port map(
            clka  => clk,
            ena   => mem_en,
            wea   => mem_wren,
            addra => mem_address,
            dina  => data_to_mem,
            douta => data_from_mem,
            clkb  => clk,
            enb   => debug_enb,
            web   => debug_web,
            addrb => debug_addrb,
            dinb  => debug_dinb,
            doutb => debug_doutb
        );

    shifter : entity work.shift_registr
        generic map(
            REGSIZE => 3
        )
        port map(
            clk   => clk,
            reset => reset_all,
            d     => mem_en,
            q     => mem_done
        );

    -- register source
    register_source : process(opcode, ALU_result, data_to_cpu, imm)
    begin
        case opcode is
            when LUI_INST =>
                wrdata <= imm;
            when JAL_INST | JALR_INST =>
                --wrdata <= PC_plus_4;
            when LOAD =>
                wrdata <= data_to_cpu;
            when STORE =>
                wrdata <= (others => '0');
            when OTHERS =>
                wrdata <= ALU_result;
        end case;
    end process register_source;

    -- ALU source
    ALU_source : process(opcode, imm, rs2_data, PC, rs1_data)
    begin
        -- data2 source
        case opcode is
            when BRANCH =>
                data2 <= rs2_data;
            when AUIPC_INST | JALR_INST =>
                data2 <= imm;
            when LOAD | STORE =>
                data2 <= imm;
            when IMMEDIATE =>
                data2 <= imm;
            when OTHERS =>
                data2 <= rs2_data;
        end case;

        -- data1 source
        case opcode is
            when BRANCH =>
                data1 <= rs1_data;
            when AUIPC_INST =>
                data1 <= PC;
            when OTHERS =>
                data1 <= rs1_data;
        end case;
    end process ALU_source;

    clk      <= not clk after clk_period / 2;
    -- DEBUG
    encoding <= to_encoding(instruction(C_OPCODE_WIDTH - 1 downto 0));

    tb : process
    begin
        -- INST dest, src1, src2

        -- reset
        wait for clk_period;
        reset <= '1';
        wait until reset_all = '1';
        reset <= '0';

        -- init
        instruction <= codes_to_instruction(
            opcode         => ERROR,
            funct_3_ALU    => ERR_O,
            funct_3_memory => ERR_O,
            funct_3_branch => ERR_O,
            funct_7        => (others => '0'),
            rs1            => 0, rs2 => 0, rd => 0,
            imm            => (others => '0')
        );

        wait until CPU_state = DECODE;
        wait for clk_period;

        -- Const data to registr
        -- LUI x4, 0x0F070000
        instruction <= codes_to_instruction(
            opcode         => LUI_INST,
            funct_3_ALU    => ERR_O,
            funct_3_memory => ERR_O,
            funct_3_branch => ERR_O,
            funct_7        => (others => '0'),
            rs1            => 0, rs2 => 0, rd => 4,
            imm            => "0000" & "1111" & "0000" & "0111" & "0000" & "0000" & "0000" & "0000"
        );

        wait until CPU_state = DECODE;
        wait for clk_period;

        -- ADDI x5, x0, 0x00000301
        instruction <= codes_to_instruction(
            opcode         => IMMEDIATE,
            funct_3_ALU    => ARIT_O,
            funct_3_memory => ERR_O,
            funct_3_branch => ERR_O,
            funct_7        => (others => '0'),
            rs1            => 0, rs2 => 0, rd => 5,
            imm            => "0000" & "0000" & "0000" & "0000" & "0000" & "0011" & "0000" & "0001"
        );

        wait until CPU_state = DECODE;
        wait for clk_period;

        -- OR x5, x4, x5
        instruction <= codes_to_instruction(
            opcode         => REGISTR,
            funct_3_ALU    => OR_O,
            funct_3_memory => ERR_O,
            funct_3_branch => ERR_O,
            funct_7        => (others => '0'),
            rs1            => 4, rs2 => 5, rd => 5,
            imm            => (others => '0')
        );

        wait until CPU_state = DECODE;
        wait for clk_period;

        -- Store data to memory
        -- SW x5, 0x00000100(x0)
        instruction <= codes_to_instruction(
            opcode         => STORE,
            funct_3_ALU    => ERR_O,
            funct_3_memory => WORD_O,
            funct_3_branch => ERR_O,
            funct_7        => (others => '0'),
            rs1            => 0, rs2 => 5, rd => 0,
            imm            => std_logic_vector(to_unsigned(4, C_DATA_WIDTH))
        );

        wait until CPU_state = DECODE;
        wait for clk_period;

        -- Load data from memory
        -- LW x6, 0x00000100(x0)
        instruction <= codes_to_instruction(
            opcode         => LOAD,
            funct_3_ALU    => ERR_O,
            funct_3_memory => WORD_O,
            funct_3_branch => ERR_O,
            funct_7        => (others => '0'),
            rs1            => 0, rs2 => 0, rd => 6,
            imm            => std_logic_vector(to_unsigned(4, C_DATA_WIDTH))
        );

        wait until CPU_state = MEMORY;
        wait until mem_done = '1';
        instruction <= data_from_mem;
        wait for clk_period * 1.5;
        assert data_to_cpu = "0000" & "1111" & "0000" & "0111" & "0000" & "0011" & "0000" & "0001" report "Wrong data" severity ERROR;

        wait until CPU_state = DECODE;
        wait for clk_period;

        -- Unaligned address
        -- LW x6, 0x00000101(x0)
        instruction <= codes_to_instruction(
            opcode         => LOAD,
            funct_3_ALU    => ERR_O,
            funct_3_memory => WORD_O,
            funct_3_branch => ERR_O,
            funct_7        => (others => '0'),
            rs1            => 0, rs2 => 0, rd => 6,
            imm            => std_logic_vector(to_unsigned(4 + 1, C_DATA_WIDTH))
        );

        wait until CPU_state = EXECUTE;
        wait for clk_period * 3;
        assert CPU_state = EXCEPTION report "Didnt raised: Unaligned address" severity ERROR;

        -- reset
        wait for clk_period;
        reset <= '1';
        wait until reset_all = '1';
        reset <= '0';
        wait until CPU_state = START;
        wait for clk_period;


        -- Const data to registr
        -- LUI x4, 0x0F070000
        instruction <= codes_to_instruction(
            opcode         => LUI_INST,
            funct_3_ALU    => ERR_O,
            funct_3_memory => ERR_O,
            funct_3_branch => ERR_O,
            funct_7        => (others => '0'),
            rs1            => 0, rs2 => 0, rd => 4,
            imm            => "0000" & "1111" & "0000" & "0111" & "0000" & "0000" & "0000" & "0000"
        );

        wait until CPU_state = DECODE;
        wait for clk_period;

        -- ADDI x5, x0, 0x00000301
        instruction <= codes_to_instruction(
            opcode         => IMMEDIATE,
            funct_3_ALU    => ARIT_O,
            funct_3_memory => ERR_O,
            funct_3_branch => ERR_O,
            funct_7        => (others => '0'),
            rs1            => 0, rs2 => 0, rd => 5,
            imm            => "0000" & "0000" & "0000" & "0000" & "0000" & "0011" & "0000" & "0001"
        );

        wait until CPU_state = DECODE;
        wait for clk_period;

        -- OR x5, x4, x5
        instruction <= codes_to_instruction(
            opcode         => REGISTR,
            funct_3_ALU    => OR_O,
            funct_3_memory => ERR_O,
            funct_3_branch => ERR_O,
            funct_7        => (others => '0'),
            rs1            => 4, rs2 => 5, rd => 5,
            imm            => (others => '0')
        );

        wait until CPU_state = DECODE;
        wait for clk_period;

        -- Store data to memory
        -- SW x5, 0x00000100(x0)
        instruction <= codes_to_instruction(
            opcode         => STORE,
            funct_3_ALU    => ERR_O,
            funct_3_memory => WORD_O,
            funct_3_branch => ERR_O,
            funct_7        => (others => '0'),
            rs1            => 0, rs2 => 5, rd => 0,
            imm            => std_logic_vector(to_unsigned(4, C_DATA_WIDTH))
        );

        wait until CPU_state = DECODE;
        wait for clk_period;

        -- LH x6, 0x00000100(x0)
        instruction <= codes_to_instruction(
            opcode         => LOAD,
            funct_3_ALU    => ERR_O,
            funct_3_memory => HALF_O,
            funct_3_branch => ERR_O,
            funct_7        => (others => '0'),
            rs1            => 0, rs2 => 0, rd => 6,
            imm            => std_logic_vector(to_unsigned(4, C_DATA_WIDTH))
        );

        wait until CPU_state = MEMORY;
        wait until mem_done = '1';
        instruction <= data_from_mem;
        wait for clk_period * 1.5;
        assert data_to_cpu = "0000" & "0000" & "0000" & "0000" & "0000" & "0011" & "0000" & "0001" report "Wrong data" severity ERROR;

        wait until CPU_state = DECODE;
        wait for clk_period;

        -- LH x6, 0x00000101(x0)
        instruction <= codes_to_instruction(
            opcode         => LOAD,
            funct_3_ALU    => ERR_O,
            funct_3_memory => HALF_O,
            funct_3_branch => ERR_O,
            funct_7        => (others => '0'),
            rs1            => 0, rs2 => 0, rd => 6,
            imm            => std_logic_vector(to_unsigned(4 + 1, C_DATA_WIDTH))
        );

        wait until CPU_state = MEMORY;
        wait until mem_done = '1';
        instruction <= data_from_mem;
        wait for clk_period * 1.5;
        assert data_to_cpu = "0000" & "0000" & "0000" & "0000" & "0000" & "0111" & "0000" & "0011" report "Wrong data" severity ERROR;

        wait until CPU_state = DECODE;
        wait for clk_period;

        -- LH x6, 0x00000110(x0)
        instruction <= codes_to_instruction(
            opcode         => LOAD,
            funct_3_ALU    => ERR_O,
            funct_3_memory => HALF_O,
            funct_3_branch => ERR_O,
            funct_7        => (others => '0'),
            rs1            => 0, rs2 => 0, rd => 6,
            imm            => std_logic_vector(to_unsigned(4 + 2, C_DATA_WIDTH))
        );

        wait until CPU_state = MEMORY;
        wait until mem_done = '1';
        instruction <= data_from_mem;
        wait for clk_period * 1.5;
        assert data_to_cpu = "0000" & "0000" & "0000" & "0000" & "0000" & "1111" & "0000" & "0111" report "Wrong data" severity ERROR;

        wait until CPU_state = DECODE;
        wait for clk_period;

        -- Unaligned address
        -- LH x6, 0x00000111(x0)
        instruction <= codes_to_instruction(
            opcode         => LOAD,
            funct_3_ALU    => ERR_O,
            funct_3_memory => HALF_O,
            funct_3_branch => ERR_O,
            funct_7        => (others => '0'),
            rs1            => 0, rs2 => 0, rd => 6,
            imm            => std_logic_vector(to_unsigned(4 + 3, C_DATA_WIDTH))
        );

        wait until CPU_state = EXECUTE;
        wait for clk_period * 2;
        assert CPU_state = EXCEPTION report "Didnt raised: Unaligned address" severity ERROR;

        -- reset
        wait for clk_period;
        reset <= '1';
        wait until reset_all = '1';
        reset <= '0';
        wait until mem_en = '1';
        wait for clk_period * 2;

        -- Const data to registr
        -- LUI x4, 0x0F070000
        instruction <= codes_to_instruction(
            opcode         => LUI_INST,
            funct_3_ALU    => ERR_O,
            funct_3_memory => ERR_O,
            funct_3_branch => ERR_O,
            funct_7        => (others => '0'),
            rs1            => 0, rs2 => 0, rd => 4,
            imm            => "0000" & "1111" & "0000" & "0111" & "0000" & "0000" & "0000" & "0000"
        );

        wait until CPU_state = DECODE;
        wait for clk_period;

        -- ADDI x5, x0, 0x00000301
        instruction <= codes_to_instruction(
            opcode         => IMMEDIATE,
            funct_3_ALU    => ARIT_O,
            funct_3_memory => ERR_O,
            funct_3_branch => ERR_O,
            funct_7        => (others => '0'),
            rs1            => 0, rs2 => 0, rd => 5,
            imm            => "0000" & "0000" & "0000" & "0000" & "0000" & "0011" & "0000" & "0001"
        );

        wait until CPU_state = DECODE;
        wait for clk_period;

        -- OR x5, x4, x5
        instruction <= codes_to_instruction(
            opcode         => REGISTR,
            funct_3_ALU    => OR_O,
            funct_3_memory => ERR_O,
            funct_3_branch => ERR_O,
            funct_7        => (others => '0'),
            rs1            => 4, rs2 => 5, rd => 5,
            imm            => (others => '0')
        );

        wait until CPU_state = DECODE;
        wait for clk_period;

        -- Store data to memory
        -- SW x5, 0x00000100(x0)
        instruction <= codes_to_instruction(
            opcode         => STORE,
            funct_3_ALU    => ERR_O,
            funct_3_memory => WORD_O,
            funct_3_branch => ERR_O,
            funct_7        => (others => '0'),
            rs1            => 0, rs2 => 5, rd => 0,
            imm            => std_logic_vector(to_unsigned(4, C_DATA_WIDTH))
        );

        wait until CPU_state = DECODE;
        wait for clk_period;

        -- LB x6, 0x00000100(x0)
        instruction <= codes_to_instruction(
            opcode         => LOAD,
            funct_3_ALU    => ERR_O,
            funct_3_memory => BYTE_O,
            funct_3_branch => ERR_O,
            funct_7        => (others => '0'),
            rs1            => 0, rs2 => 0, rd => 6,
            imm            => std_logic_vector(to_unsigned(4, C_DATA_WIDTH))
        );

        wait until CPU_state = MEMORY;
        wait until mem_done = '1';
        instruction <= data_from_mem;
        wait for clk_period * 1.5;
        assert data_to_cpu = "0000" & "0000" & "0000" & "0000" & "0000" & "0000" & "0000" & "0001" report "Wrong data" severity ERROR;

        wait until CPU_state = DECODE;
        wait for clk_period;

        -- LB x6, 0x00000101(x0)
        instruction <= codes_to_instruction(
            opcode         => LOAD,
            funct_3_ALU    => ERR_O,
            funct_3_memory => BYTE_O,
            funct_3_branch => ERR_O,
            funct_7        => (others => '0'),
            rs1            => 0, rs2 => 0, rd => 6,
            imm            => std_logic_vector(to_unsigned(4 + 1, C_DATA_WIDTH))
        );

        wait until CPU_state = MEMORY;
        wait until mem_done = '1';
        instruction <= data_from_mem;
        wait for clk_period * 1.5;
        assert data_to_cpu = "0000" & "0000" & "0000" & "0000" & "0000" & "0000" & "0000" & "0011" report "Wrong data" severity ERROR;

        wait until CPU_state = DECODE;
        wait for clk_period;

        -- LB x6, 0x00000110(x0)
        instruction <= codes_to_instruction(
            opcode         => LOAD,
            funct_3_ALU    => ERR_O,
            funct_3_memory => BYTE_O,
            funct_3_branch => ERR_O,
            funct_7        => (others => '0'),
            rs1            => 0, rs2 => 0, rd => 6,
            imm            => std_logic_vector(to_unsigned(4 + 2, C_DATA_WIDTH))
        );

        wait until CPU_state = MEMORY;
        wait until mem_done = '1';
        instruction <= data_from_mem;
        wait for clk_period * 1.5;
        assert data_to_cpu = "0000" & "0000" & "0000" & "0000" & "0000" & "0000" & "0000" & "0111" report "Wrong data" severity ERROR;

        wait until CPU_state = DECODE;
        wait for clk_period;

        -- LB x6, 0x00000111(x0)
        instruction <= codes_to_instruction(
            opcode         => LOAD,
            funct_3_ALU    => ERR_O,
            funct_3_memory => BYTE_O,
            funct_3_branch => ERR_O,
            funct_7        => (others => '0'),
            rs1            => 0, rs2 => 0, rd => 6,
            imm            => std_logic_vector(to_unsigned(4 + 3, C_DATA_WIDTH))
        );

        wait until CPU_state = MEMORY;
        wait until mem_done = '1';
        instruction <= data_from_mem;
        wait for clk_period * 1.5;
        assert data_to_cpu = "0000" & "0000" & "0000" & "0000" & "0000" & "0000" & "0000" & "1111" report "Wrong data" severity ERROR;

        wait for clk_period * 20;
        report "Done";
    end process tb;

end Behavioral;
