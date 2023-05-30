library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.JKRiscV_types.all;

library unisim;
use unisim.vcomponents.all;

entity RISCV_wrapper is
    generic(
        -- Parameters of Axi Slave Bus Interface S00_AXI
        C_S00_AXI_DATA_WIDTH : integer := 32;
        C_S00_AXI_ADDR_WIDTH : integer := 17;
        C_LED_WIDTH          : integer := 8;
        C_SWITCH_WIDTH       : integer := 8;
        C_GPIO_WIDTH         : integer := 8;
        C_NUM_REGS           : integer := 8;
        C_RAM_DELAY          : integer := 2
    );
    port(
        LEDS_IO_T          : out std_logic_vector(C_LED_WIDTH - 1 downto 0);
        LEDS_IO_O          : out std_logic_vector(C_LED_WIDTH - 1 downto 0);
        LEDS_IO_I          : in  std_logic_vector(C_LED_WIDTH - 1 downto 0);
        SWITCH_IO_T        : out std_logic_vector(C_SWITCH_WIDTH - 1 downto 0);
        SWITCH_IO_O        : out std_logic_vector(C_SWITCH_WIDTH - 1 downto 0);
        SWITCH_IO_I        : in  std_logic_vector(C_SWITCH_WIDTH - 1 downto 0);
        GPIO_IO_T          : out std_logic_vector(C_GPIO_WIDTH - 1 downto 0);
        GPIO_IO_O          : out std_logic_vector(C_GPIO_WIDTH - 1 downto 0);
        GPIO_IO_I          : in  std_logic_vector(C_GPIO_WIDTH - 1 downto 0);
        -- Ports of Axi Slave Bus Interface S00_AXI
        s00_axi_aclk    : in  std_logic;
        s00_axi_aresetn : in  std_logic;
        s00_axi_awaddr  : in  std_logic_vector(C_S00_AXI_ADDR_WIDTH - 1 downto 0);
        s00_axi_awprot  : in  std_logic_vector(2 downto 0);
        s00_axi_awvalid : in  std_logic;
        s00_axi_awready : out std_logic;
        s00_axi_wdata   : in  std_logic_vector(C_S00_AXI_DATA_WIDTH - 1 downto 0);
        s00_axi_wstrb   : in  std_logic_vector((C_S00_AXI_DATA_WIDTH / 8) - 1 downto 0);
        s00_axi_wvalid  : in  std_logic;
        s00_axi_wready  : out std_logic;
        s00_axi_bresp   : out std_logic_vector(1 downto 0);
        s00_axi_bvalid  : out std_logic;
        s00_axi_bready  : in  std_logic;
        s00_axi_araddr  : in  std_logic_vector(C_S00_AXI_ADDR_WIDTH - 1 downto 0);
        s00_axi_arprot  : in  std_logic_vector(2 downto 0);
        s00_axi_arvalid : in  std_logic;
        s00_axi_arready : out std_logic;
        s00_axi_rdata   : out std_logic_vector(C_S00_AXI_DATA_WIDTH - 1 downto 0);
        s00_axi_rresp   : out std_logic_vector(1 downto 0);
        s00_axi_rvalid  : out std_logic;
        s00_axi_rready  : in  std_logic
    );
end entity;

architecture RTL of RISCV_wrapper is

    constant C_REG_BYTES  : integer := C_S00_AXI_DATA_WIDTH / 8;
    constant C_BYTES_ADDR : integer := integer(log2(real(C_REG_BYTES)));
    constant C_REGS_ADDR  : integer := integer(log2(real(C_NUM_REGS * C_REG_BYTES)));
    type regfile_t is array (0 to C_NUM_REGS - 1) of std_logic_vector(C_S00_AXI_DATA_WIDTH - 1 downto 0);
    signal regfile        : regfile_t;

    type regnames_t is (
        REG_CONTROL, REG_STATUS, REG_CLOCK_CONTROL
        -- TODO : add register names
    );

    constant BIT_REG_CONTROL_RESET          : integer := 0;
    constant BIT_REG_CONTROL_COMPUTER_RESET : integer := 1;

    constant BIT_REG_CLOCK_CONTROL_CE    : integer := 0;
    constant BIT_REG_CLOCK_CONTROL_PULSE : integer := 1;

    function rn2i(name : regnames_t)
    return integer is
    begin
        return regnames_t'pos(name);
    end function rn2i;

    signal bvalid : std_logic;
    signal rvalid : std_logic;
    signal reset  : std_logic;

    signal ram_rvalid_dly : std_logic_vector(C_RAM_DELAY + 2 - 1 downto 0);

    signal computer_clk           : std_logic;
    signal computer_reset         : std_logic;
    signal computer_CPU_state_out : t_CPU_STATE;
    signal computer_LEDS_T        : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
    signal computer_LEDS_O        : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
    signal computer_LEDS_I        : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
    signal computer_SWITCH_T      : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
    signal computer_SWITCH_O      : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
    signal computer_SWITCH_I      : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
    signal computer_GPIO_T        : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
    signal computer_GPIO_O        : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
    signal computer_GPIO_I        : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
    signal computer_debug_ce      : std_logic;
    signal computer_debug_enb     : STD_LOGIC;
    signal computer_debug_web     : STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal computer_debug_addrb   : STD_LOGIC_VECTOR(C_MEM_ADDR_WIDTH - 1 DOWNTO 0);
    signal computer_debug_dinb    : STD_LOGIC_VECTOR(C_DATA_WIDTH - 1 DOWNTO 0);
    signal computer_debug_doutb   : STD_LOGIC_VECTOR(C_DATA_WIDTH - 1 DOWNTO 0);

    signal mem_read_active   : std_logic;
    signal mem_write_active  : std_logic;
    signal mem_read_address  : std_logic_vector(computer_debug_addrb'range);
    signal mem_write_address : std_logic_vector(computer_debug_addrb'range);

begin

    reset <= (not s00_axi_aresetn) or regfile(rn2i(REG_CONTROL))(BIT_REG_CONTROL_RESET);

    WR_SLAVE : process(s00_axi_aclk)
        variable reg_addr : integer;
    begin
        if rising_edge(s00_axi_aclk) then
            s00_axi_bresp       <= (others => '0');
            computer_debug_web  <= (others => '0');
            computer_debug_dinb <= (others => '0');
            if reset = '1' then
                bvalid           <= '0';
                regfile          <= (others => (others => '0'));
                mem_write_active <= '0';
            else

                if regfile(rn2i(REG_CLOCK_CONTROL))(BIT_REG_CLOCK_CONTROL_PULSE) = '1' then
                    regfile(rn2i(REG_CLOCK_CONTROL))(BIT_REG_CLOCK_CONTROL_PULSE) <= '0';
                end if;

                regfile(rn2i(REG_STATUS)) <= std_logic_vector(to_unsigned(t_CPU_STATE'pos(computer_CPU_state_out), C_S00_AXI_DATA_WIDTH));

                -- mem write duration is one cycle
                mem_write_active <= '0';
                if mem_read_active = '0' then
                    if bvalid = '1' and s00_axi_bready = '1' then
                        bvalid <= '0';
                    else

                        if s00_axi_wvalid = '1' and s00_axi_awvalid = '1' then
                            bvalid <= '1';

                            if s00_axi_awaddr(s00_axi_awaddr'high) = '0' then
                                -- register memspace
                                reg_addr := to_integer(unsigned(s00_axi_awaddr(C_REGS_ADDR - 1 downto C_BYTES_ADDR)));
                                for i in s00_axi_wstrb'range loop
                                    if s00_axi_wstrb(i) = '1' then
                                        regfile(reg_addr)(8 * (i + 1) - 1 downto 8 * i) <= s00_axi_wdata(8 * (i + 1) - 1 downto 8 * i);
                                    end if;
                                end loop;
                            else
                                -- memory memspace
                                computer_debug_web  <= s00_axi_wstrb;
                                computer_debug_dinb <= s00_axi_wdata;
                                mem_write_address   <= std_logic_vector(resize(unsigned(s00_axi_awaddr(s00_axi_awaddr'high - 1 downto 0)), mem_write_address'length));
                                mem_write_active    <= '1';
                            end if;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;

    s00_axi_bvalid <= bvalid;
    WR_SLAVE_READY : process(s00_axi_aclk)
    begin
        if rising_edge(s00_axi_aclk) then
            if s00_axi_aresetn = '0' then
                s00_axi_wready  <= '0';
                s00_axi_awready <= '0';
            else
                if bvalid = '0' then
                    if s00_axi_wvalid = '1' and s00_axi_awvalid = '1' then
                        s00_axi_wready  <= '1';
                        s00_axi_awready <= '1';
                    end if;
                else
                    s00_axi_wready  <= '0';
                    s00_axi_awready <= '0';
                end if;
            end if;
        end if;
    end process;

    RD_SLAVE : process(s00_axi_aclk)
        variable reg_addr : integer;
    begin
        if rising_edge(s00_axi_aclk) then
            -- read 
            s00_axi_rresp <= (others => '0');
            if reset = '1' then
                rvalid          <= '0';
                s00_axi_rdata   <= (others => '0');
                mem_read_active <= '0';
                ram_rvalid_dly  <= (others => '0');
            else
                if mem_write_active = '0' then
                    if rvalid = '1' and s00_axi_rready = '1' then
                        rvalid          <= '0';
                        mem_read_active <= '0';
                    else
                        if s00_axi_araddr(s00_axi_araddr'high) = '0' then
                            reg_addr := to_integer(unsigned(s00_axi_araddr(C_REGS_ADDR - 1 downto C_BYTES_ADDR)));
                            if s00_axi_arvalid = '1' then
                                s00_axi_rdata <= regfile(reg_addr);
                                rvalid        <= '1';
                            end if;
                        else
                            if s00_axi_arvalid = '1' or unsigned(ram_rvalid_dly) /= 0 then
                                if unsigned(ram_rvalid_dly) = 0 then
                                    mem_read_active  <= '1';
                                    mem_read_address <= std_logic_vector(resize(unsigned(s00_axi_araddr(s00_axi_araddr'high - 1 downto 0)), mem_read_address'length));
                                    ram_rvalid_dly   <= ('1', others => '0');
                                    rvalid           <= '0';
                                else
                                    s00_axi_rdata  <= computer_debug_doutb;
                                    ram_rvalid_dly <= '0' & ram_rvalid_dly(ram_rvalid_dly'high downto 1);
                                    rvalid         <= ram_rvalid_dly(0);
                                end if;
                            end if;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;

    s00_axi_rvalid <= rvalid;

    RD_SLAVE_READY : process(s00_axi_aclk)
    begin
        if rising_edge(s00_axi_aclk) then
            if s00_axi_aresetn = '0' then
                s00_axi_arready <= '0';
            else
                if rvalid = '0' and s00_axi_arvalid = '1' then
                    s00_axi_arready <= '1';
                else
                    s00_axi_arready <= '0';
                end if;
            end if;
        end if;
    end process;

    process(s00_axi_aclk)
    begin
        if rising_edge(s00_axi_aclk) then
            computer_debug_ce <= regfile(rn2i(REG_CLOCK_CONTROL))(BIT_REG_CLOCK_CONTROL_CE) or regfile(rn2i(REG_CLOCK_CONTROL))(BIT_REG_CLOCK_CONTROL_PULSE);
            computer_reset    <= regfile(rn2i(REG_CONTROL))(BIT_REG_CONTROL_COMPUTER_RESET);
        end if;
    end process;

    computer_debug_addrb <= mem_read_address when mem_read_active = '1' else
                            mem_write_address when mem_write_active = '1' else
                            (others => '0');

    computer_inst : entity work.Computer
        port map(
            clk           => s00_axi_aclk,
            reset         => computer_reset,
            CPU_state_out => computer_CPU_state_out,
            LEDS_T        => computer_LEDS_T,
            LEDS_O        => computer_LEDS_O,
            LEDS_I        => computer_LEDS_I,
            SWITCH_T      => computer_SWITCH_T,
            SWITCH_O      => computer_SWITCH_O,
            SWITCH_I      => computer_SWITCH_I,
            GPIO_T        => computer_GPIO_T,
            GPIO_O        => computer_GPIO_O,
            GPIO_I        => computer_GPIO_I,
            debug_ce      => computer_debug_ce,
            debug_enb     => '1',
            debug_web     => computer_debug_web,
            debug_addrb   => computer_debug_addrb,
            debug_dinb    => computer_debug_dinb,
            debug_doutb   => computer_debug_doutb
        );
        
    LEDS_IO: if (LEDS_IO_I'length > 0) and (LEDS_IO_I'length <=  computer_LEDS_I'length) generate
        LEDS_IO_T <= computer_LEDS_T(LEDS_IO_T'range);
        LEDS_IO_O <= computer_LEDS_O(LEDS_IO_O'range);
        computer_LEDS_I(LEDS_IO_I'range) <= LEDS_IO_I;
    end generate;
    
    SWITCH_IO: if (SWITCH_IO_I'length > 0) and (SWITCH_IO_I'length <=  computer_SWITCH_I'length) generate
        SWITCH_IO_T <= computer_SWITCH_T(SWITCH_IO_T'range);
        SWITCH_IO_O <= computer_SWITCH_O(SWITCH_IO_O'range);
        computer_SWITCH_I(SWITCH_IO_I'range) <= SWITCH_IO_I;
    end generate;
    
    GPIO_IO: if (GPIO_IO_I'length > 0) and (GPIO_IO_I'length <=  computer_GPIO_I'length) generate
        GPIO_IO_T <= computer_GPIO_T(GPIO_IO_T'range);
        GPIO_IO_O <= computer_GPIO_O(GPIO_IO_O'range);
        computer_GPIO_I(GPIO_IO_I'range) <= GPIO_IO_I;
    end generate;

end architecture RTL;
