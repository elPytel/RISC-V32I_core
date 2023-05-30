----------------------------------------------------------------------------------
-- Company: TUL
-- Engineer: Jaroslav Korner
-- 
-- Create Date: 04.12.2022 10:57:53
-- Design Name: 
-- Module Name: Core - Behavioral
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

use work.JKRiscV_types.all;

entity Core is
    port(
        -- in
        clk           : in  std_logic;
        reset         : in  std_logic;
        mem_done      : in  std_logic;
        data_from_mem : in  std_logic_vector(C_DATA_WIDTH - 1 downto 0);
        -- out
        CPU_state_out : out t_CPU_STATE;
        mem_address   : out std_logic_vector(C_MEM_ADDR_WIDTH - 1 downto 0);
        data_to_mem   : out std_logic_vector(C_DATA_WIDTH - 1 downto 0);
        mem_en        : out std_logic;
        mem_wren      : out std_logic_vector(C_DATA_WIDTH / C_BYTE_SIZE - 1 downto 0);
        reset_all     : out std_logic
    );
end Core;

architecture Behavioral of Core is

    -- ALU
    signal data1, data2 : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
    signal ALU_result   : std_logic_vector(C_DATA_WIDTH - 1 downto 0);

    -- ControlUnit
    signal opcode          : t_OPCODE;
    signal alufunc         : t_ALUFUNC;
    signal PC_jump_handler : std_logic;
    signal data_to_cpu     : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
    signal imm             : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
    signal rs2, rs1, rd    : std_logic_vector(C_REG_ADDR_WIDTH - 1 downto 0);

    -- registers
    signal regwr              : std_logic;
    signal wrdata             : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
    signal rs1_data, rs2_data : std_logic_vector(C_DATA_WIDTH - 1 downto 0);

    -- PC
    signal PC        : std_logic_vector(C_MEM_ADDR_WIDTH - 1 downto 0);
    signal PC_plus_4 : std_logic_vector(C_MEM_ADDR_WIDTH - 1 downto 0);
    signal PC_error  : std_logic;
    signal PC_ce     : std_logic;
    signal pc_branch : std_logic;

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
            r     => ALU_result
        );

    control_unit : entity work.ControlUnit
        port map(
            clk             => clk,
            reset_in        => reset,
            PC_error        => PC_error,
            PC              => PC,
            ALU_result      => ALU_result,
            data_from_mem   => data_from_mem,
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
            branch          => pc_branch,
            reg_write       => regwr,
            rs1             => rs1,
            rs2             => rs2,
            rd              => rd,
            CPU_state_out   => CPU_state_out
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

    program_counter : entity work.PC_driver
        port map(
            clk               => clk,
            reset             => reset_all,
            ce                => PC_ce,
            pc_branch         => pc_branch,
            opcode            => opcode,
            immediate         => imm,
            ALU_result        => ALU_result,
            exception_handler => PC_jump_handler,
            PC_plus_4_out     => PC_plus_4,
            PC_out            => PC,
            PC_error          => PC_error
        );

    -- register source
    register_source : process(opcode, ALU_result, data_to_cpu, imm, PC_plus_4)
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

end Behavioral;
