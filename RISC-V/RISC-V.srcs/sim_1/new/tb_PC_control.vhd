----------------------------------------------------------------------------------
-- Company: TUL
-- Engineer: Jaroslav Korner
-- 
-- Create Date: 15.03.2023 22:35:31
-- Design Name: 
-- Module Name: tb_PC_control - Behavioral
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

entity tb_PC_control is
end tb_PC_control;

architecture Behavioral of tb_PC_control is

    -- clock
    constant clk_period : time      := 10 ns;
    signal clk          : std_logic := '0';

    -- ALU
    signal data1, data2 : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
    signal R            : std_logic_vector(C_DATA_WIDTH - 1 downto 0);

    -- ControlUnit
    signal opcode         : t_OPCODE;
    signal funct_3_ALU    : t_FUNCT_3_ALU;
    signal funct_3_memory : t_FUNCT_3_MEMORY;
    signal funct_3_branch : t_FUNCT_3_BRANCH;
    signal funct_7        : std_logic_vector(C_FUNCT_7_WIDTH - 1 downto 0);
    signal alufunc        : t_ALUFUNC;
    signal reset          : std_logic := '0';
    signal CPU_state      : t_CPU_STATE;

    -- instr fetch
    signal instruction  : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
    signal imm          : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
    signal rs2, rs1, rd : std_logic_vector(C_REG_ADDR_WIDTH - 1 downto 0);
    signal encoding     : t_ENCODING;

    -- registers
    signal regwr              : std_logic;
    signal wrdata             : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
    signal rs1_data, rs2_data : std_logic_vector(C_DATA_WIDTH - 1 downto 0);

    -- PC
    signal PC              : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
    signal PC_plus_4       : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
    signal PC_jump_handler : std_logic;
    signal PC_error        : std_logic;
    signal reset_all       : std_logic;
    signal PC_ce           : std_logic;
    signal to_branch       : std_logic;

    -- RAM
    signal ram_dout    : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
    signal mem_done    : std_logic;
    signal mem_en      : std_logic;
    signal mem_wren    : STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal data_to_mem : STD_LOGIC_VECTOR(C_DATA_WIDTH - 1 DOWNTO 0);
    signal data_to_cpu : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
    signal debug_enb   : STD_LOGIC;
    signal debug_web   : STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal debug_addrb : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal debug_dinb  : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal debug_doutb : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal mem_address : STD_LOGIC_VECTOR(31 DOWNTO 0);

    -- exception
    signal new_exception : std_logic;

begin

    ALU : entity work.ALU
        generic map(
            C_OUTPUT_REG => FALSE
        )
        port map(
            clk   => clk,
            funct => alufunc,
            x     => data1,
            y     => data2,
            r     => R
        );

    control_unit : entity work.ControlUnit
        port map(
            clk             => clk,
            reset_in        => reset,
            PC_error        => PC_error,
            PC              => PC,
            ALU_result      => R,
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
            branch          => to_branch,
            reg_write       => regwr,
            rs1             => rs1,
            rs2             => rs2,
            rd              => rd,
            CPU_state_out   => CPU_state
        );

    instruction_parser : entity work.instruction_parser
        port map(
            instruction    => instruction,
            funct_3_ALU    => funct_3_ALU,
            funct_3_memory => funct_3_memory,
            funct_3_branch => funct_3_branch,
            funct_7        => funct_7
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
            MEMORY_SIZE_BYTES => 4096,
            MEMORY_INIT_FILE  => "empty_ram.mem"
        )
        port map(
            clka  => clk,
            ena   => mem_en,
            wea   => mem_wren,
            addra => mem_address,
            dina  => data_to_mem,
            douta => ram_dout,
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

    program_counter : entity work.PC_driver
        port map(
            clk               => clk,
            reset             => reset_all,
            ce                => PC_ce,
            pc_branch         => to_branch,
            opcode            => opcode,
            immediate         => imm,
            ALU_result        => R,
            exception_handler => PC_jump_handler,
            PC_plus_4_out     => PC_plus_4,
            PC_out            => PC,
            PC_error          => PC_error
        );

    -- exception vector
    exception_raiser : process(clk, reset_all, PC_jump_handler)
    begin
        if reset_all = '1' then
            new_exception <= '0';
        elsif PC_jump_handler = '1' then
            new_exception <= '0';
        elsif rising_edge(clk) then
            if PC_error = '1' then
                new_exception <= '1';
            end if;
        end if;
    end process exception_raiser;

    -- register source
    register_source : process(opcode, R, data_to_cpu, imm, PC_plus_4)
    begin
        case opcode is
            when LUI_INST =>
                wrdata <= imm;
            when JAL_INST | JALR_INST =>
                wrdata <= PC_plus_4;
            when LOAD =>
                wrdata <= data_to_cpu;
            when STORE =>
                wrdata <= (others => '0');
            when OTHERS =>
                wrdata <= R;
        end case;
    end process register_source;

    -- ALU source
    ALU_source : process(opcode, imm, rs2_data, PC, rs1_data)
    begin
        -- y source
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

        -- x source
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
        variable value : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
    begin
        -- INST dest, src1, src2
        -- AUIPC_INST, JAL_INST, JALR_INST, BRANCH
        -- type t_FUNCT_3_BRANCH is (BEQ_O, BNE_O, BLT_O, BGE_O, BLTU_O, BGEU_O, ERR_O);

        -- reset
        wait for clk_period;
        reset <= '1';
        wait until reset_all = '1';
        wait for clk_period;
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

        -- unconditional jumps
        instruction <= codes_to_instruction(
            opcode         => AUIPC_INST,
            funct_3_ALU    => ERR_O,
            funct_3_memory => ERR_O,
            funct_3_branch => ERR_O,
            funct_7        => (others => '0'),
            rs1            => 0, rs2 => 0, rd => 1,
            imm            => "0000" & "1111" & "1111" & "1111" & "1111" & "0000" & "0000" & "0000"
        );

        wait until CPU_state = DECODE;
        wait for clk_period;

        instruction <= codes_to_instruction(
            opcode         => JAL_INST,
            funct_3_ALU    => ERR_O,
            funct_3_memory => ERR_O,
            funct_3_branch => ERR_O,
            funct_7        => (others => '0'),
            rs1            => 0, rs2 => 0, rd => 2,
            imm            => "0000" & "0000" & "0000" & "0000" & "0000" & "1111" & "0000" & "0000"
        );

        wait until CPU_state = DECODE;
        wait for clk_period;

        instruction <= codes_to_instruction(
            opcode         => JALR_INST,
            funct_3_ALU    => ERR_O,
            funct_3_memory => ERR_O,
            funct_3_branch => ERR_O,
            funct_7        => (others => '0'),
            rs1            => 1, rs2 => 0, rd => 2,
            imm            => "0000" & "0000" & "0000" & "0000" & "0000" & "0110" & "0000" & "0000"
        );

        wait until CPU_state = DECODE;
        wait for clk_period;

        -- inicialization of registers

        -- ADDI x10, x0, 10
        instruction <= codes_to_instruction(
            opcode         => IMMEDIATE,
            funct_3_ALU    => ARIT_O,
            funct_3_memory => ERR_O,
            funct_3_branch => ERR_O,
            funct_7        => (others => '0'),
            rs1            => 0, rs2 => 0, rd => 10,
            imm            => std_logic_vector(to_unsigned(10, C_DATA_WIDTH))
        );

        wait until CPU_state = DECODE;
        wait for clk_period;

        -- ADDI x11, x0, 11
        instruction <= codes_to_instruction(
            opcode         => IMMEDIATE,
            funct_3_ALU    => ARIT_O,
            funct_3_memory => ERR_O,
            funct_3_branch => ERR_O,
            funct_7        => (others => '0'),
            rs1            => 0, rs2 => 0, rd => 11,
            imm            => std_logic_vector(to_unsigned(11, C_DATA_WIDTH))
        );

        wait until CPU_state = DECODE;
        wait for clk_period;

        -- ADDI x12, x0, 12
        instruction <= codes_to_instruction(
            opcode         => IMMEDIATE,
            funct_3_ALU    => ARIT_O,
            funct_3_memory => ERR_O,
            funct_3_branch => ERR_O,
            funct_7        => (others => '0'),
            rs1            => 0, rs2 => 0, rd => 12,
            imm            => std_logic_vector(to_unsigned(12, C_DATA_WIDTH))
        );

        wait until PC_ce = '1';
        wait for clk_period;

        -- conditional branches
        reset <= '1';
        wait for clk_period;
        reset <= '0';
        wait until mem_done;

        -- BEQ
        --value := "0000" & "0000" & "0000" & "0111" & "0010" & "0100" & "1110" & "0000";
        value       := "0000" & "0000" & "0000" & "0000" & "0000" & "0000" & "0001" & "0000";
        instruction <= codes_to_instruction(
            opcode         => BRANCH,
            funct_3_ALU    => ERR_O,
            funct_3_memory => ERR_O,
            funct_3_branch => BEQ_O,
            funct_7        => (others => '0'),
            rs1            => 10, rs2 => 10, rd => 0,
            imm            => value
        );

        wait until PC_ce = '1';
        wait for clk_period;
        assert to_branch = '1'
        report "BRANCHE failed!" & LF & --integer'image(TO_INTEGER(signed(value))) & " != " & integer'image(TO_INTEGER(signed(PC))) & LF &
        "From test case: " & t_FUNCT_3_BRANCH'image(funct_3_branch) & ", " & t_OPCODE'image(opcode) & LF
        severity ERROR;

        wait until CPU_state = DECODE;
        wait for clk_period;

        value       := "0000" & "0000" & "0000" & "0000" & "0000" & "0000" & "0001" & "0000";
        instruction <= codes_to_instruction(
            opcode         => BRANCH,
            funct_3_ALU    => ERR_O,
            funct_3_memory => ERR_O,
            funct_3_branch => BEQ_O,
            funct_7        => (others => '0'),
            rs1            => 10, rs2 => 11, rd => 0,
            imm            => value
        );

        wait until PC_ce = '1';
        wait for clk_period;
        assert to_branch = '0'
        report "BRANCHE failed!" & LF & "From test case: " & t_FUNCT_3_BRANCH'image(funct_3_branch) & ", " & t_OPCODE'image(opcode) & LF
        severity ERROR;

        wait until CPU_state = DECODE;
        wait for clk_period;

        -- BNE
        value       := "0000" & "0000" & "0000" & "0000" & "0000" & "0000" & "0010" & "0000";
        instruction <= codes_to_instruction(
            opcode         => BRANCH,
            funct_3_ALU    => ERR_O,
            funct_3_memory => ERR_O,
            funct_3_branch => BNE_O,
            funct_7        => (others => '0'),
            rs1            => 10, rs2 => 10, rd => 0,
            imm            => value
        );

        wait until PC_ce = '1';
        wait for clk_period;
        assert to_branch = '0'
        report "BRANCHE failed!" & LF & "From test case: " & t_FUNCT_3_BRANCH'image(funct_3_branch) & ", " & t_OPCODE'image(opcode) & LF
        severity ERROR;

        wait until CPU_state = DECODE;
        wait for clk_period;

        value       := "0000" & "0000" & "0000" & "0000" & "0000" & "0000" & "0010" & "0000";
        instruction <= codes_to_instruction(
            opcode         => BRANCH,
            funct_3_ALU    => ERR_O,
            funct_3_memory => ERR_O,
            funct_3_branch => BNE_O,
            funct_7        => (others => '0'),
            rs1            => 10, rs2 => 11, rd => 0,
            imm            => value
        );

        wait until PC_ce = '1';
        wait for clk_period;
        assert to_branch = '1'
        report "BRANCHE failed!" & LF & "From test case: " & t_FUNCT_3_BRANCH'image(funct_3_branch) & ", " & t_OPCODE'image(opcode) & LF
        severity ERROR;

        wait until CPU_state = DECODE;
        wait for clk_period;

        -- BLT
        value       := "0000" & "0000" & "0000" & "0000" & "0000" & "0001" & "0000" & "0000";
        instruction <= codes_to_instruction(
            opcode         => BRANCH,
            funct_3_ALU    => ERR_O,
            funct_3_memory => ERR_O,
            funct_3_branch => BLT_O,
            funct_7        => (others => '0'),
            rs1            => 10, rs2 => 11, rd => 0,
            imm            => value
        );

        wait until PC_ce = '1';
        wait for clk_period;
        assert to_branch = '1'
        report "BRANCHE failed!" & LF & "From test case: " & t_FUNCT_3_BRANCH'image(funct_3_branch) & ", " & t_OPCODE'image(opcode) & LF
        severity ERROR;

        wait until CPU_state = DECODE;
        wait for clk_period;

        value       := "0000" & "0000" & "0000" & "0000" & "0000" & "0001" & "0000" & "0000";
        instruction <= codes_to_instruction(
            opcode         => BRANCH,
            funct_3_ALU    => ERR_O,
            funct_3_memory => ERR_O,
            funct_3_branch => BLT_O,
            funct_7        => (others => '0'),
            rs1            => 11, rs2 => 10, rd => 0,
            imm            => value
        );

        wait until PC_ce = '1';
        wait for clk_period;
        assert to_branch = '0'
        report "BRANCHE failed!" & LF & "From test case: " & t_FUNCT_3_BRANCH'image(funct_3_branch) & ", " & t_OPCODE'image(opcode) & LF
        severity ERROR;

        wait until CPU_state = DECODE;
        wait for clk_period;

        -- BLTU
        value       := "0000" & "0000" & "0000" & "0000" & "0000" & "0010" & "0000" & "0000";
        instruction <= codes_to_instruction(
            opcode         => BRANCH,
            funct_3_ALU    => ERR_O,
            funct_3_memory => ERR_O,
            funct_3_branch => BLTU_O,
            funct_7        => (others => '0'),
            rs1            => 10, rs2 => 11, rd => 0,
            imm            => value
        );

        wait until PC_ce = '1';
        wait for clk_period;
        assert to_branch = '1'
        report "BRANCHE failed!" & LF & "From test case: " & t_FUNCT_3_BRANCH'image(funct_3_branch) & ", " & t_OPCODE'image(opcode) & LF
        severity ERROR;

        wait until CPU_state = DECODE;
        wait for clk_period;

        value       := "0000" & "0000" & "0000" & "0000" & "0000" & "0010" & "0000" & "0000";
        instruction <= codes_to_instruction(
            opcode         => BRANCH,
            funct_3_ALU    => ERR_O,
            funct_3_memory => ERR_O,
            funct_3_branch => BLTU_O,
            funct_7        => (others => '0'),
            rs1            => 11, rs2 => 10, rd => 0,
            imm            => value
        );

        wait until PC_ce = '1';
        wait for clk_period;
        assert to_branch = '0'
        report "BRANCHE failed!" & LF & "From test case: " & t_FUNCT_3_BRANCH'image(funct_3_branch) & ", " & t_OPCODE'image(opcode) & LF
        severity ERROR;

        wait until CPU_state = DECODE;
        wait for clk_period;

        -- BGE
        value       := "0000" & "0000" & "0000" & "0000" & "0000" & "0100" & "0000" & "0000";
        instruction <= codes_to_instruction(
            opcode         => BRANCH,
            funct_3_ALU    => ERR_O,
            funct_3_memory => ERR_O,
            funct_3_branch => BGE_O,
            funct_7        => (others => '0'),
            rs1            => 10, rs2 => 11, rd => 0,
            imm            => value
        );

        wait until PC_ce = '1';
        wait for clk_period;
        assert to_branch = '0'
        report "BRANCHE failed!" & LF & "From test case: " & t_FUNCT_3_BRANCH'image(funct_3_branch) & ", " & t_OPCODE'image(opcode) & LF
        severity ERROR;

        wait until CPU_state = DECODE;
        wait for clk_period;

        value       := "0000" & "0000" & "0000" & "0000" & "0000" & "0100" & "0000" & "0000";
        instruction <= codes_to_instruction(
            opcode         => BRANCH,
            funct_3_ALU    => ERR_O,
            funct_3_memory => ERR_O,
            funct_3_branch => BGE_O,
            funct_7        => (others => '0'),
            rs1            => 11, rs2 => 10, rd => 0,
            imm            => value
        );

        wait until PC_ce = '1';
        wait for clk_period;
        assert to_branch = '1'
        report "BRANCHE failed!" & LF & "From test case: " & t_FUNCT_3_BRANCH'image(funct_3_branch) & ", " & t_OPCODE'image(opcode) & LF
        severity ERROR;

        wait until CPU_state = DECODE;
        wait for clk_period;

        -- BGEU
        value       := "0000" & "0000" & "0000" & "0000" & "0000" & "1000" & "0000" & "0000";
        instruction <= codes_to_instruction(
            opcode         => BRANCH,
            funct_3_ALU    => ERR_O,
            funct_3_memory => ERR_O,
            funct_3_branch => BGEU_O,
            funct_7        => (others => '0'),
            rs1            => 10, rs2 => 11, rd => 0,
            imm            => value
        );

        wait until PC_ce = '1';
        wait for clk_period;
        assert to_branch = '0'
        report "BRANCHE failed!" & LF & "From test case: " & t_FUNCT_3_BRANCH'image(funct_3_branch) & ", " & t_OPCODE'image(opcode) & LF
        severity ERROR;

        wait until CPU_state = DECODE;
        wait for clk_period;

        value       := "0000" & "0000" & "0000" & "0000" & "0000" & "1000" & "0000" & "0000";
        instruction <= codes_to_instruction(
            opcode         => BRANCH,
            funct_3_ALU    => ERR_O,
            funct_3_memory => ERR_O,
            funct_3_branch => BGEU_O,
            funct_7        => (others => '0'),
            rs1            => 11, rs2 => 10, rd => 0,
            imm            => value
        );

        wait until PC_ce = '1';
        wait for clk_period;
        assert to_branch = '1'
        report "BRANCHE failed!" & LF & "From test case: " & t_FUNCT_3_BRANCH'image(funct_3_branch) & ", " & t_OPCODE'image(opcode) & LF
        severity ERROR;

        -- END OF BRANCH TESTS

        wait until CPU_state = DECODE;
        wait for clk_period;

        instruction <= codes_to_instruction(
            opcode         => ERROR,
            funct_3_ALU    => ERR_O,
            funct_3_memory => ERR_O,
            funct_3_branch => ERR_O,
            funct_7        => (others => '0'),
            rs1            => 0, rs2 => 0, rd => 0,
            imm            => (others => '0')
        );

        wait for clk_period * 20;
        report "Done";
    end process tb;

end Behavioral;
