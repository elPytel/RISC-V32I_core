# Usage with Vitis IDE:
# In Vitis IDE create a Single Application Debug launch configuration,
# change the debug type to 'Attach to running target' and provide this 
# tcl script in 'Execute Script' option.
# Path of this script: C:\work\2022\BP\Korner\RISC-V\RISCVonZED\RISCVonZED_Vitis\RISCVonZed_system\_ide\scripts\debugger_riscvonzed_test00-default.tcl
# 
# 
# Usage with xsct:
# To debug using xsct, launch xsct and run below command
# source C:\work\2022\BP\Korner\RISC-V\RISCVonZED\RISCVonZED_Vitis\RISCVonZed_system\_ide\scripts\debugger_riscvonzed_test00-default.tcl
# 
connect -url tcp:127.0.0.1:3121
targets -set -nocase -filter {name =~"APU*"}
rst -system
after 3000
targets -set -filter {jtag_cable_name =~ "Digilent Zed 210248552928" && level==0 && jtag_device_ctx=="jsn-Zed-210248552928-23727093-0"}
fpga -file C:/work/2022/BP/Korner/RISC-V/RISCVonZED/RISCVonZED_Vitis/RISCVonZed_test00/_ide/bitstream/top_wrapper.bit
targets -set -nocase -filter {name =~"APU*"}
loadhw -hw C:/work/2022/BP/Korner/RISC-V/RISCVonZED/RISCVonZED_Vitis/top_wrapper/export/top_wrapper/hw/top_wrapper.xsa -mem-ranges [list {0x40000000 0xbfffffff}] -regs
configparams force-mem-access 1
targets -set -nocase -filter {name =~"APU*"}
source C:/work/2022/BP/Korner/RISC-V/RISCVonZED/RISCVonZED_Vitis/RISCVonZed_test00/_ide/psinit/ps7_init.tcl
ps7_init
ps7_post_config
targets -set -nocase -filter {name =~ "*A9*#0"}
dow C:/work/2022/BP/Korner/RISC-V/RISCVonZED/RISCVonZED_Vitis/RISCVonZed_test00/Debug/RISCVonZed_test00.elf
configparams force-mem-access 0
bpadd -addr &main
