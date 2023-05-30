--Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2022.1 (win64) Build 3526262 Mon Apr 18 15:48:16 MDT 2022
--Date        : Thu May 11 11:41:49 2023
--Host        : NORMANDI running 64-bit major release  (build 9200)
--Command     : generate_target top_wrapper.bd
--Design      : top_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity top_wrapper is
  port (
    DDR_addr : inout STD_LOGIC_VECTOR ( 14 downto 0 );
    DDR_ba : inout STD_LOGIC_VECTOR ( 2 downto 0 );
    DDR_cas_n : inout STD_LOGIC;
    DDR_ck_n : inout STD_LOGIC;
    DDR_ck_p : inout STD_LOGIC;
    DDR_cke : inout STD_LOGIC;
    DDR_cs_n : inout STD_LOGIC;
    DDR_dm : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dq : inout STD_LOGIC_VECTOR ( 31 downto 0 );
    DDR_dqs_n : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dqs_p : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_odt : inout STD_LOGIC;
    DDR_ras_n : inout STD_LOGIC;
    DDR_reset_n : inout STD_LOGIC;
    DDR_we_n : inout STD_LOGIC;
    FIXED_IO_ddr_vrn : inout STD_LOGIC;
    FIXED_IO_ddr_vrp : inout STD_LOGIC;
    FIXED_IO_mio : inout STD_LOGIC_VECTOR ( 53 downto 0 );
    FIXED_IO_ps_clk : inout STD_LOGIC;
    FIXED_IO_ps_porb : inout STD_LOGIC;
    FIXED_IO_ps_srstb : inout STD_LOGIC;
    GPIO_IO_tri_io : inout STD_LOGIC_VECTOR ( 7 downto 0 );
    LEDS_IO_tri_io : inout STD_LOGIC_VECTOR ( 7 downto 0 );
    SWITCH_IO_tri_io : inout STD_LOGIC_VECTOR ( 7 downto 0 )
  );
end top_wrapper;

architecture STRUCTURE of top_wrapper is
  component top is
  port (
    DDR_cas_n : inout STD_LOGIC;
    DDR_cke : inout STD_LOGIC;
    DDR_ck_n : inout STD_LOGIC;
    DDR_ck_p : inout STD_LOGIC;
    DDR_cs_n : inout STD_LOGIC;
    DDR_reset_n : inout STD_LOGIC;
    DDR_odt : inout STD_LOGIC;
    DDR_ras_n : inout STD_LOGIC;
    DDR_we_n : inout STD_LOGIC;
    DDR_ba : inout STD_LOGIC_VECTOR ( 2 downto 0 );
    DDR_addr : inout STD_LOGIC_VECTOR ( 14 downto 0 );
    DDR_dm : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dq : inout STD_LOGIC_VECTOR ( 31 downto 0 );
    DDR_dqs_n : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dqs_p : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    FIXED_IO_mio : inout STD_LOGIC_VECTOR ( 53 downto 0 );
    FIXED_IO_ddr_vrn : inout STD_LOGIC;
    FIXED_IO_ddr_vrp : inout STD_LOGIC;
    FIXED_IO_ps_srstb : inout STD_LOGIC;
    FIXED_IO_ps_clk : inout STD_LOGIC;
    FIXED_IO_ps_porb : inout STD_LOGIC;
    LEDS_IO_tri_o : out STD_LOGIC_VECTOR ( 7 downto 0 );
    LEDS_IO_tri_t : out STD_LOGIC_VECTOR ( 7 downto 0 );
    LEDS_IO_tri_i : in STD_LOGIC_VECTOR ( 7 downto 0 );
    SWITCH_IO_tri_o : out STD_LOGIC_VECTOR ( 7 downto 0 );
    SWITCH_IO_tri_t : out STD_LOGIC_VECTOR ( 7 downto 0 );
    SWITCH_IO_tri_i : in STD_LOGIC_VECTOR ( 7 downto 0 );
    GPIO_IO_tri_o : out STD_LOGIC_VECTOR ( 7 downto 0 );
    GPIO_IO_tri_t : out STD_LOGIC_VECTOR ( 7 downto 0 );
    GPIO_IO_tri_i : in STD_LOGIC_VECTOR ( 7 downto 0 )
  );
  end component top;
  component IOBUF is
  port (
    I : in STD_LOGIC;
    O : out STD_LOGIC;
    T : in STD_LOGIC;
    IO : inout STD_LOGIC
  );
  end component IOBUF;
  signal GPIO_IO_tri_i_0 : STD_LOGIC_VECTOR ( 0 to 0 );
  signal GPIO_IO_tri_i_1 : STD_LOGIC_VECTOR ( 1 to 1 );
  signal GPIO_IO_tri_i_2 : STD_LOGIC_VECTOR ( 2 to 2 );
  signal GPIO_IO_tri_i_3 : STD_LOGIC_VECTOR ( 3 to 3 );
  signal GPIO_IO_tri_i_4 : STD_LOGIC_VECTOR ( 4 to 4 );
  signal GPIO_IO_tri_i_5 : STD_LOGIC_VECTOR ( 5 to 5 );
  signal GPIO_IO_tri_i_6 : STD_LOGIC_VECTOR ( 6 to 6 );
  signal GPIO_IO_tri_i_7 : STD_LOGIC_VECTOR ( 7 to 7 );
  signal GPIO_IO_tri_io_0 : STD_LOGIC_VECTOR ( 0 to 0 );
  signal GPIO_IO_tri_io_1 : STD_LOGIC_VECTOR ( 1 to 1 );
  signal GPIO_IO_tri_io_2 : STD_LOGIC_VECTOR ( 2 to 2 );
  signal GPIO_IO_tri_io_3 : STD_LOGIC_VECTOR ( 3 to 3 );
  signal GPIO_IO_tri_io_4 : STD_LOGIC_VECTOR ( 4 to 4 );
  signal GPIO_IO_tri_io_5 : STD_LOGIC_VECTOR ( 5 to 5 );
  signal GPIO_IO_tri_io_6 : STD_LOGIC_VECTOR ( 6 to 6 );
  signal GPIO_IO_tri_io_7 : STD_LOGIC_VECTOR ( 7 to 7 );
  signal GPIO_IO_tri_o_0 : STD_LOGIC_VECTOR ( 0 to 0 );
  signal GPIO_IO_tri_o_1 : STD_LOGIC_VECTOR ( 1 to 1 );
  signal GPIO_IO_tri_o_2 : STD_LOGIC_VECTOR ( 2 to 2 );
  signal GPIO_IO_tri_o_3 : STD_LOGIC_VECTOR ( 3 to 3 );
  signal GPIO_IO_tri_o_4 : STD_LOGIC_VECTOR ( 4 to 4 );
  signal GPIO_IO_tri_o_5 : STD_LOGIC_VECTOR ( 5 to 5 );
  signal GPIO_IO_tri_o_6 : STD_LOGIC_VECTOR ( 6 to 6 );
  signal GPIO_IO_tri_o_7 : STD_LOGIC_VECTOR ( 7 to 7 );
  signal GPIO_IO_tri_t_0 : STD_LOGIC_VECTOR ( 0 to 0 );
  signal GPIO_IO_tri_t_1 : STD_LOGIC_VECTOR ( 1 to 1 );
  signal GPIO_IO_tri_t_2 : STD_LOGIC_VECTOR ( 2 to 2 );
  signal GPIO_IO_tri_t_3 : STD_LOGIC_VECTOR ( 3 to 3 );
  signal GPIO_IO_tri_t_4 : STD_LOGIC_VECTOR ( 4 to 4 );
  signal GPIO_IO_tri_t_5 : STD_LOGIC_VECTOR ( 5 to 5 );
  signal GPIO_IO_tri_t_6 : STD_LOGIC_VECTOR ( 6 to 6 );
  signal GPIO_IO_tri_t_7 : STD_LOGIC_VECTOR ( 7 to 7 );
  signal LEDS_IO_tri_i_0 : STD_LOGIC_VECTOR ( 0 to 0 );
  signal LEDS_IO_tri_i_1 : STD_LOGIC_VECTOR ( 1 to 1 );
  signal LEDS_IO_tri_i_2 : STD_LOGIC_VECTOR ( 2 to 2 );
  signal LEDS_IO_tri_i_3 : STD_LOGIC_VECTOR ( 3 to 3 );
  signal LEDS_IO_tri_i_4 : STD_LOGIC_VECTOR ( 4 to 4 );
  signal LEDS_IO_tri_i_5 : STD_LOGIC_VECTOR ( 5 to 5 );
  signal LEDS_IO_tri_i_6 : STD_LOGIC_VECTOR ( 6 to 6 );
  signal LEDS_IO_tri_i_7 : STD_LOGIC_VECTOR ( 7 to 7 );
  signal LEDS_IO_tri_io_0 : STD_LOGIC_VECTOR ( 0 to 0 );
  signal LEDS_IO_tri_io_1 : STD_LOGIC_VECTOR ( 1 to 1 );
  signal LEDS_IO_tri_io_2 : STD_LOGIC_VECTOR ( 2 to 2 );
  signal LEDS_IO_tri_io_3 : STD_LOGIC_VECTOR ( 3 to 3 );
  signal LEDS_IO_tri_io_4 : STD_LOGIC_VECTOR ( 4 to 4 );
  signal LEDS_IO_tri_io_5 : STD_LOGIC_VECTOR ( 5 to 5 );
  signal LEDS_IO_tri_io_6 : STD_LOGIC_VECTOR ( 6 to 6 );
  signal LEDS_IO_tri_io_7 : STD_LOGIC_VECTOR ( 7 to 7 );
  signal LEDS_IO_tri_o_0 : STD_LOGIC_VECTOR ( 0 to 0 );
  signal LEDS_IO_tri_o_1 : STD_LOGIC_VECTOR ( 1 to 1 );
  signal LEDS_IO_tri_o_2 : STD_LOGIC_VECTOR ( 2 to 2 );
  signal LEDS_IO_tri_o_3 : STD_LOGIC_VECTOR ( 3 to 3 );
  signal LEDS_IO_tri_o_4 : STD_LOGIC_VECTOR ( 4 to 4 );
  signal LEDS_IO_tri_o_5 : STD_LOGIC_VECTOR ( 5 to 5 );
  signal LEDS_IO_tri_o_6 : STD_LOGIC_VECTOR ( 6 to 6 );
  signal LEDS_IO_tri_o_7 : STD_LOGIC_VECTOR ( 7 to 7 );
  signal LEDS_IO_tri_t_0 : STD_LOGIC_VECTOR ( 0 to 0 );
  signal LEDS_IO_tri_t_1 : STD_LOGIC_VECTOR ( 1 to 1 );
  signal LEDS_IO_tri_t_2 : STD_LOGIC_VECTOR ( 2 to 2 );
  signal LEDS_IO_tri_t_3 : STD_LOGIC_VECTOR ( 3 to 3 );
  signal LEDS_IO_tri_t_4 : STD_LOGIC_VECTOR ( 4 to 4 );
  signal LEDS_IO_tri_t_5 : STD_LOGIC_VECTOR ( 5 to 5 );
  signal LEDS_IO_tri_t_6 : STD_LOGIC_VECTOR ( 6 to 6 );
  signal LEDS_IO_tri_t_7 : STD_LOGIC_VECTOR ( 7 to 7 );
  signal SWITCH_IO_tri_i_0 : STD_LOGIC_VECTOR ( 0 to 0 );
  signal SWITCH_IO_tri_i_1 : STD_LOGIC_VECTOR ( 1 to 1 );
  signal SWITCH_IO_tri_i_2 : STD_LOGIC_VECTOR ( 2 to 2 );
  signal SWITCH_IO_tri_i_3 : STD_LOGIC_VECTOR ( 3 to 3 );
  signal SWITCH_IO_tri_i_4 : STD_LOGIC_VECTOR ( 4 to 4 );
  signal SWITCH_IO_tri_i_5 : STD_LOGIC_VECTOR ( 5 to 5 );
  signal SWITCH_IO_tri_i_6 : STD_LOGIC_VECTOR ( 6 to 6 );
  signal SWITCH_IO_tri_i_7 : STD_LOGIC_VECTOR ( 7 to 7 );
  signal SWITCH_IO_tri_io_0 : STD_LOGIC_VECTOR ( 0 to 0 );
  signal SWITCH_IO_tri_io_1 : STD_LOGIC_VECTOR ( 1 to 1 );
  signal SWITCH_IO_tri_io_2 : STD_LOGIC_VECTOR ( 2 to 2 );
  signal SWITCH_IO_tri_io_3 : STD_LOGIC_VECTOR ( 3 to 3 );
  signal SWITCH_IO_tri_io_4 : STD_LOGIC_VECTOR ( 4 to 4 );
  signal SWITCH_IO_tri_io_5 : STD_LOGIC_VECTOR ( 5 to 5 );
  signal SWITCH_IO_tri_io_6 : STD_LOGIC_VECTOR ( 6 to 6 );
  signal SWITCH_IO_tri_io_7 : STD_LOGIC_VECTOR ( 7 to 7 );
  signal SWITCH_IO_tri_o_0 : STD_LOGIC_VECTOR ( 0 to 0 );
  signal SWITCH_IO_tri_o_1 : STD_LOGIC_VECTOR ( 1 to 1 );
  signal SWITCH_IO_tri_o_2 : STD_LOGIC_VECTOR ( 2 to 2 );
  signal SWITCH_IO_tri_o_3 : STD_LOGIC_VECTOR ( 3 to 3 );
  signal SWITCH_IO_tri_o_4 : STD_LOGIC_VECTOR ( 4 to 4 );
  signal SWITCH_IO_tri_o_5 : STD_LOGIC_VECTOR ( 5 to 5 );
  signal SWITCH_IO_tri_o_6 : STD_LOGIC_VECTOR ( 6 to 6 );
  signal SWITCH_IO_tri_o_7 : STD_LOGIC_VECTOR ( 7 to 7 );
  signal SWITCH_IO_tri_t_0 : STD_LOGIC_VECTOR ( 0 to 0 );
  signal SWITCH_IO_tri_t_1 : STD_LOGIC_VECTOR ( 1 to 1 );
  signal SWITCH_IO_tri_t_2 : STD_LOGIC_VECTOR ( 2 to 2 );
  signal SWITCH_IO_tri_t_3 : STD_LOGIC_VECTOR ( 3 to 3 );
  signal SWITCH_IO_tri_t_4 : STD_LOGIC_VECTOR ( 4 to 4 );
  signal SWITCH_IO_tri_t_5 : STD_LOGIC_VECTOR ( 5 to 5 );
  signal SWITCH_IO_tri_t_6 : STD_LOGIC_VECTOR ( 6 to 6 );
  signal SWITCH_IO_tri_t_7 : STD_LOGIC_VECTOR ( 7 to 7 );
begin
GPIO_IO_tri_iobuf_0: component IOBUF
     port map (
      I => GPIO_IO_tri_o_0(0),
      IO => GPIO_IO_tri_io(0),
      O => GPIO_IO_tri_i_0(0),
      T => GPIO_IO_tri_t_0(0)
    );
GPIO_IO_tri_iobuf_1: component IOBUF
     port map (
      I => GPIO_IO_tri_o_1(1),
      IO => GPIO_IO_tri_io(1),
      O => GPIO_IO_tri_i_1(1),
      T => GPIO_IO_tri_t_1(1)
    );
GPIO_IO_tri_iobuf_2: component IOBUF
     port map (
      I => GPIO_IO_tri_o_2(2),
      IO => GPIO_IO_tri_io(2),
      O => GPIO_IO_tri_i_2(2),
      T => GPIO_IO_tri_t_2(2)
    );
GPIO_IO_tri_iobuf_3: component IOBUF
     port map (
      I => GPIO_IO_tri_o_3(3),
      IO => GPIO_IO_tri_io(3),
      O => GPIO_IO_tri_i_3(3),
      T => GPIO_IO_tri_t_3(3)
    );
GPIO_IO_tri_iobuf_4: component IOBUF
     port map (
      I => GPIO_IO_tri_o_4(4),
      IO => GPIO_IO_tri_io(4),
      O => GPIO_IO_tri_i_4(4),
      T => GPIO_IO_tri_t_4(4)
    );
GPIO_IO_tri_iobuf_5: component IOBUF
     port map (
      I => GPIO_IO_tri_o_5(5),
      IO => GPIO_IO_tri_io(5),
      O => GPIO_IO_tri_i_5(5),
      T => GPIO_IO_tri_t_5(5)
    );
GPIO_IO_tri_iobuf_6: component IOBUF
     port map (
      I => GPIO_IO_tri_o_6(6),
      IO => GPIO_IO_tri_io(6),
      O => GPIO_IO_tri_i_6(6),
      T => GPIO_IO_tri_t_6(6)
    );
GPIO_IO_tri_iobuf_7: component IOBUF
     port map (
      I => GPIO_IO_tri_o_7(7),
      IO => GPIO_IO_tri_io(7),
      O => GPIO_IO_tri_i_7(7),
      T => GPIO_IO_tri_t_7(7)
    );
LEDS_IO_tri_iobuf_0: component IOBUF
     port map (
      I => LEDS_IO_tri_o_0(0),
      IO => LEDS_IO_tri_io(0),
      O => LEDS_IO_tri_i_0(0),
      T => LEDS_IO_tri_t_0(0)
    );
LEDS_IO_tri_iobuf_1: component IOBUF
     port map (
      I => LEDS_IO_tri_o_1(1),
      IO => LEDS_IO_tri_io(1),
      O => LEDS_IO_tri_i_1(1),
      T => LEDS_IO_tri_t_1(1)
    );
LEDS_IO_tri_iobuf_2: component IOBUF
     port map (
      I => LEDS_IO_tri_o_2(2),
      IO => LEDS_IO_tri_io(2),
      O => LEDS_IO_tri_i_2(2),
      T => LEDS_IO_tri_t_2(2)
    );
LEDS_IO_tri_iobuf_3: component IOBUF
     port map (
      I => LEDS_IO_tri_o_3(3),
      IO => LEDS_IO_tri_io(3),
      O => LEDS_IO_tri_i_3(3),
      T => LEDS_IO_tri_t_3(3)
    );
LEDS_IO_tri_iobuf_4: component IOBUF
     port map (
      I => LEDS_IO_tri_o_4(4),
      IO => LEDS_IO_tri_io(4),
      O => LEDS_IO_tri_i_4(4),
      T => LEDS_IO_tri_t_4(4)
    );
LEDS_IO_tri_iobuf_5: component IOBUF
     port map (
      I => LEDS_IO_tri_o_5(5),
      IO => LEDS_IO_tri_io(5),
      O => LEDS_IO_tri_i_5(5),
      T => LEDS_IO_tri_t_5(5)
    );
LEDS_IO_tri_iobuf_6: component IOBUF
     port map (
      I => LEDS_IO_tri_o_6(6),
      IO => LEDS_IO_tri_io(6),
      O => LEDS_IO_tri_i_6(6),
      T => LEDS_IO_tri_t_6(6)
    );
LEDS_IO_tri_iobuf_7: component IOBUF
     port map (
      I => LEDS_IO_tri_o_7(7),
      IO => LEDS_IO_tri_io(7),
      O => LEDS_IO_tri_i_7(7),
      T => LEDS_IO_tri_t_7(7)
    );
SWITCH_IO_tri_iobuf_0: component IOBUF
     port map (
      I => SWITCH_IO_tri_o_0(0),
      IO => SWITCH_IO_tri_io(0),
      O => SWITCH_IO_tri_i_0(0),
      T => SWITCH_IO_tri_t_0(0)
    );
SWITCH_IO_tri_iobuf_1: component IOBUF
     port map (
      I => SWITCH_IO_tri_o_1(1),
      IO => SWITCH_IO_tri_io(1),
      O => SWITCH_IO_tri_i_1(1),
      T => SWITCH_IO_tri_t_1(1)
    );
SWITCH_IO_tri_iobuf_2: component IOBUF
     port map (
      I => SWITCH_IO_tri_o_2(2),
      IO => SWITCH_IO_tri_io(2),
      O => SWITCH_IO_tri_i_2(2),
      T => SWITCH_IO_tri_t_2(2)
    );
SWITCH_IO_tri_iobuf_3: component IOBUF
     port map (
      I => SWITCH_IO_tri_o_3(3),
      IO => SWITCH_IO_tri_io(3),
      O => SWITCH_IO_tri_i_3(3),
      T => SWITCH_IO_tri_t_3(3)
    );
SWITCH_IO_tri_iobuf_4: component IOBUF
     port map (
      I => SWITCH_IO_tri_o_4(4),
      IO => SWITCH_IO_tri_io(4),
      O => SWITCH_IO_tri_i_4(4),
      T => SWITCH_IO_tri_t_4(4)
    );
SWITCH_IO_tri_iobuf_5: component IOBUF
     port map (
      I => SWITCH_IO_tri_o_5(5),
      IO => SWITCH_IO_tri_io(5),
      O => SWITCH_IO_tri_i_5(5),
      T => SWITCH_IO_tri_t_5(5)
    );
SWITCH_IO_tri_iobuf_6: component IOBUF
     port map (
      I => SWITCH_IO_tri_o_6(6),
      IO => SWITCH_IO_tri_io(6),
      O => SWITCH_IO_tri_i_6(6),
      T => SWITCH_IO_tri_t_6(6)
    );
SWITCH_IO_tri_iobuf_7: component IOBUF
     port map (
      I => SWITCH_IO_tri_o_7(7),
      IO => SWITCH_IO_tri_io(7),
      O => SWITCH_IO_tri_i_7(7),
      T => SWITCH_IO_tri_t_7(7)
    );
top_i: component top
     port map (
      DDR_addr(14 downto 0) => DDR_addr(14 downto 0),
      DDR_ba(2 downto 0) => DDR_ba(2 downto 0),
      DDR_cas_n => DDR_cas_n,
      DDR_ck_n => DDR_ck_n,
      DDR_ck_p => DDR_ck_p,
      DDR_cke => DDR_cke,
      DDR_cs_n => DDR_cs_n,
      DDR_dm(3 downto 0) => DDR_dm(3 downto 0),
      DDR_dq(31 downto 0) => DDR_dq(31 downto 0),
      DDR_dqs_n(3 downto 0) => DDR_dqs_n(3 downto 0),
      DDR_dqs_p(3 downto 0) => DDR_dqs_p(3 downto 0),
      DDR_odt => DDR_odt,
      DDR_ras_n => DDR_ras_n,
      DDR_reset_n => DDR_reset_n,
      DDR_we_n => DDR_we_n,
      FIXED_IO_ddr_vrn => FIXED_IO_ddr_vrn,
      FIXED_IO_ddr_vrp => FIXED_IO_ddr_vrp,
      FIXED_IO_mio(53 downto 0) => FIXED_IO_mio(53 downto 0),
      FIXED_IO_ps_clk => FIXED_IO_ps_clk,
      FIXED_IO_ps_porb => FIXED_IO_ps_porb,
      FIXED_IO_ps_srstb => FIXED_IO_ps_srstb,
      GPIO_IO_tri_i(7) => GPIO_IO_tri_i_7(7),
      GPIO_IO_tri_i(6) => GPIO_IO_tri_i_6(6),
      GPIO_IO_tri_i(5) => GPIO_IO_tri_i_5(5),
      GPIO_IO_tri_i(4) => GPIO_IO_tri_i_4(4),
      GPIO_IO_tri_i(3) => GPIO_IO_tri_i_3(3),
      GPIO_IO_tri_i(2) => GPIO_IO_tri_i_2(2),
      GPIO_IO_tri_i(1) => GPIO_IO_tri_i_1(1),
      GPIO_IO_tri_i(0) => GPIO_IO_tri_i_0(0),
      GPIO_IO_tri_o(7) => GPIO_IO_tri_o_7(7),
      GPIO_IO_tri_o(6) => GPIO_IO_tri_o_6(6),
      GPIO_IO_tri_o(5) => GPIO_IO_tri_o_5(5),
      GPIO_IO_tri_o(4) => GPIO_IO_tri_o_4(4),
      GPIO_IO_tri_o(3) => GPIO_IO_tri_o_3(3),
      GPIO_IO_tri_o(2) => GPIO_IO_tri_o_2(2),
      GPIO_IO_tri_o(1) => GPIO_IO_tri_o_1(1),
      GPIO_IO_tri_o(0) => GPIO_IO_tri_o_0(0),
      GPIO_IO_tri_t(7) => GPIO_IO_tri_t_7(7),
      GPIO_IO_tri_t(6) => GPIO_IO_tri_t_6(6),
      GPIO_IO_tri_t(5) => GPIO_IO_tri_t_5(5),
      GPIO_IO_tri_t(4) => GPIO_IO_tri_t_4(4),
      GPIO_IO_tri_t(3) => GPIO_IO_tri_t_3(3),
      GPIO_IO_tri_t(2) => GPIO_IO_tri_t_2(2),
      GPIO_IO_tri_t(1) => GPIO_IO_tri_t_1(1),
      GPIO_IO_tri_t(0) => GPIO_IO_tri_t_0(0),
      LEDS_IO_tri_i(7) => LEDS_IO_tri_i_7(7),
      LEDS_IO_tri_i(6) => LEDS_IO_tri_i_6(6),
      LEDS_IO_tri_i(5) => LEDS_IO_tri_i_5(5),
      LEDS_IO_tri_i(4) => LEDS_IO_tri_i_4(4),
      LEDS_IO_tri_i(3) => LEDS_IO_tri_i_3(3),
      LEDS_IO_tri_i(2) => LEDS_IO_tri_i_2(2),
      LEDS_IO_tri_i(1) => LEDS_IO_tri_i_1(1),
      LEDS_IO_tri_i(0) => LEDS_IO_tri_i_0(0),
      LEDS_IO_tri_o(7) => LEDS_IO_tri_o_7(7),
      LEDS_IO_tri_o(6) => LEDS_IO_tri_o_6(6),
      LEDS_IO_tri_o(5) => LEDS_IO_tri_o_5(5),
      LEDS_IO_tri_o(4) => LEDS_IO_tri_o_4(4),
      LEDS_IO_tri_o(3) => LEDS_IO_tri_o_3(3),
      LEDS_IO_tri_o(2) => LEDS_IO_tri_o_2(2),
      LEDS_IO_tri_o(1) => LEDS_IO_tri_o_1(1),
      LEDS_IO_tri_o(0) => LEDS_IO_tri_o_0(0),
      LEDS_IO_tri_t(7) => LEDS_IO_tri_t_7(7),
      LEDS_IO_tri_t(6) => LEDS_IO_tri_t_6(6),
      LEDS_IO_tri_t(5) => LEDS_IO_tri_t_5(5),
      LEDS_IO_tri_t(4) => LEDS_IO_tri_t_4(4),
      LEDS_IO_tri_t(3) => LEDS_IO_tri_t_3(3),
      LEDS_IO_tri_t(2) => LEDS_IO_tri_t_2(2),
      LEDS_IO_tri_t(1) => LEDS_IO_tri_t_1(1),
      LEDS_IO_tri_t(0) => LEDS_IO_tri_t_0(0),
      SWITCH_IO_tri_i(7) => SWITCH_IO_tri_i_7(7),
      SWITCH_IO_tri_i(6) => SWITCH_IO_tri_i_6(6),
      SWITCH_IO_tri_i(5) => SWITCH_IO_tri_i_5(5),
      SWITCH_IO_tri_i(4) => SWITCH_IO_tri_i_4(4),
      SWITCH_IO_tri_i(3) => SWITCH_IO_tri_i_3(3),
      SWITCH_IO_tri_i(2) => SWITCH_IO_tri_i_2(2),
      SWITCH_IO_tri_i(1) => SWITCH_IO_tri_i_1(1),
      SWITCH_IO_tri_i(0) => SWITCH_IO_tri_i_0(0),
      SWITCH_IO_tri_o(7) => SWITCH_IO_tri_o_7(7),
      SWITCH_IO_tri_o(6) => SWITCH_IO_tri_o_6(6),
      SWITCH_IO_tri_o(5) => SWITCH_IO_tri_o_5(5),
      SWITCH_IO_tri_o(4) => SWITCH_IO_tri_o_4(4),
      SWITCH_IO_tri_o(3) => SWITCH_IO_tri_o_3(3),
      SWITCH_IO_tri_o(2) => SWITCH_IO_tri_o_2(2),
      SWITCH_IO_tri_o(1) => SWITCH_IO_tri_o_1(1),
      SWITCH_IO_tri_o(0) => SWITCH_IO_tri_o_0(0),
      SWITCH_IO_tri_t(7) => SWITCH_IO_tri_t_7(7),
      SWITCH_IO_tri_t(6) => SWITCH_IO_tri_t_6(6),
      SWITCH_IO_tri_t(5) => SWITCH_IO_tri_t_5(5),
      SWITCH_IO_tri_t(4) => SWITCH_IO_tri_t_4(4),
      SWITCH_IO_tri_t(3) => SWITCH_IO_tri_t_3(3),
      SWITCH_IO_tri_t(2) => SWITCH_IO_tri_t_2(2),
      SWITCH_IO_tri_t(1) => SWITCH_IO_tri_t_1(1),
      SWITCH_IO_tri_t(0) => SWITCH_IO_tri_t_0(0)
    );
end STRUCTURE;
