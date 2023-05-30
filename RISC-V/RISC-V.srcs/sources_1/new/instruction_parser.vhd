----------------------------------------------------------------------------------
-- Company: TUL
-- Engineer: Jaroslav Korner
-- 
-- Create Date: 03.12.2022 23:17:18
-- Design Name: 
-- Module Name: instruction_parser - Behavioral
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

entity instruction_parser is
    port(
        instruction    : in  std_logic_vector(C_DATA_WIDTH - 1 downto 0);
        opcode         : out t_OPCODE;
        funct_3_ALU    : out t_FUNCT_3_ALU;
        funct_3_memory : out t_FUNCT_3_MEMORY;
        funct_3_branch : out t_FUNCT_3_BRANCH;
        funct_7        : out std_logic_vector(C_FUNCT_7_WIDTH - 1 downto 0);
        rs1            : out std_logic_vector(C_REG_ADDR_WIDTH - 1 downto 0);
        rs2            : out std_logic_vector(C_REG_ADDR_WIDTH - 1 downto 0);
        rd             : out std_logic_vector(C_REG_ADDR_WIDTH - 1 downto 0);
        imm            : out std_logic_vector(C_DATA_WIDTH - 1 downto 0)
    );

    -- TODO: function extend_immediate(instruction, encoding, funct_3_ALU, opcode) return std_logic_vector;

end instruction_parser;

architecture Behavioral of instruction_parser is
    signal encoding : t_ENCODING;
begin
    encoding <= to_encoding(instruction(C_OPCODE_WIDTH - 1 downto 0));

    -- common fields for R-type, I-type, S-type, B-type, U-type, J-type instructions
    funct_7        <= instruction(C_FUNCT_7_LOW + C_FUNCT_7_WIDTH - 1 downto C_FUNCT_7_LOW);
    rs2            <= instruction(C_RS2_ADDR_LOW + C_REG_ADDR_WIDTH - 1 downto C_RS2_ADDR_LOW);
    rs1            <= instruction(C_RS1_ADDR_LOW + C_REG_ADDR_WIDTH - 1 downto C_RS1_ADDR_LOW);
    funct_3_ALU    <= to_funct_3_ALU(instruction(C_FUNCT_3_LOW + C_FUNCT_3_WIDTH - 1 downto C_FUNCT_3_LOW));
    funct_3_memory <= to_funct_3_memory(instruction(C_FUNCT_3_LOW + C_FUNCT_3_WIDTH - 1 downto C_FUNCT_3_LOW));
    funct_3_branch <= to_funct_3_branch(instruction(C_FUNCT_3_LOW + C_FUNCT_3_WIDTH - 1 downto C_FUNCT_3_LOW));
    rd             <= instruction(C_RD_ADDR_LOW + C_REG_ADDR_WIDTH - 1 downto C_RD_ADDR_LOW);
    opcode         <= to_opcode(instruction(C_OPCODE_WIDTH - 1 downto 0));

    parser : process(instruction, encoding, funct_3_ALU, opcode)
        variable shamt  : std_logic_vector(C_REG_ADDR_WIDTH - 1 downto 0) := (others => '0');
        variable imm_12 : std_logic_vector(11 downto 0)                   := (others => '0');
        variable imm_20 : std_logic_vector(19 downto 0)                   := (others => '0');
    begin
        case encoding is
            when R_TYPE =>
                -- R-type instructions (funct_7, rs2, rs1, funct_3, rd, opcode)
                imm <= (others => '0');
            when I_TYPE =>
                -- I-type instructions (imm_12, rs1, funct_3, rd, opcode)
                if opcode = IMMEDIATE and (funct_3_ALU = SLL_O or funct_3_ALU = SR_O) then -- or SRLAI_O
                    shamt := instruction(20 + C_REG_ADDR_WIDTH - 1 downto 20);
                    imm   <= std_logic_vector(RESIZE(signed(shamt), imm'length));
                else
                    imm_12 := instruction(31 downto 20);
                    imm    <= std_logic_vector(RESIZE(signed(imm_12), imm'length));
                end if;
            when S_TYPE =>
                -- S-type instructions (imm_11-5, rs2, rs1, funct_3, imm_4-0, opcode)
                imm_12 := instruction(31 downto 25) & instruction(11 downto 7);
                imm    <= std_logic_vector(RESIZE(signed(imm_12), imm'length));
            when B_TYPE =>
                -- B-type instructions (imm_12, imm_10-5, rs2, rs1, funct_3, imm_4-1, imm_11, opcode)
                imm_12 := instruction(31) & instruction(7) & instruction(30 downto 25) & instruction(11 downto 8);
                imm    <= std_logic_vector(RESIZE(signed(imm_12 & '0'), imm'length));
            when U_TYPE =>
                -- U-type instructions (imm_31-12, rd, opcode)
                imm_20 := instruction(31 downto 12);
                imm    <= (imm_20, others => '0');
            when J_TYPE =>
                -- J-type instructions (imm_20, imm_10-1, imm_11, imm_19-12, rd, opcode)
                imm_20 := instruction(31) & instruction(19 downto 12) & instruction(20) & instruction(30 downto 21);
                imm    <= std_logic_vector(RESIZE(signed(imm_20 & '0'), imm'length));
            when OTHERS =>
                imm <= (others => '0');
        end case;
    end process parser;

end Behavioral;
