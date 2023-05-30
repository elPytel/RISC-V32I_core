----------------------------------------------------------------------------------
-- Company: TUL
-- Engineer: Rozkovec
-- 
-- Create Date: 20.04.2023 08:49:50
-- Design Name: 
-- Module Name: tb_RISCV_wrapper - Behavioral
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
use IEEE.NUMERIC_STD.ALL;
use work.JKRiscV_types.all;

entity tb_RISCV_wrapper is
    --  Port ( );
end tb_RISCV_wrapper;

architecture Behavioral of tb_RISCV_wrapper is
    constant C_S00_AXI_DATA_WIDTH : integer := 32;
    constant C_S00_AXI_ADDR_WIDTH : integer := 17;
    constant C_NUM_REGS           : integer := 8;
    constant C_RAM_DELAY          : integer := 2;
    constant C_LED_WIDTH          : integer := 8;
    constant C_SWITCH_WIDTH       : integer := 8;
    constant C_GPIO_WIDTH         : integer := 8;

    signal LED_pins    : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
    signal SWITCH_pins : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
    signal GPIO_pins   : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
    signal clk         : std_logic := '0';
    constant CLK_P     : time      := 10 ns;
    signal rst         : std_logic := '1';

    signal s00_axi_aresetn : std_logic := '0';

    signal s00_axi_awaddr  : std_logic_vector(C_S00_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
    signal s00_axi_awprot  : std_logic_vector(2 downto 0)                        := (others => '0');
    signal s00_axi_awvalid : std_logic                                           := '0';
    signal s00_axi_awready : std_logic;

    signal s00_axi_wdata  : std_logic_vector(C_S00_AXI_DATA_WIDTH - 1 downto 0)       := (others => '0');
    signal s00_axi_wstrb  : std_logic_vector((C_S00_AXI_DATA_WIDTH / 8) - 1 downto 0) := (others => '1');
    signal s00_axi_wvalid : std_logic                                                 := '0';
    signal s00_axi_wready : std_logic;

    signal s00_axi_bresp  : std_logic_vector(1 downto 0);
    signal s00_axi_bvalid : std_logic;
    signal s00_axi_bready : std_logic := '0';

    signal s00_axi_araddr  : std_logic_vector(C_S00_AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
    signal s00_axi_arprot  : std_logic_vector(2 downto 0)                        := (others => '0');
    signal s00_axi_arvalid : std_logic                                           := '0';
    signal s00_axi_arready : std_logic;

    signal s00_axi_rdata  : std_logic_vector(C_S00_AXI_DATA_WIDTH - 1 downto 0);
    signal s00_axi_rresp  : std_logic_vector(1 downto 0);
    signal s00_axi_rvalid : std_logic;
    signal s00_axi_rready : std_logic := '0';

    signal axi_master_run       : std_logic;
    signal axi_master_addr      : std_logic_vector(C_S00_AXI_ADDR_WIDTH - 1 downto 0);
    signal axi_master_rd_not_wr : std_logic;
    signal axi_master_rd_data   : std_logic_vector(C_S00_AXI_DATA_WIDTH - 1 downto 0);
    signal axi_master_wr_data   : std_logic_vector(C_S00_AXI_DATA_WIDTH - 1 downto 0);
    signal axi_master_done      : std_logic;

    procedure axi_master_write(addr           : integer;
                               data           : integer;
                               signal am_run  : out std_logic;
                               signal am_rd   : out std_logic;
                               signal am_data : out std_logic_vector(C_S00_AXI_DATA_WIDTH - 1 downto 0);
                               signal am_addr : out std_logic_vector(C_S00_AXI_ADDR_WIDTH - 1 downto 0);
                               signal am_done : in std_logic
                              ) is
    begin
        am_run  <= '1';
        am_rd   <= '0';
        am_addr <= std_logic_vector(to_unsigned(addr, am_addr'length));
        am_data <= std_logic_vector(to_unsigned(data, axi_master_wr_data'length));
        wait until am_done = '1';
        am_run  <= '0';
        wait until am_done = '0';
    end procedure axi_master_write;

    procedure axi_master_read(addr           : integer;
                              signal am_run  : out std_logic;
                              signal am_rd   : out std_logic;
                              signal am_addr : out std_logic_vector(C_S00_AXI_ADDR_WIDTH - 1 downto 0);
                              signal am_done : in std_logic
                             ) is
    begin
        am_run  <= '1';
        am_rd   <= '1';
        am_addr <= std_logic_vector(to_unsigned(addr, am_addr'length));
        wait until am_done = '1';
        am_run  <= '0';
        wait until am_done = '0';
    end procedure axi_master_read;
    signal LEDS_IO_T   : std_logic_vector(C_LED_WIDTH - 1 downto 0);
    signal LEDS_IO_O   : std_logic_vector(C_LED_WIDTH - 1 downto 0);
    signal LEDS_IO_I   : std_logic_vector(C_LED_WIDTH - 1 downto 0);
    signal SWITCH_IO_T : std_logic_vector(C_SWITCH_WIDTH - 1 downto 0);
    signal SWITCH_IO_O : std_logic_vector(C_SWITCH_WIDTH - 1 downto 0);
    signal SWITCH_IO_I : std_logic_vector(C_SWITCH_WIDTH - 1 downto 0);
    signal GPIO_IO_T   : std_logic_vector(C_GPIO_WIDTH - 1 downto 0);
    signal GPIO_IO_O   : std_logic_vector(C_GPIO_WIDTH - 1 downto 0);
    signal GPIO_IO_I   : std_logic_vector(C_GPIO_WIDTH - 1 downto 0);

begin

    clk             <= not clk after CLK_P / 2;
    s00_axi_aresetn <= not rst;

    axi_master : process(clk)
        type axi_master_state_t is (SIdle, SRDAddr, SRData, SWRAddr, SWAck, SDone);
        variable state : axi_master_state_t;
    begin
        if rising_edge(clk) then
            s00_axi_arvalid <= '0';
            s00_axi_rready  <= '0';
            s00_axi_awvalid <= '0';
            s00_axi_wvalid  <= '0';
            s00_axi_bready  <= '0';
            axi_master_done <= '0';
            if rst = '1' then
                state := SIdle;
            else
                case state is
                    when SIdle =>
                        if axi_master_run = '1' then
                            if axi_master_rd_not_wr = '1' then
                                state := SRDAddr;
                            else
                                state := SWRAddr;
                            end if;
                        end if;
                    when SRDAddr =>
                        s00_axi_araddr  <= axi_master_addr;
                        s00_axi_arvalid <= '1';
                        if s00_axi_arready = '1' and s00_axi_arvalid = '1' then
                            state           := SRData;
                            s00_axi_arvalid <= '0';
                            s00_axi_rready  <= '1';
                        end if;
                    when SRData =>
                        s00_axi_rready <= '1';
                        if s00_axi_rvalid = '1' and s00_axi_rready = '1' then
                            axi_master_rd_data <= s00_axi_rdata;
                            state              := SDone;
                            s00_axi_rready     <= '0';
                        end if;
                    when SWRAddr =>
                        s00_axi_awvalid <= '1';
                        s00_axi_wvalid  <= '1';
                        s00_axi_awaddr  <= axi_master_addr;
                        s00_axi_wdata   <= axi_master_wr_data;
                        if s00_axi_awready = '1' then
                            s00_axi_awvalid <= '0';
                        end if;
                        if s00_axi_wready = '1' then
                            s00_axi_wvalid <= '0';
                            s00_axi_bready <= '1';
                            state          := SWAck;
                        end if;
                    when SWAck =>
                        s00_axi_bready <= '1';
                        if s00_axi_bvalid = '1' then
                            s00_axi_bready <= '0';
                            state          := SDone;
                        end if;
                    when SDone =>
                        axi_master_done <= '1';
                        if axi_master_run = '1' then
                            state := SIdle;
                        end if;
                end case;
            end if;
        end if;
    end process;

    DUT : entity work.RISCV_wrapper
        generic map(
            C_S00_AXI_DATA_WIDTH => C_S00_AXI_DATA_WIDTH,
            C_S00_AXI_ADDR_WIDTH => C_S00_AXI_ADDR_WIDTH,
            C_LED_WIDTH          => C_LED_WIDTH,
            C_SWITCH_WIDTH       => C_SWITCH_WIDTH,
            C_GPIO_WIDTH         => C_GPIO_WIDTH,
            C_NUM_REGS           => C_NUM_REGS,
            C_RAM_DELAY          => C_RAM_DELAY
        )
        port map(
            LEDS_IO_T       => LEDS_IO_T,
            LEDS_IO_O       => LEDS_IO_O,
            LEDS_IO_I       => LEDS_IO_I,
            SWITCH_IO_T     => SWITCH_IO_T,
            SWITCH_IO_O     => SWITCH_IO_O,
            SWITCH_IO_I     => SWITCH_IO_I,
            GPIO_IO_T       => GPIO_IO_T,
            GPIO_IO_O       => GPIO_IO_O,
            GPIO_IO_I       => GPIO_IO_I,
            s00_axi_aclk    => clk,
            s00_axi_aresetn => s00_axi_aresetn,
            s00_axi_awaddr  => s00_axi_awaddr,
            s00_axi_awprot  => s00_axi_awprot,
            s00_axi_awvalid => s00_axi_awvalid,
            s00_axi_awready => s00_axi_awready,
            s00_axi_wdata   => s00_axi_wdata,
            s00_axi_wstrb   => s00_axi_wstrb,
            s00_axi_wvalid  => s00_axi_wvalid,
            s00_axi_wready  => s00_axi_wready,
            s00_axi_bresp   => s00_axi_bresp,
            s00_axi_bvalid  => s00_axi_bvalid,
            s00_axi_bready  => s00_axi_bready,
            s00_axi_araddr  => s00_axi_araddr,
            s00_axi_arprot  => s00_axi_arprot,
            s00_axi_arvalid => s00_axi_arvalid,
            s00_axi_arready => s00_axi_arready,
            s00_axi_rdata   => s00_axi_rdata,
            s00_axi_rresp   => s00_axi_rresp,
            s00_axi_rvalid  => s00_axi_rvalid,
            s00_axi_rready  => s00_axi_rready
        );

    process
    begin
        rst <= '1';
        wait for CLK_P * 10;
        rst <= '0';
        wait for CLK_P * 10;
        axi_master_read(addr => (65536 + 0), am_run => axi_master_run, am_rd => axi_master_rd_not_wr, am_addr => axi_master_addr, am_done => axi_master_done);
        wait for CLK_P * 10;
        axi_master_read(addr => (65536 + 4), am_run => axi_master_run, am_rd => axi_master_rd_not_wr, am_addr => axi_master_addr, am_done => axi_master_done);
        wait for CLK_P * 10;
        axi_master_read(addr => (65536 + 8), am_run => axi_master_run, am_rd => axi_master_rd_not_wr, am_addr => axi_master_addr, am_done => axi_master_done);
        wait for CLK_P * 10;
        axi_master_read(addr => (65536 + 12), am_run => axi_master_run, am_rd => axi_master_rd_not_wr, am_addr => axi_master_addr, am_done => axi_master_done);
        wait for CLK_P * 10;
        axi_master_write(addr => (65536 + 0), data => 16#0EADBEEF#, am_run => axi_master_run, am_rd => axi_master_rd_not_wr, am_data => axi_master_wr_data, am_addr => axi_master_addr, am_done => axi_master_done);
        wait for CLK_P * 10;
        axi_master_write(addr => (65536 + 4), data => 16#000B1E5F#, am_run => axi_master_run, am_rd => axi_master_rd_not_wr, am_data => axi_master_wr_data, am_addr => axi_master_addr, am_done => axi_master_done);
        wait for CLK_P * 10;
        axi_master_read(addr => (65536 + 0), am_run => axi_master_run, am_rd => axi_master_rd_not_wr, am_addr => axi_master_addr, am_done => axi_master_done);
        wait for CLK_P * 10;
        axi_master_read(addr => (65536 + 4), am_run => axi_master_run, am_rd => axi_master_rd_not_wr, am_addr => axi_master_addr, am_done => axi_master_done);
        wait;
    end process;

end Behavioral;

