// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.1 (win64) Build 3526262 Mon Apr 18 15:48:16 MDT 2022
// Date        : Thu May 11 11:44:00 2023
// Host        : NORMANDI running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               c:/work/2022/BP/Korner/RISC-V/RISCVonZED/RISCVonZED_Vivado/RISCVonZED_Vivado.gen/sources_1/bd/top/ip/top_korner_RISC_V_0_0/top_korner_RISC_V_0_0_stub.v
// Design      : top_korner_RISC_V_0_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg484-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "RISCV_wrapper,Vivado 2022.1" *)
module top_korner_RISC_V_0_0(LEDS_IO_T, LEDS_IO_O, LEDS_IO_I, SWITCH_IO_T, 
  SWITCH_IO_O, SWITCH_IO_I, GPIO_IO_T, GPIO_IO_O, GPIO_IO_I, s00_axi_aclk, s00_axi_aresetn, 
  s00_axi_awaddr, s00_axi_awprot, s00_axi_awvalid, s00_axi_awready, s00_axi_wdata, 
  s00_axi_wstrb, s00_axi_wvalid, s00_axi_wready, s00_axi_bresp, s00_axi_bvalid, 
  s00_axi_bready, s00_axi_araddr, s00_axi_arprot, s00_axi_arvalid, s00_axi_arready, 
  s00_axi_rdata, s00_axi_rresp, s00_axi_rvalid, s00_axi_rready)
/* synthesis syn_black_box black_box_pad_pin="LEDS_IO_T[7:0],LEDS_IO_O[7:0],LEDS_IO_I[7:0],SWITCH_IO_T[7:0],SWITCH_IO_O[7:0],SWITCH_IO_I[7:0],GPIO_IO_T[7:0],GPIO_IO_O[7:0],GPIO_IO_I[7:0],s00_axi_aclk,s00_axi_aresetn,s00_axi_awaddr[16:0],s00_axi_awprot[2:0],s00_axi_awvalid,s00_axi_awready,s00_axi_wdata[31:0],s00_axi_wstrb[3:0],s00_axi_wvalid,s00_axi_wready,s00_axi_bresp[1:0],s00_axi_bvalid,s00_axi_bready,s00_axi_araddr[16:0],s00_axi_arprot[2:0],s00_axi_arvalid,s00_axi_arready,s00_axi_rdata[31:0],s00_axi_rresp[1:0],s00_axi_rvalid,s00_axi_rready" */;
  output [7:0]LEDS_IO_T;
  output [7:0]LEDS_IO_O;
  input [7:0]LEDS_IO_I;
  output [7:0]SWITCH_IO_T;
  output [7:0]SWITCH_IO_O;
  input [7:0]SWITCH_IO_I;
  output [7:0]GPIO_IO_T;
  output [7:0]GPIO_IO_O;
  input [7:0]GPIO_IO_I;
  input s00_axi_aclk;
  input s00_axi_aresetn;
  input [16:0]s00_axi_awaddr;
  input [2:0]s00_axi_awprot;
  input s00_axi_awvalid;
  output s00_axi_awready;
  input [31:0]s00_axi_wdata;
  input [3:0]s00_axi_wstrb;
  input s00_axi_wvalid;
  output s00_axi_wready;
  output [1:0]s00_axi_bresp;
  output s00_axi_bvalid;
  input s00_axi_bready;
  input [16:0]s00_axi_araddr;
  input [2:0]s00_axi_arprot;
  input s00_axi_arvalid;
  output s00_axi_arready;
  output [31:0]s00_axi_rdata;
  output [1:0]s00_axi_rresp;
  output s00_axi_rvalid;
  input s00_axi_rready;
endmodule
