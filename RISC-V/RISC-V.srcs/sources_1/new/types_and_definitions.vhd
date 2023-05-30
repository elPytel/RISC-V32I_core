----------------------------------------------------------------------------------
-- Company: TUL
-- Engineer: Jaroslav Korner
-- 
-- Create Date: 29.11.2022 07:29:18
-- Design Name: 
-- Module Name: 
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
use IEEE.NUMERIC_STD.ALL;

package JKRiscV_types is

    constant JKRiscV_true  : signed(1 downto 0) := to_signed(1, 2);
    constant JKRiscV_false : signed(1 downto 0) := to_signed(0, 2);

    constant C_MAX_SHIFT : integer := 5;

    constant XLEN : integer := 32;

    constant C_DATA_WIDTH     : integer := XLEN;
    constant C_MEM_ADDR_WIDTH : integer := XLEN;
    constant C_REG_ADDR_WIDTH : integer := 5;
    constant C_OPCODE_WIDTH   : integer := 7;
    constant C_FUNCT_3_WIDTH  : integer := 3;
    constant C_FUNCT_7_WIDTH  : integer := 7;

    constant C_RS1_ADDR_LOW : integer := 15;
    constant C_RS2_ADDR_LOW : integer := 20;
    constant C_RD_ADDR_LOW  : integer := 7;
    constant C_FUNCT_3_LOW  : integer := 12;
    constant C_FUNCT_7_LOW  : integer := 25;

    constant C_BIT_SIZE  : integer := 1;
    constant C_BYTE_SIZE : integer := 8;
    constant C_HALF_SIZE : integer := 16;
    constant C_WORD_SIZE : integer := XLEN;

    constant C_EXCEPTION_VECTOR_WIDTH         : integer := 4;
    -- memory-address-misaligned
    constant C_EXCEPTION_MEM_ADDR_MISALIGNED  : integer := 0;
    -- instruction-address-misaligned
    constant C_EXCEPTION_INST_ADDR_MISALIGNED : integer := 1;
    -- illegal-instruction
    constant C_EXCEPTION_ILLEGAL_INST         : integer := 2;
    constant C_EXCEPTION_ECALL_BREAK          : integer := 3;

    constant JKRiscV_exception_hendler : std_logic_vector(C_DATA_WIDTH - 1 downto 0) := x"00000F00";

    type t_CPU_STATE is (FETCH, DECODE, EXECUTE, MEMORY, WRITEBACK, IDLE, HALT, EXCEPTION, START, RESETING);

    type t_ENCODING is (R_TYPE, I_TYPE, S_TYPE, B_TYPE, U_TYPE, J_TYPE, ERROR);
    --type t_INSTRUCTION is (LUI, AUIPC, JAL, JALR, BEQ, BNE, BLT, BGE, BLTU, BGEU, LB, LH, LW, LBU, LHU, SB, SH, SW, ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI, ADDR, SUBR, SLLR, SLTR, SLTRU, XORR, SRLR, SRAR, ORR, ANDR, FENCE, ECALL, EBREAK);

    type t_OPCODE is (LUI_INST, AUIPC_INST, JAL_INST, JALR_INST, FENCE_INST, ECALL_BREAK_INST, BRANCH, LOAD, STORE, IMMEDIATE, REGISTR, ERROR);
    type t_OPCODE_memory is array (natural range <>) of std_logic_vector(C_OPCODE_WIDTH - 1 downto 0);
    constant t_OPCODE_values : t_OPCODE_memory(0 to 11) := (
        "0110111", "0010111", "1101111", "1100111", "0001111",
        "1110011", "1100011", "0000011", "0100011", "0010011", "0110011",
        "0000000"                       -- ERROR
    );

    type t_FUNCT_3_ALU is (ARIT_O, SLT_O, SLTU_O, XOR_O, OR_O, AND_O, SLL_O, SR_O, ERR_O);
    type t_FUNCT_3_ALU_memory is array (natural range <>) of std_logic_vector(C_FUNCT_3_WIDTH - 1 downto 0);
    constant t_FUNCT_3_ALU_values : t_FUNCT_3_ALU_memory(0 to 8) := (
        "000", "010", "011", "100", "110", "111", "001", "101",
        "000"                           -- ERROR
    );

    type t_FUNCT_3_MEMORY is (BYTE_O, HALF_O, WORD_O, UBYTE_O, UHALF_O, ERR_O);
    type t_FUNCT_3_BRANCH is (BEQ_O, BNE_O, BLT_O, BGE_O, BLTU_O, BGEU_O, ERR_O);
    --type t_FUNCT_3_BRANCH is (BEQ, BNE, BLT, BGE, BLTU, BGEU, ERROR);

    type t_ALUFUNC is (ADD_F, SUB_F, SLL_F, SLT_F, SLTU_F, XOR_F, SRL_F, SRA_F, OR_F, AND_F, ERR_F);

    type t_REGISTR_NAME is (ZERO, RA, SP, GP, TP, T0, T1, T2, S0, S1, A0, A1, A2, A3, A4, A5, A6, A7, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, T3, T4, T5, T6, ERR_R);
    function to_registr_name(input : std_logic_vector(C_REG_ADDR_WIDTH-1 downto 0)) return t_REGISTR_NAME;
    function registr_name_to_std_logic_vector(input : t_REGISTR_NAME) return std_logic_vector;

    function opcode_to_std_logic_vector(input : t_OPCODE) return std_logic_vector;
    function funct_3_ALU_to_std_logic_vector(input : t_FUNCT_3_ALU) return std_logic_vector;
    function funct_3_memory_to_std_logic_vector(input : t_FUNCT_3_MEMORY) return std_logic_vector;
    function funct_3_branch_to_std_logic_vector(input : t_FUNCT_3_BRANCH) return std_logic_vector;

    function to_encoding(input : std_logic_vector(C_OPCODE_WIDTH-1 downto 0)) return t_ENCODING;
    function to_opcode(input : std_logic_vector(C_OPCODE_WIDTH-1 downto 0)) return t_OPCODE;
    function to_funct_3_ALU(input : std_logic_vector(C_FUNCT_3_WIDTH -1 downto 0)) return t_FUNCT_3_ALU;
    function to_funct_3_memory(input : std_logic_vector(C_FUNCT_3_WIDTH -1 downto 0)) return t_FUNCT_3_MEMORY;
    function to_funct_3_branch(input : std_logic_vector(C_FUNCT_3_WIDTH -1 downto 0)) return t_FUNCT_3_BRANCH;

    function codes_to_instruction(
        opcode         : t_OPCODE;
        funct_3_ALU    : t_FUNCT_3_ALU;
        funct_3_memory : t_FUNCT_3_MEMORY;
        funct_3_branch : t_FUNCT_3_BRANCH;
        funct_7        : std_logic_vector(C_FUNCT_7_WIDTH -1 downto 0);
        rs1            : integer;
        rs2            : integer;
        rd             : integer;
        imm            : std_logic_vector(C_DATA_WIDTH-1 downto 0)
    ) return std_logic_vector;

    function data_from_memory_formater(
        funct_3_memory : t_FUNCT_3_MEMORY;
        dout_shifted   : std_logic_vector(C_DATA_WIDTH - 1 downto 0)
    ) return std_logic_vector;

    function unaligned_address_check(
        opcode         : t_OPCODE;
        byte_addr      : std_logic_vector(1 downto 0);
        funct_3_memory : t_FUNCT_3_MEMORY
    ) return std_logic;

    function mem_wren_control(
        opcode         : t_OPCODE;
        funct_3_memory : t_FUNCT_3_MEMORY;
        byte_addr      : std_logic_vector(1 downto 0)
    ) return std_logic_vector;

    function ALU_control(
        opcode         : t_OPCODE;
        funct_3_ALU    : t_FUNCT_3_ALU;
        funct_3_branch : t_FUNCT_3_BRANCH;
        funct_7        : std_logic_vector(C_FUNCT_7_WIDTH - 1 downto 0)
    ) return t_ALUFUNC;

    function branch_control(
        opcode         : t_OPCODE;
        funct_3_branch : t_FUNCT_3_BRANCH;
        ALU_result     : std_logic_vector(C_DATA_WIDTH - 1 downto 0)
    ) return std_logic;

    function register_control(opcode : t_OPCODE) return std_logic;
    function RAM_control(opcode : t_OPCODE) return std_logic;

    function ALU_solve(funct : t_ALUFUNC; x, y : std_logic_vector) return std_logic_vector;

    function to_string(bits : std_logic_vector) return string;

end package JKRiscV_types;

package body JKRiscV_types is

    function to_string(bits : std_logic_vector) return string is
        variable string_vector : string(bits'length - 1 downto 0) := (others => NUL);
    begin
        for i in bits'range loop
            string_vector(i) := std_logic'image(bits((i)))(2);
        end loop;
        return string_vector;
    end function;

    function to_encoding(input : std_logic_vector(C_OPCODE_WIDTH-1 downto 0)) return t_ENCODING is
        variable encoding : t_ENCODING;
    begin
        case input is
            when "0000011" | "0010011" | "1100111" => encoding := I_TYPE;
            when "0110111" | "0010111"             => encoding := U_TYPE;
            when "1101111"                         => encoding := J_TYPE;
            when "0100011"                         => encoding := S_TYPE;
            when "1100011"                         => encoding := B_TYPE;
            when "0110011"                         => encoding := R_TYPE;
            when others                            => encoding := ERROR;
        end case;
        return encoding;
    end function to_encoding;

    function codes_to_instruction(
        opcode         : t_OPCODE;
        funct_3_ALU    : t_FUNCT_3_ALU;
        funct_3_memory : t_FUNCT_3_MEMORY;
        funct_3_branch : t_FUNCT_3_BRANCH;
        funct_7        : std_logic_vector(C_FUNCT_7_WIDTH -1 downto 0);
        rs1            : integer;
        rs2            : integer;
        rd             : integer;
        imm            : std_logic_vector(C_DATA_WIDTH-1 downto 0)
    ) return std_logic_vector is
        variable instruction  : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
        variable opcode_bits  : std_logic_vector(C_OPCODE_WIDTH - 1 downto 0);
        variable rs1_bits     : std_logic_vector(C_REG_ADDR_WIDTH - 1 downto 0);
        variable rs2_bits     : std_logic_vector(C_REG_ADDR_WIDTH - 1 downto 0);
        variable rd_bits      : std_logic_vector(C_REG_ADDR_WIDTH - 1 downto 0);
        variable funct_3_bits : std_logic_vector(C_FUNCT_3_WIDTH - 1 downto 0);
        variable encoding     : t_ENCODING;
    begin
        opcode_bits := opcode_to_std_logic_vector(opcode);
        encoding    := to_encoding(opcode_bits);
        rs1_bits    := std_logic_vector(to_unsigned(rs1, C_REG_ADDR_WIDTH));
        rs2_bits    := std_logic_vector(to_unsigned(rs2, C_REG_ADDR_WIDTH));
        rd_bits     := std_logic_vector(to_unsigned(rd, C_REG_ADDR_WIDTH));
        case encoding is
            when I_TYPE =>
                case opcode is
                    when LOAD =>
                        funct_3_bits := funct_3_memory_to_std_logic_vector(funct_3_memory);
                    when IMMEDIATE =>
                        funct_3_bits := funct_3_ALU_to_std_logic_vector(funct_3_ALU);
                    when ECALL_BREAK_INST =>
                        funct_3_bits := (others => '0');
                    when others =>
                        funct_3_bits := (others => '0');
                end case;
                -- TODO case for SLL and SRL
                instruction := imm(11 downto 0) & rs1_bits & funct_3_bits & rd_bits & opcode_bits;
            when U_TYPE =>
                instruction := imm(31 downto 12) & rd_bits & opcode_bits;
            when J_TYPE =>
                instruction := imm(20) & imm(10 downto 1) & imm(11) & imm(19 downto 12) & rd_bits & opcode_bits;
            when S_TYPE =>
                instruction := imm(11 downto 5) & rs2_bits & rs1_bits & funct_3_memory_to_std_logic_vector(funct_3_memory) & imm(4 downto 0) & opcode_bits;
            when B_TYPE =>
                instruction := imm(12) & imm(10 downto 5) & rs2_bits & rs1_bits & funct_3_branch_to_std_logic_vector(funct_3_branch) & imm(4 downto 1) & imm(11) & opcode_bits;
            when R_TYPE =>
                instruction := funct_7 & rs2_bits & rs1_bits & funct_3_ALU_to_std_logic_vector(funct_3_ALU) & rd_bits & opcode_bits;
            when others =>
                instruction := (others => '0');
        end case;
        return instruction;
    end function;

    function opcode_to_std_logic_vector(input : t_OPCODE) return std_logic_vector is
        variable opcode : std_logic_vector(C_OPCODE_WIDTH - 1 downto 0);
    begin
        opcode := t_OPCODE_values(t_OPCODE'POS(input));
        return opcode;
    end function opcode_to_std_logic_vector;

    function to_opcode(input : std_logic_vector(C_OPCODE_WIDTH-1 downto 0)) return t_OPCODE is
        variable opcode : t_OPCODE;
    begin
        case input is
            when "0110111" => opcode := LUI_INST;
            when "0010111" => opcode := AUIPC_INST;
            when "1101111" => opcode := JAL_INST;
            when "1100111" => opcode := JALR_INST;
            when "0001111" => opcode := FENCE_INST;
            when "1110011" => opcode := ECALL_BREAK_INST;
            when "1100011" => opcode := BRANCH;
            when "0000011" => opcode := LOAD;
            when "0100011" => opcode := STORE;
            when "0010011" => opcode := IMMEDIATE;
            when "0110011" => opcode := REGISTR;
            when others    => opcode := ERROR;
        end case;
        return opcode;
    end function to_opcode;

    function funct_3_ALU_to_std_logic_vector(input : t_FUNCT_3_ALU) return std_logic_vector is
        variable funct : std_logic_vector(C_FUNCT_3_WIDTH - 1 downto 0);
    begin
        case input is
            when ARIT_O => funct := "000";
            when SLT_O  => funct := "010";
            when SLTU_O => funct := "011";
            when XOR_O  => funct := "100";
            when OR_O   => funct := "110";
            when AND_O  => funct := "111";
            when SLL_O  => funct := "001";
            when SR_O   => funct := "101";
            when others => funct := "000";
        end case;
        return funct;
    end function funct_3_ALU_to_std_logic_vector;

    function funct_3_memory_to_std_logic_vector(input : t_FUNCT_3_MEMORY) return std_logic_vector is
        variable funct : std_logic_vector(C_FUNCT_3_WIDTH - 1 downto 0);
    begin
        case input is
            when BYTE_O  => funct := "000";
            when HALF_O  => funct := "001";
            when WORD_O  => funct := "010";
            when UBYTE_O => funct := "100";
            when UHALF_O => funct := "101";
            when others  => funct := "000";
        end case;
        return funct;
    end function funct_3_memory_to_std_logic_vector;

    function funct_3_branch_to_std_logic_vector(input : t_FUNCT_3_BRANCH) return std_logic_vector is
        variable funct : std_logic_vector(C_FUNCT_3_WIDTH - 1 downto 0);
    begin
        case input is
            when BEQ_O  => funct := "000";
            when BNE_O  => funct := "001";
            when BLT_O  => funct := "100";
            when BGE_O  => funct := "101";
            when BLTU_O => funct := "110";
            when BGEU_O => funct := "111";
            when others => funct := "000";
        end case;
        return funct;
    end function funct_3_branch_to_std_logic_vector;

    function to_funct_3_ALU(input : std_logic_vector(C_FUNCT_3_WIDTH -1 downto 0)) return t_FUNCT_3_ALU is
        variable funct : t_FUNCT_3_ALU;
    begin
        case input is
            when "000"  => funct := ARIT_O;
            when "010"  => funct := SLT_O;
            when "011"  => funct := SLTU_O;
            when "100"  => funct := XOR_O;
            when "110"  => funct := OR_O;
            when "111"  => funct := AND_O;
            when "001"  => funct := SLL_O;
            when "101"  => funct := SR_O;
            when others => funct := ERR_O;
        end case;
        return funct;
    end function to_funct_3_ALU;

    function to_funct_3_memory(input : std_logic_vector(C_FUNCT_3_WIDTH -1 downto 0)) return t_FUNCT_3_MEMORY is
        variable funct : t_FUNCT_3_MEMORY;
    begin
        case input is
            when "000"  => funct := BYTE_O;
            when "001"  => funct := HALF_O;
            when "010"  => funct := WORD_O;
            when "100"  => funct := UBYTE_O;
            when "101"  => funct := UHALF_O;
            when others => funct := ERR_O;
        end case;
        return funct;
    end function to_funct_3_memory;

    function to_funct_3_branch(input : std_logic_vector(C_FUNCT_3_WIDTH -1 downto 0)) return t_FUNCT_3_BRANCH is
        variable funct : t_FUNCT_3_BRANCH;
    begin
        case input is
            when "000"  => funct := BEQ_O;
            when "001"  => funct := BNE_O;
            when "100"  => funct := BLT_O;
            when "101"  => funct := BGE_O;
            when "110"  => funct := BLTU_O;
            when "111"  => funct := BGEU_O;
            when others => funct := ERR_O;
        end case;
        return funct;
    end function to_funct_3_branch;

    --    function to_funct_7 (input : std_logic_vector(7 -1 downto 0)) return t_FUNCT_7 is
    --        variable funct : t_FUNCT_7;
    --    begin
    --        funct := t_FUNCT_7'VAL(TO_INTEGER(unsigned(input)));
    --        return funct;
    --    end function to_funct_7;

    function data_from_memory_formater(
        funct_3_memory : t_FUNCT_3_MEMORY;
        dout_shifted   : std_logic_vector(C_DATA_WIDTH - 1 downto 0)
    ) return std_logic_vector is
        variable byte     : std_logic_vector(C_BYTE_SIZE - 1 downto 0);
        variable half     : std_logic_vector(C_HALF_SIZE - 1 downto 0);
        variable data_out : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
    begin
        case funct_3_memory is
            when BYTE_O =>
                byte     := dout_shifted(C_BYTE_SIZE - 1 downto 0);
                data_out := std_logic_vector(RESIZE(signed(byte), data_out'length));
            when UBYTE_O =>
                byte     := dout_shifted(C_BYTE_SIZE - 1 downto 0);
                --data_out <= (others => '0', Byte);
                data_out := std_logic_vector(RESIZE(unsigned(byte), data_out'length));
            when HALF_O =>
                half     := dout_shifted(C_HALF_SIZE - 1 downto 0);
                data_out := std_logic_vector(RESIZE(signed(half), data_out'length));
            when UHALF_O =>
                half     := dout_shifted(C_HALF_SIZE - 1 downto 0);
                --data_out <= (others => '0', half);
                data_out := std_logic_vector(RESIZE(unsigned(half), data_out'length));
            when WORD_O =>
                data_out := dout_shifted;
            when others => data_out := (others => '0');
        end case;
        return data_out;
    end data_from_memory_formater;

    function mem_wren_control(
        opcode         : t_OPCODE;
        funct_3_memory : t_FUNCT_3_MEMORY;
        byte_addr      : std_logic_vector(1 downto 0)
    ) return std_logic_vector is
        variable wren : std_logic_vector(C_DATA_WIDTH / C_BYTE_SIZE - 1 downto 0);
    begin
        case opcode is
            when LOAD =>
                wren := (others => '0');
            when STORE =>
                case funct_3_memory is
                    when BYTE_O =>
                        wren := std_logic_vector(shift_left(unsigned'("0001"), to_integer(unsigned(byte_addr))));
                    when HALF_O =>
                        wren := std_logic_vector(shift_left(unsigned'("0011"), to_integer(unsigned(byte_addr))));
                    when WORD_O =>
                        wren := "1111";
                    when others =>
                        wren := (others => '0');
                end case;
            when OTHERS =>
                wren := (others => '0');
        end case;
        return wren;
    end mem_wren_control;

    function unaligned_address_check(
        opcode         : t_OPCODE;
        byte_addr      : std_logic_vector(1 downto 0);
        funct_3_memory : t_FUNCT_3_MEMORY
    ) return std_logic is
        variable unaligned_addr : std_logic;
    begin
        if opcode = LOAD or opcode = STORE then
            case funct_3_memory is
                when BYTE_O | UBYTE_O =>
                    unaligned_addr := '0';
                when HALF_O | UHALF_O =>
                    if unsigned(byte_addr(1 downto 0)) > 2 then
                        unaligned_addr := '1';
                    else
                        unaligned_addr := '0';
                    end if;
                when WORD_O =>
                    if unsigned(byte_addr(1 downto 0)) > 0 then
                        unaligned_addr := '1';
                    else
                        unaligned_addr := '0';
                    end if;
                when others =>
                    unaligned_addr := '1';
            end case;
        else
            unaligned_addr := '0';
        end if;
        return unaligned_addr;
    end function unaligned_address_check;

    function register_control(opcode : t_OPCODE) return std_logic is
        variable reg_write : std_logic;
    begin
        case opcode is
            -- PC
            when AUIPC_INST | JALR_INST =>
                reg_write := '1';
            -- hot fix
            when JAL_INST =>
                reg_write := '0';
            -- LOAD/STORE
            when LOAD | LUI_INST =>
                reg_write := '1';
            when STORE =>
                reg_write := '0';
            when FENCE_INST =>
                reg_write := '0';
            when OTHERS =>
                reg_write := '1';
        end case;
        return reg_write;
    end function register_control;

    function RAM_control(opcode : t_OPCODE) return std_logic is
        variable RAM_ce : std_logic;
    begin
        case opcode is
            when LOAD | STORE =>
                RAM_ce := '1';
            when OTHERS =>
                RAM_ce := '0';
        end case;
        return RAM_ce;
    end function RAM_control;

    function branch_control(
        opcode         : t_OPCODE;
        funct_3_branch : t_FUNCT_3_BRANCH;
        ALU_result     : std_logic_vector(C_DATA_WIDTH - 1 downto 0)
    ) return std_logic is
        variable going_to_branch : std_logic;
        constant zero            : std_logic_vector(C_DATA_WIDTH - 1 downto 0) := (others => '0');
        --constant zero     : std_logic_vector(C_DATA_WIDTH - 1 downto 0) := std_logic_vector(resize(JKRiscV_false, C_DATA_WIDTH));
        constant true_32b        : std_logic_vector(C_DATA_WIDTH - 1 downto 0) := std_logic_vector(resize(JKRiscV_true, C_DATA_WIDTH));
    begin
        going_to_branch := '0';
        if opcode = BRANCH then
            case funct_3_branch is
                when BEQ_O =>
                    if ALU_result = zero then
                        going_to_branch := '1';
                    end if;
                when BNE_O =>
                    if ALU_result /= zero then
                        going_to_branch := '1';
                    end if;
                when BLT_O =>
                    if ALU_result = true_32b then
                        going_to_branch := '1';
                    end if;
                when BGE_O =>
                    if ALU_result /= true_32b then
                        going_to_branch := '1';
                    end if;
                when BLTU_O =>
                    if ALU_result = true_32b then
                        going_to_branch := '1';
                    end if;
                when BGEU_O =>
                    if ALU_result /= true_32b then
                        going_to_branch := '1';
                    end if;
                when others =>
                    going_to_branch := '0';
            end case;
        end if;
        return going_to_branch;
    end branch_control;

    function ALU_control(
        opcode         : t_OPCODE;
        funct_3_ALU    : t_FUNCT_3_ALU;
        funct_3_branch : t_FUNCT_3_BRANCH;
        funct_7        : std_logic_vector(C_FUNCT_7_WIDTH - 1 downto 0)
    ) return t_ALUFUNC is
        variable alufunc : t_ALUFUNC;
    begin
        case opcode is
            when FENCE_INST =>
                --alufunc := NOP_F;
                alufunc := ADD_F;

            when AUIPC_INST | JALR_INST =>
                alufunc := ADD_F;

            when LOAD | STORE =>
                alufunc := ADD_F;

            when BRANCH =>
                case funct_3_branch is
                    when BEQ_O =>
                        alufunc := SUB_F;
                    when BNE_O =>
                        alufunc := SUB_F;
                    when BLT_O =>
                        alufunc := SLT_F;
                    when BGE_O =>
                        alufunc := SLT_F;
                    when BLTU_O =>
                        alufunc := SLTU_F;
                    when BGEU_O =>
                        alufunc := SLTU_F;
                    when others => null;
                end case;

            when IMMEDIATE =>
                case funct_3_ALU is
                    when ARIT_O =>
                        alufunc := ADD_F;
                    when SLT_O =>
                        alufunc := SLT_F;
                    when SLTU_O =>
                        alufunc := SLTU_F;
                    when XOR_O =>
                        alufunc := XOR_F;
                    when OR_O =>
                        alufunc := OR_F;
                    when AND_O =>
                        alufunc := AND_F;
                    when SLL_O =>
                        alufunc := SLL_F;
                    when SR_O =>
                        case funct_7 is
                            when "0000000" =>
                                alufunc := SRL_F;
                            when "0100000" =>
                                alufunc := SRA_F;
                            when others => null;
                        end case;
                    when others => null;
                end case;

            when REGISTR =>
                case funct_3_ALU is
                    when ARIT_O =>
                        case funct_7 is
                            when "0000000" =>
                                alufunc := ADD_F;
                            when "0100000" =>
                                alufunc := SUB_F;
                            when others => null;
                        end case;
                    when SLT_O =>
                        alufunc := SLT_F;
                    when SLTU_O =>
                        alufunc := SLTU_F;
                    when XOR_O =>
                        alufunc := XOR_F;
                    when OR_O =>
                        alufunc := OR_F;
                    when AND_O =>
                        alufunc := AND_F;
                    when SLL_O =>
                        alufunc := SLL_F;
                    when SR_O =>
                        case funct_7 is
                            when "0000000" =>
                                alufunc := SRL_F;
                            when "0100000" =>
                                alufunc := SRA_F;
                            when others => null;
                        end case;

                    when others => null;
                end case;

            when others => null;
        end case;
        return alufunc;
    end function ALU_control;

    -- TODO: use in final design!
    function register_source(
        opcode      : t_OPCODE;
        ALU_result  : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
        data_to_cpu : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
        imm         : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
        PC_plus_4   : std_logic_vector(C_DATA_WIDTH - 1 downto 0)
    ) return std_logic_vector is
        variable wrdata : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
    begin
        case opcode is
            when LUI_INST =>
                wrdata := imm;
            when JAL_INST | JALR_INST =>
                wrdata := PC_plus_4;
            when LOAD =>
                wrdata := data_to_cpu;
            when STORE =>
                wrdata := (others => '0');
            when others =>
                wrdata := ALU_result;
        end case;
        return wrdata;
    end register_source;

    function ALU_data1_source(
        opcode   : t_OPCODE;
        imm      : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
        PC       : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
        rs1_data : std_logic_vector(C_DATA_WIDTH - 1 downto 0)
    ) return std_logic_vector is
        variable data1 : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
    begin
        case opcode is
            when BRANCH =>
                data1 := rs1_data;
            when AUIPC_INST =>
                data1 := PC;
            when others =>
                data1 := rs1_data;
        end case;
        return data1;
    end function ALU_data1_source;

    function ALU_data2_source(
        opcode   : t_OPCODE;
        imm      : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
        rs2_data : std_logic_vector(C_DATA_WIDTH - 1 downto 0)
    ) return std_logic_vector is
        variable data2 : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
    begin
        case opcode is
            when BRANCH =>
                data2 := rs2_data;
            when AUIPC_INST | JALR_INST =>
                data2 := imm;
            when LOAD | STORE =>
                data2 := imm;
            when IMMEDIATE =>
                data2 := imm;
            when others =>
                data2 := rs2_data;
        end case;
        return data2;
    end function ALU_data2_source;

    function ALU_solve(funct : t_ALUFUNC; x, y : std_logic_vector) return std_logic_vector is
        variable result_signed          : signed(C_DATA_WIDTH - 1 downto 0) := (others => '0');
        variable y_signed, x_signed     : signed(C_DATA_WIDTH - 1 downto 0);
        variable y_unsigned, x_unsigned : unsigned(C_DATA_WIDTH - 1 downto 0);
    begin
        y_signed   := signed(y);
        x_signed   := signed(x);
        y_unsigned := unsigned(y);
        x_unsigned := unsigned(x);

        case funct is
            when ADD_F =>
                -- addition 
                result_signed := resize(x_signed + y_signed, result_signed'length);

            when SUB_F =>
                -- subtraction 
                result_signed := resize(x_signed - y_signed, result_signed'length);

            when SLT_F =>
                -- set on less than
                if x_signed < y_signed then
                    result_signed := resize(JKRiscV_true, result_signed'length);
                else
                    result_signed := resize(JKRiscV_false, result_signed'length);
                end if;

            when SLTU_F =>
                -- set on less than
                if unsigned(x) < unsigned(y) then
                    result_signed := resize(JKRiscV_true, result_signed'length);
                else
                    result_signed := resize(JKRiscV_false, result_signed'length);
                end if;

            when XOR_F =>
                -- bitwise XOR
                result_signed := x_signed xor y_signed;

            when OR_F =>
                -- bitwise OR 
                result_signed := x_signed or y_signed;

            when AND_F =>
                -- bitwise AND 
                result_signed := x_signed and y_signed;

            when SLL_F =>
                -- shift left logical
                result_signed := shift_left(x_signed, to_integer(resize(y_unsigned, C_MAX_SHIFT)));

            when SRL_F =>
                -- shift right logical 
                result_signed := signed(shift_right(x_unsigned, to_integer(y_unsigned)));

            when SRA_F =>
                -- shift right arithmetical
                result_signed := shift_right(x_signed, to_integer(resize(y_unsigned, C_MAX_SHIFT)));

            when others =>
                result_signed := (others => '0');
        end case;

        return std_logic_vector(result_signed);
    end function ALU_solve;

    --TODO: test this function
    function to_registr_name(input : std_logic_vector(C_REG_ADDR_WIDTH-1 downto 0)) return t_REGISTR_NAME is
        variable registr : t_REGISTR_NAME;
    begin
        case input is
            when "00000" => registr := ZERO;
            when "00001" => registr := RA;
            when "00010" => registr := SP;
            when "00011" => registr := GP;
            when "00100" => registr := TP;
            when "00101" => registr := T0;
            when "00110" => registr := T1;
            when "00111" => registr := T2;
            when "01000" => registr := S0;
            when "01001" => registr := S1;
            when "01010" => registr := A0;
            when "01011" => registr := A1;
            when "01100" => registr := A2;
            when "01101" => registr := A3;
            when "01110" => registr := A4;
            when "01111" => registr := A5;
            when "10000" => registr := A6;
            when "10001" => registr := A7;
            when "10010" => registr := S2;
            when "10011" => registr := S3;
            when "10100" => registr := S4;
            when "10101" => registr := S5;
            when "10110" => registr := S6;
            when "10111" => registr := S7;
            when "11000" => registr := S8;
            when "11001" => registr := S9;
            when "11010" => registr := S10;
            when "11011" => registr := S11;
            when "11100" => registr := T3;
            when "11101" => registr := T4;
            when "11110" => registr := T5;
            when "11111" => registr := T6;
            when others => registr := ERR_R;
        end case;
        return registr;
    end function to_registr_name;

    --TODO: test this function
    function registr_name_to_std_logic_vector(input : t_REGISTR_NAME) return std_logic_vector is
        variable registr : std_logic_vector(C_REG_ADDR_WIDTH-1 downto 0);
    begin
        case input is
            when ZERO => registr := "00000";
            when RA   => registr := "00001";
            when SP   => registr := "00010";
            when GP   => registr := "00011";
            when TP   => registr := "00100";
            when T0   => registr := "00101";
            when T1   => registr := "00110";
            when T2   => registr := "00111";
            when S0   => registr := "01000";
            when S1   => registr := "01001";
            when A0   => registr := "01010";
            when A1   => registr := "01011";
            when A2   => registr := "01100";
            when A3   => registr := "01101";
            when A4   => registr := "01110";
            when A5   => registr := "01111";
            when A6   => registr := "10000";
            when A7   => registr := "10001";
            when S2   => registr := "10010";
            when S3   => registr := "10011";
            when S4   => registr := "10100";
            when S5   => registr := "10101";
            when S6   => registr := "10110";
            when S7   => registr := "10111";
            when S8   => registr := "11000";
            when S9   => registr := "11001";
            when S10  => registr := "11010";
            when S11  => registr := "11011";
            when T3   => registr := "11100";
            when T4   => registr := "11101";
            when T5   => registr := "11110";
            when T6   => registr := "11111";
            when ERR_R => registr := (others => 'X');
        end case;
        return registr;
    end function registr_name_to_std_logic_vector;

end package body JKRiscV_types;
