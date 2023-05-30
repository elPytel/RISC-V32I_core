----------------------------------------------------------------------------------
-- Company: TUL
-- Engineer: Jaroslav Korner
-- 
-- Create Date: 11.03.2023 17:49:04
-- Design Name: 
-- Module Name: PC_driver - Behavioral
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

entity PC_driver is
    Port(
        -- in
        clk               : in  std_logic;
        reset             : in  std_logic;
        ce                : in  std_logic;
        pc_branch         : in  std_logic;
        opcode            : in  t_OPCODE;
        immediate         : in  std_logic_vector(C_DATA_WIDTH - 1 downto 0);
        ALU_result        : in  std_logic_vector(C_DATA_WIDTH - 1 downto 0);
        exception_handler : in  std_logic;
        -- out
        PC_plus_4_out     : out std_logic_vector(C_DATA_WIDTH - 1 downto 0);
        PC_out            : out std_logic_vector(C_DATA_WIDTH - 1 downto 0);
        PC_error          : out std_logic
    );
end PC_driver;

architecture Behavioral of PC_driver is
    signal PC                             : std_logic_vector(C_MEM_ADDR_WIDTH - 1 downto 0);
    signal PC_next                        : std_logic_vector(C_MEM_ADDR_WIDTH - 1 downto 0);
    signal PC_plus_imm                    : std_logic_vector(C_MEM_ADDR_WIDTH - 1 downto 0);
    signal PC_plus_4                      : std_logic_vector(C_MEM_ADDR_WIDTH - 1 downto 0);
    signal instruction_address_misaligned : std_logic;
begin

    -- PC increment
    PC_plus_4   <= std_logic_vector(resize(unsigned(PC) + 4, PC_plus_4'length));
    PC_plus_imm <= std_logic_vector(to_unsigned(TO_INTEGER(unsigned(PC)) + TO_INTEGER(signed(immediate)), PC_plus_imm'length));

    -- PC exception
    instruction_address_misaligned <= '1' when PC_next(1 downto 0) /= "00" else '0';
    --    instruction_address_misaligned <= std_logic(PC_next(1 downto 0) /= "00");   

    -- PC update
    PC_update : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                PC <= (others => '0');
            elsif exception_handler = '1' then
                PC <= JKRiscV_exception_hendler;
            elsif ce = '1' and instruction_address_misaligned = '0' then
                PC <= PC_next;
            end if;
        end if;
    end process PC_update;

    -- PC source
    PC_source : process(opcode, ALU_result, PC_plus_4, PC_plus_imm, pc_branch)
    begin
        case opcode is
            when JALR_INST =>
                PC_next <= ALU_result(C_MEM_ADDR_WIDTH - 1 downto 1) & '0';
            when JAL_INST =>
                PC_next <= PC_plus_imm;
            when BRANCH =>
                if pc_branch = '1' then
                    PC_next <= PC_plus_imm;
                else
                    PC_next <= PC_plus_4;
                end if;
            when OTHERS =>
                PC_next <= PC_plus_4;
        end case;
    end process PC_source;

    -- PC out
    PC_out        <= PC;
    PC_plus_4_out <= PC_plus_4;
    PC_error      <= instruction_address_misaligned;

end Behavioral;
