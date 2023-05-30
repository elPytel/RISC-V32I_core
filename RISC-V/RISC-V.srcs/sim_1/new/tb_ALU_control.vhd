----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03.12.2022 22:52:15
-- Design Name: 
-- Module Name: ALU_control - Behavioral
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
use IEEE.math_real.all;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

use work.JKRiscV_types.all;

entity tb_ALU_control is
end tb_ALU_control;

architecture Behavioral of tb_ALU_control is

    -- clock
    constant clk_period : time      := 10 ns;
    signal clk          : std_logic := '0';

    -- ALU
    signal data1, data2 : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
    signal ALU_result   : std_logic_vector(C_DATA_WIDTH - 1 downto 0);

    -- ControlUnit
    signal opcode       : t_OPCODE;
    signal funct_3_ALU  : t_FUNCT_3_ALU;
    signal funct_7      : std_logic_vector(6 downto 0);
    signal alu_function : t_ALUFUNC;

    signal funct_3_memory : t_FUNCT_3_MEMORY;
    signal funct_3_branch : t_FUNCT_3_BRANCH;

    signal instruction  : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
    signal rs2, rs1, rd : std_logic_vector(C_REG_ADDR_WIDTH - 1 downto 0);
    signal imm          : std_logic_vector(C_DATA_WIDTH - 1 downto 0);

    procedure ALU_eval(constant func_3_in   : in t_FUNCT_3_ALU;
                       constant opcode_in   : in t_OPCODE;
                       constant rs2_value   : integer;
                       constant rs1_value   : integer;
                       constant rd_value    : integer;
                       constant func_7_in   : in std_logic_vector(6 downto 0);
                       signal   instruction : out std_logic_vector(C_DATA_WIDTH - 1 downto 0);
                       signal   x_out       : out std_logic_vector(C_DATA_WIDTH - 1 downto 0);
                       signal   y_out       : out std_logic_vector(C_DATA_WIDTH - 1 downto 0);
                       signal   r           : in std_logic_vector(C_DATA_WIDTH - 1 downto 0)) is
        -- dummy variables (will by bypassed)
        variable rs1_in : std_logic_vector(C_REG_ADDR_WIDTH - 1 downto 0) := (others => '0');
        variable rs2_in : std_logic_vector(C_REG_ADDR_WIDTH - 1 downto 0) := (others => '0');
        variable rd_in  : std_logic_vector(C_REG_ADDR_WIDTH - 1 downto 0) := (others => '0');
    begin
        -- prepare inputs for ALU
        -- (func_7, rs2, rs1, func_3, rd, opcode);
        instruction <= func_7_in & rs2_in & rs1_in & funct_3_ALU_to_std_logic_vector(func_3_in) & rd_in & opcode_to_std_logic_vector(opcode_in);
        x_out       <= std_logic_vector(to_signed(rs1_value, data1'length));
        y_out       <= std_logic_vector(to_signed(rs2_value, data2'length));

        -- evaluate
        wait for 2 * clk_period;

        -- test validity
        assert r = std_logic_vector(to_signed(rd_value, r'length))
        report integer'image(rd_value) & " != " & integer'image(TO_INTEGER(signed(r))) & LF & "From test case: " & t_FUNCT_3_ALU'image(func_3_in) & ", " & t_OPCODE'image(opcode_in) & LF & "rs1_value: " & integer'image(rs1_value) & " rs2_value: " & integer'image(rs2_value) & LF
        severity ERROR;

        wait for clk_period;
    end procedure ALU_eval;

    procedure ALU_binary_eval(constant func_3_in   : in t_FUNCT_3_ALU;
                              constant opcode_in   : in t_OPCODE;
                              constant rs2_value   : in std_logic_vector(C_DATA_WIDTH - 1 downto 0);
                              constant rs1_value   : in std_logic_vector(C_DATA_WIDTH - 1 downto 0);
                              constant rd_value    : in std_logic_vector(C_DATA_WIDTH - 1 downto 0);
                              constant func_7_in   : in std_logic_vector(6 downto 0);
                              signal   instruction : out std_logic_vector(C_DATA_WIDTH - 1 downto 0);
                              signal   x_out       : out std_logic_vector(C_DATA_WIDTH - 1 downto 0);
                              signal   y_out       : out std_logic_vector(C_DATA_WIDTH - 1 downto 0);
                              signal   r           : in std_logic_vector(C_DATA_WIDTH - 1 downto 0)) is
        -- dummy variables (will by bypassed)
        variable rs1_in : std_logic_vector(C_REG_ADDR_WIDTH - 1 downto 0) := (others => '0');
        variable rs2_in : std_logic_vector(C_REG_ADDR_WIDTH - 1 downto 0) := (others => '0');
        variable rd_in  : std_logic_vector(C_REG_ADDR_WIDTH - 1 downto 0) := (others => '0');
    begin
        -- prepare inputs for ALU
        -- (func_7, rs2, rs1, func_3, rd, opcode);
        instruction <= func_7_in & rs2_in & rs1_in & funct_3_ALU_to_std_logic_vector(func_3_in) & rd_in & opcode_to_std_logic_vector(opcode_in);
        x_out       <= rs1_value;
        y_out       <= rs2_value;

        -- evaluate
        wait for 2 * clk_period;

        -- test validity
        assert r = rd_value
        report integer'image(TO_INTEGER(signed(rd_value))) & " != " & integer'image(TO_INTEGER(signed(r))) & LF & "From test case: " & t_FUNCT_3_ALU'image(func_3_in) & ", " & t_OPCODE'image(opcode_in) & LF & "rs1_value: " & integer'image(TO_INTEGER(signed(rs1_value))) & " rs2_value: " & integer'image(TO_INTEGER(signed(rs2_value))) & LF & to_string(rd_value) & LF & to_string(r) & LF
        severity ERROR;

        wait for clk_period;
    end procedure ALU_binary_eval;

begin
    dut_ALU : entity work.ALU
        generic map(
            C_OUTPUT_REG => true
        )
        port map(
            clk   => clk,
            funct => alu_function,
            x     => data1,
            y     => data2,
            r     => ALU_result
        );

    dut_instruction_parser : entity work.instruction_parser
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

    clk <= not clk after clk_period / 2;

    alu_function <= ALU_control(opcode, funct_3_ALU, funct_3_branch, funct_7);

    tb : process
        variable func_3_in : t_FUNCT_3_ALU                := ERR_O;
        variable opcode_in : t_OPCODE                     := ERROR;
        variable func_7_in : std_logic_vector(6 downto 0) := (others => '0');
        variable rs2_value : integer                      := 0;
        variable rs1_value : integer                      := 0;
        variable rd_value  : integer                      := 0;
        variable rs1_in    : std_logic_vector(4 downto 0) := (others => '0');
        variable rs2_in    : std_logic_vector(4 downto 0) := (others => '0');
        variable rd_in     : std_logic_vector(4 downto 0) := (others => '0');
    begin
        -- NOP
        -- (func_7, rs2, rs1, func_3, rd, opcode);
        instruction <= func_7_in & rs2_in & rs1_in & funct_3_ALU_to_std_logic_vector(func_3_in) & rd_in & opcode_to_std_logic_vector(opcode_in);
        wait for clk_period;

        -- Arithmetic
        -- ERROR
        --        rs2_value := 5;
        --        rs1_value := 3;
        --        ALU_eval(
        --            func_3_in => ARIT_O, 
        --            opcode_in => REGISTR, 
        --            rs2_value => rs2_value, 
        --            rs1_value => rs1_value, 
        --            rd_value => rs2_value + rs1_value -1, 
        --            func_7_in => "0000000", 
        --            instruction => instruction, x_out => x, y_out => y, r => R
        --        );

        -- ADD
        rs2_value := 5;
        rs1_value := 2;
        ALU_eval(
            func_3_in   => ARIT_O,
            opcode_in   => REGISTR,
            rs2_value   => rs2_value,
            rs1_value   => rs1_value,
            rd_value    => rs2_value + rs1_value,
            func_7_in   => "0000000",
            instruction => instruction, x_out => data1, y_out => data2, r => ALU_result
        );

        rs2_value := 5;
        rs1_value := -7;
        ALU_eval(
            func_3_in   => ARIT_O,
            opcode_in   => REGISTR,
            rs2_value   => rs2_value,
            rs1_value   => rs1_value,
            rd_value    => rs2_value + rs1_value,
            func_7_in   => "0000000",
            instruction => instruction, x_out => data1, y_out => data2, r => ALU_result
        );

        rs2_value := 42;
        rs1_value := -42;
        ALU_eval(
            func_3_in   => ARIT_O,
            opcode_in   => REGISTR,
            rs2_value   => rs2_value,
            rs1_value   => rs1_value,
            rd_value    => rs2_value + rs1_value,
            func_7_in   => "0000000",
            instruction => instruction, x_out => data1, y_out => data2, r => ALU_result
        );

        -- SUB
        rs2_value := 12;
        rs1_value := 5;
        ALU_eval(
            func_3_in   => ARIT_O,
            opcode_in   => REGISTR,
            rs2_value   => rs2_value,
            rs1_value   => rs1_value,
            rd_value    => rs1_value - rs2_value,
            func_7_in   => "0100000",
            instruction => instruction, x_out => data1, y_out => data2, r => ALU_result
        );

        rs2_value := -6912;
        rs1_value := -8723;
        ALU_eval(
            func_3_in   => ARIT_O,
            opcode_in   => REGISTR,
            rs2_value   => rs2_value,
            rs1_value   => rs1_value,
            rd_value    => rs1_value - rs2_value,
            func_7_in   => "0100000",
            instruction => instruction, x_out => data1, y_out => data2, r => ALU_result
        );

        rs2_value := 18;
        rs1_value := 42;
        ALU_eval(
            func_3_in   => ARIT_O,
            opcode_in   => REGISTR,
            rs2_value   => rs2_value,
            rs1_value   => rs1_value,
            rd_value    => rs1_value - rs2_value,
            func_7_in   => "0100000",
            instruction => instruction, x_out => data1, y_out => data2, r => ALU_result
        );

        rs2_value := 0;
        rs1_value := 0;
        ALU_eval(
            func_3_in   => ARIT_O,
            opcode_in   => REGISTR,
            rs2_value   => rs2_value,
            rs1_value   => rs1_value,
            rd_value    => rs1_value - rs2_value,
            func_7_in   => "0100000",
            instruction => instruction, x_out => data1, y_out => data2, r => ALU_result
        );

        -- Compare numbers
        -- SLT, set on less than

        -- less
        ALU_eval(
            func_3_in   => SLT_O,
            opcode_in   => REGISTR,
            rs2_value   => 124,
            rs1_value   => 1,
            rd_value    => TO_INTEGER(JKRiscV_true),
            func_7_in   => "0000000",
            instruction => instruction, x_out => data1, y_out => data2, r => ALU_result
        );

        ALU_eval(
            func_3_in   => SLT_O,
            opcode_in   => REGISTR,
            rs2_value   => 1,
            rs1_value   => -1,
            rd_value    => TO_INTEGER(JKRiscV_true),
            func_7_in   => "0000000",
            instruction => instruction, x_out => data1, y_out => data2, r => ALU_result
        );

        -- equal
        ALU_eval(
            func_3_in   => SLT_O,
            opcode_in   => REGISTR,
            rs2_value   => 42,
            rs1_value   => 42,
            rd_value    => TO_INTEGER(JKRiscV_false),
            func_7_in   => "0000000",
            instruction => instruction, x_out => data1, y_out => data2, r => ALU_result
        );

        -- greater
        ALU_eval(
            func_3_in   => SLT_O,
            opcode_in   => REGISTR,
            rs2_value   => 42,
            rs1_value   => 2048,
            rd_value    => TO_INTEGER(JKRiscV_false),
            func_7_in   => "0000000",
            instruction => instruction, x_out => data1, y_out => data2, r => ALU_result
        );

        ALU_eval(
            func_3_in   => SLT_O,
            opcode_in   => REGISTR,
            rs2_value   => -2048,
            rs1_value   => -42,
            rd_value    => TO_INTEGER(JKRiscV_false),
            func_7_in   => "0000000",
            instruction => instruction, x_out => data1, y_out => data2, r => ALU_result
        );

        -- SLTU, set on less than unsigned

        -- less
        ALU_eval(
            func_3_in   => SLTU_O,
            opcode_in   => REGISTR,
            rs2_value   => 11112,
            rs1_value   => 11111,
            rd_value    => TO_INTEGER(JKRiscV_true),
            func_7_in   => "0000000",
            instruction => instruction, x_out => data1, y_out => data2, r => ALU_result
        );

        -- equal
        ALU_eval(
            func_3_in   => SLTU_O,
            opcode_in   => REGISTR,
            rs2_value   => 123456789,
            rs1_value   => 123456789,
            rd_value    => TO_INTEGER(JKRiscV_false),
            func_7_in   => "0000000",
            instruction => instruction, x_out => data1, y_out => data2, r => ALU_result
        );

        -- greater
        ALU_eval(
            func_3_in   => SLTU_O,
            opcode_in   => REGISTR,
            rs2_value   => 2048,
            rs1_value   => 2049,
            rd_value    => TO_INTEGER(JKRiscV_false),
            func_7_in   => "0000000",
            instruction => instruction, x_out => data1, y_out => data2, r => ALU_result
        );

        -- Shifts & rotates
        -- SLL, shift left logical
        -- static 32bits tests
        ALU_binary_eval(
            func_3_in   => SLL_O,
            opcode_in   => REGISTR,
            rs2_value   => "00000000000000000000000000000001",
            rs1_value   => "00000000000000000000000000000000",
            rd_value    => "00000000000000000000000000000000",
            func_7_in   => "0000000",
            instruction => instruction, x_out => data1, y_out => data2, r => ALU_result
        );

        ALU_binary_eval(
            func_3_in   => SLL_O,
            opcode_in   => REGISTR,
            rs2_value   => "00000000000000000000000000000000",
            rs1_value   => "00000000000000000000000000000001",
            rd_value    => "00000000000000000000000000000001",
            func_7_in   => "0000000",
            instruction => instruction, x_out => data1, y_out => data2, r => ALU_result
        );

        ALU_binary_eval(
            func_3_in   => SLL_O,
            opcode_in   => REGISTR,
            rs2_value   => "00000000000000000000000000000001",
            rs1_value   => "10000000000000000000000000000000",
            rd_value    => "00000000000000000000000000000000",
            func_7_in   => "0000000",
            instruction => instruction, x_out => data1, y_out => data2, r => ALU_result
        );

        rs2_value := 1;
        ALU_binary_eval(
            func_3_in   => SLL_O,
            opcode_in   => REGISTR,
            rs2_value   => std_logic_vector(to_signed(rs2_value, C_DATA_WIDTH)),
            rs1_value   => "00000000000000000000000000000001",
            rd_value    => "00000000000000000000000000000010",
            func_7_in   => "0000000",
            instruction => instruction, x_out => data1, y_out => data2, r => ALU_result
        );

        rs1_value := 5;
        rs2_value := 2;
        ALU_eval(
            func_3_in   => SLL_O,
            opcode_in   => REGISTR,
            rs2_value   => rs2_value,
            rs1_value   => rs1_value,
            rd_value    => rs1_value * (2 ** rs2_value),
            func_7_in   => "0000000",
            instruction => instruction, x_out => data1, y_out => data2, r => ALU_result
        );

        -- SRL, shift right logical
        ALU_binary_eval(
            func_3_in   => SR_O,
            opcode_in   => REGISTR,
            rs2_value   => "00000000000000000000000000000001",
            rs1_value   => "00000000000000000000000000000000",
            rd_value    => "00000000000000000000000000000000",
            func_7_in   => "0000000",
            instruction => instruction, x_out => data1, y_out => data2, r => ALU_result
        );

        ALU_binary_eval(
            func_3_in   => SR_O,
            opcode_in   => REGISTR,
            rs2_value   => "00000000000000000000000000000000",
            rs1_value   => "00000000000000000000000000000001",
            rd_value    => "00000000000000000000000000000001",
            func_7_in   => "0000000",
            instruction => instruction, x_out => data1, y_out => data2, r => ALU_result
        );

        ALU_binary_eval(
            func_3_in   => SR_O,
            opcode_in   => REGISTR,
            rs2_value   => "00000000000000000000000000000001",
            rs1_value   => "10000000000000000000000000000000",
            rd_value    => "01000000000000000000000000000000",
            func_7_in   => "0000000",
            instruction => instruction, x_out => data1, y_out => data2, r => ALU_result
        );

        rs2_value := 1;
        ALU_binary_eval(
            func_3_in   => SR_O,
            opcode_in   => REGISTR,
            rs2_value   => std_logic_vector(to_signed(rs2_value, C_DATA_WIDTH)),
            rs1_value   => "00000000000000000000000000000001",
            rd_value    => "00000000000000000000000000000000",
            func_7_in   => "0000000",
            instruction => instruction, x_out => data1, y_out => data2, r => ALU_result
        );

        rs1_value := 64;
        rs2_value := 2;
        ALU_eval(
            func_3_in   => SR_O,
            opcode_in   => REGISTR,
            rs2_value   => rs2_value,
            rs1_value   => rs1_value,
            rd_value    => rs1_value / (2 ** rs2_value),
            func_7_in   => "0000000",
            instruction => instruction, x_out => data1, y_out => data2, r => ALU_result
        );

        -- SRA, shift right arithmetical
        ALU_binary_eval(
            func_3_in   => SR_O,
            opcode_in   => REGISTR,
            rs2_value   => "00000000000000000000000000000001",
            rs1_value   => "10000000000000000000000000000100",
            rd_value    => "11000000000000000000000000000010",
            func_7_in   => "0100000",
            instruction => instruction, x_out => data1, y_out => data2, r => ALU_result
        );

        ALU_binary_eval(
            func_3_in   => SR_O,
            opcode_in   => REGISTR,
            rs2_value   => "00000000000000000000000000000001",
            rs1_value   => "00000000000000000000000000001000",
            rd_value    => "00000000000000000000000000000100",
            func_7_in   => "0100000",
            instruction => instruction, x_out => data1, y_out => data2, r => ALU_result
        );

        -- shift by 5 lower bits of rs2
        ALU_binary_eval(
            func_3_in   => SR_O,
            opcode_in   => REGISTR,
            rs2_value   => "00000000000000000000000000100001",
            rs1_value   => "10000000000000000000000000001000",
            rd_value    => "11000000000000000000000000000100",
            func_7_in   => "0100000",
            instruction => instruction, x_out => data1, y_out => data2, r => ALU_result
        );

        rs2_value := 5;
        ALU_binary_eval(
            func_3_in   => SR_O,
            opcode_in   => REGISTR,
            rs2_value   => std_logic_vector(to_signed(rs2_value, C_DATA_WIDTH)),
            rs1_value   => "10000000000000000000000010100000",
            rd_value    => "11111100000000000000000000000101",
            func_7_in   => "0100000",
            instruction => instruction, x_out => data1, y_out => data2, r => ALU_result
        );

        -- Bitwise operations
        -- XOR
        ALU_binary_eval(
            func_3_in   => XOR_O,
            opcode_in   => REGISTR,
            rs2_value   => "11111111000000001111111100000000",
            rs1_value   => "11111111111111110000000000000000",
            rd_value    => "00000000111111111111111100000000",
            func_7_in   => "0000000",
            instruction => instruction, x_out => data1, y_out => data2, r => ALU_result
        );

        -- OR
        ALU_binary_eval(
            func_3_in   => OR_O,
            opcode_in   => REGISTR,
            rs2_value   => "11111111000000001111111100000000",
            rs1_value   => "11111111111111110000000000000000",
            rd_value    => "11111111111111111111111100000000",
            func_7_in   => "0000000",
            instruction => instruction, x_out => data1, y_out => data2, r => ALU_result
        );

        -- AND
        ALU_binary_eval(
            func_3_in   => AND_O,
            opcode_in   => REGISTR,
            rs2_value   => "11111111000000001111111100000000",
            rs1_value   => "11111111111111110000000000000000",
            rd_value    => "11111111000000000000000000000000",
            func_7_in   => "0000000",
            instruction => instruction, x_out => data1, y_out => data2, r => ALU_result
        );

        wait for clk_period * 200;
        report "Done";
    end process tb;

end Behavioral;
