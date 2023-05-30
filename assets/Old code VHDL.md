```VHDL
    type t_INSTRUCTION_RECORD is record
        funct_7  : std_logic_vector(C_FUNCT_7_WIDTH -1 downto 0);
        rs2, rs1 : std_logic_vector(C_ADDR_WIDTH -1 downto 0);
        funct_3  : t_FUNCT_3;
        rd       : std_logic_vector(C_ADDR_WIDTH -1 downto 0);
        opcode   : t_OPCODE;
    end record;

    function instruction_to_std_logic_vector(instruction : t_INSTRUCTION_RECORD) return std_logic_vector is
        variable result : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
        variable opcode : std_logic_vector(C_OPCODE_WIDTH - 1 downto 0);
        variable funct_3 : std_logic_vector(C_FUNCT_3_WIDTH - 1 downto 0);
    begin
        opcode := opcode_to_std_logic_vector(instruction.opcode);
        funct_3 := funct_3_to_std_logic_vector(instruction.funct_3);
        result := instruction.funct_7 & instruction.rs2 & instruction.rs1 & funct_3 & instruction.rd & opcode;
        return result;
    end function;
```