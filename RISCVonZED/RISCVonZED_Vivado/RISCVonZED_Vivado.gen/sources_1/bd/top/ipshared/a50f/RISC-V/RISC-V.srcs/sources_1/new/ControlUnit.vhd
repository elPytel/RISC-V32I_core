----------------------------------------------------------------------------------
-- Company: TUL
-- Engineer: Jaroslav Korner
-- 
-- Create Date: 29.11.2022 07:29:18
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

entity ControlUnit is
    port(
        -- int
        clk             : in  std_logic;
        reset_in        : in  std_logic;
        PC_error        : in  std_logic;
        PC              : in  std_logic_vector(C_DATA_WIDTH - 1 downto 0);
        ALU_result      : in  std_logic_vector(C_DATA_WIDTH - 1 downto 0);
        data_from_mem   : in  std_logic_vector(C_DATA_WIDTH - 1 downto 0);
        data_from_cpu   : in  std_logic_vector(C_DATA_WIDTH - 1 downto 0);
        mem_done        : in  std_logic;
        -- out
        reset_all       : out std_logic;
        opcode          : out t_OPCODE;
        -- ALU
        alufunc         : out t_ALUFUNC;
        imm             : out std_logic_vector(C_DATA_WIDTH - 1 downto 0);
        -- mem
        mem_en          : out std_logic;
        mem_address     : out std_logic_vector(C_DATA_WIDTH - 1 downto 0);
        data_to_mem     : out std_logic_vector(C_DATA_WIDTH - 1 downto 0);
        data_to_cpu     : out std_logic_vector(C_DATA_WIDTH - 1 downto 0);
        mem_wren        : out std_logic_vector(C_DATA_WIDTH / C_BYTE_SIZE - 1 downto 0);
        -- PC
        PC_ce           : out std_logic;
        PC_jump_handler : out std_logic;
        branch         : out std_logic;
        -- reg
        reg_write       : out std_logic;
        rs1             : out std_logic_vector(C_REG_ADDR_WIDTH - 1 downto 0);
        rs2             : out std_logic_vector(C_REG_ADDR_WIDTH - 1 downto 0);
        rd              : out std_logic_vector(C_REG_ADDR_WIDTH - 1 downto 0);
        -- debug
        CPU_state_out   : out t_CPU_STATE
    );
end entity ControlUnit;

architecture behavior of ControlUnit is

    signal CPU_state : t_CPU_STATE := HALT;

    -- instruction decoder
    signal instruction    : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
    signal funct_3_ALU    : t_FUNCT_3_ALU;
    signal funct_3_memory : t_FUNCT_3_MEMORY;
    signal funct_3_branch : t_FUNCT_3_BRANCH;
    signal funct_7        : std_logic_vector(C_FUNCT_7_WIDTH - 1 downto 0);

    -- memory
    signal data_address          : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
    signal data_address_formated : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
    signal Byte_addr             : std_logic_vector(1 downto 0);
    signal Byte_shift            : unsigned(C_MAX_SHIFT - 1 downto 0);
    signal from_mem_shifted      : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
    signal mem_error             : std_logic;

    -- exceptions
    signal exception_vector : std_logic_vector(C_EXCEPTION_VECTOR_WIDTH - 1 downto 0);
    signal new_exception    : std_logic;

    -- functions

begin

    instruction_parser : entity work.instruction_parser
        port map(
            instruction    => instruction,
            opcode         => opcode,
            funct_3_ALU    => funct_3_ALU,
            funct_3_memory => funct_3_memory,
            funct_3_branch => funct_3_branch,
            funct_7        => funct_7,
            rs1            => rs1,
            rs2            => rs2,
            rd             => rd,
            imm            => imm
        );

    -- memory control
    data_address          <= ALU_result;
    data_address_formated <= data_address(C_DATA_WIDTH - 1 downto 2) & "00";
    Byte_addr             <= data_address(1 downto 0);
    Byte_shift            <= to_unsigned(to_integer(unsigned(Byte_addr)) * C_BYTE_SIZE, C_MAX_SHIFT);
    data_to_mem           <= std_logic_vector(shift_left(signed(data_from_cpu), to_integer(Byte_shift)));
    from_mem_shifted      <= std_logic_vector(shift_right(unsigned(data_from_mem), to_integer(Byte_shift)));

    mem_error <= unaligned_address_check(opcode, Byte_addr, funct_3_memory);

    -- exception vector
    exception_raiser : process(clk)
    begin
        if rising_edge(clk) then
            if reset_in = '1' then
                exception_vector <= (others => '0');
                new_exception    <= '0';
            elsif PC_jump_handler = '1' then
                new_exception <= '0';
            else
                if PC_error = '1' then
                    new_exception                                      <= '1';
                    exception_vector(C_EXCEPTION_INST_ADDR_MISALIGNED) <= '1';
                elsif mem_error = '1' then
                    new_exception                                     <= '1';
                    exception_vector(C_EXCEPTION_MEM_ADDR_MISALIGNED) <= '1';
                elsif opcode = ERROR and CPU_state = EXECUTE then
                    new_exception                              <= '1';
                    exception_vector(C_EXCEPTION_ILLEGAL_INST) <= '1';
                elsif opcode = ECALL_BREAK_INST then
                    new_exception                             <= '1';
                    exception_vector(C_EXCEPTION_ECALL_BREAK) <= '1';
                end if;
            end if;
        end if;
    end process exception_raiser;

    -- will branche?
    branch <= branch_control(opcode, funct_3_branch, ALU_result);

    -- FSM change state
    FSM_change_state : process(clk)
    begin
        if rising_edge(clk) then
            -- default
            reg_write       <= '0';
            reset_all       <= '0';
            PC_ce           <= '0';
            mem_en          <= '0';
            PC_jump_handler <= '0';
            mem_wren        <= (others => '0');

            if reset_in = '1' then
                reset_all   <= '1';
                instruction <= (others => '0');
                mem_address <= (others => '0');
                data_to_cpu <= (others => '0');
                CPU_state   <= START;
            elsif new_exception = '1' then
                CPU_state <= EXCEPTION;
            else
                case CPU_state is
                    when START =>
                        CPU_state <= FETCH;

                    when FETCH =>
                        mem_address <= PC;
                        mem_en      <= '1';
                        CPU_state   <= DECODE;

                    when DECODE =>
                        if not mem_done = '1' then
                            CPU_state <= DECODE;
                        else
                            CPU_state   <= EXECUTE;
                            instruction <= data_from_mem;
                        end if;

                    when EXECUTE =>
                        alufunc <= ALU_control(opcode, funct_3_ALU, funct_3_branch, funct_7);
                        PC_ce   <= '1';
                        if RAM_control(opcode) = '1' then
                            CPU_state <= MEMORY;
                        else
                            CPU_state <= WRITEBACK;
                        end if;
                        -- hot fix
                        if opcode = JAL_INST then
                            reg_write <= '1';
                        end if;

                    when MEMORY =>
                        mem_en      <= RAM_control(opcode);
                        mem_address <= data_address_formated;
                        mem_wren    <= mem_wren_control(opcode, funct_3_memory, Byte_addr);
                        CPU_state   <= WRITEBACK;

                    when WRITEBACK =>
                        if RAM_control(opcode) = '1' and not mem_done = '1' then
                            CPU_state <= WRITEBACK;
                        else
                            if opcode = LOAD then
                                data_to_cpu <= data_from_memory_formater(funct_3_memory, from_mem_shifted);
                            end if;
                            reg_write <= register_control(opcode);
                            CPU_state <= FETCH;
                        end if;

                    when HALT =>
                        alufunc   <= ERR_F;
                        CPU_state <= HALT;

                    when EXCEPTION =>
                        -- TODO:
                        -- save PC to stack
                        -- x1 to stack
                        -- stack pointer + 4(x8 = 32)
                        -- x2 + 4
                        -- PC + 4 -> x1
                        -- jump to exception handler

                        PC_jump_handler <= '1';
                        alufunc         <= ERR_F;
                        CPU_state       <= DECODE;
                        CPU_state       <= HALT;

                    when others =>
                        CPU_state <= START;
                end case;
            end if;
        end if;
    end process FSM_change_state;

    -- FSM output
    CPU_state_out <= CPU_state;

end architecture behavior;
