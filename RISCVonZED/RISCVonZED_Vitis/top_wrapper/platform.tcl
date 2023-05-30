# 
# Usage: To re-create this platform project launch xsct with below options.
# xsct C:\work\2022\BP\Korner\RISC-V\RISCVonZED\RISCVonZED_Vitis\top_wrapper\platform.tcl
# 
# OR launch xsct and run below command.
# source C:\work\2022\BP\Korner\RISC-V\RISCVonZED\RISCVonZED_Vitis\top_wrapper\platform.tcl
# 
# To create the platform in a different location, modify the -out option of "platform create" command.
# -out option specifies the output directory of the platform project.

platform create -name {top_wrapper}\
-hw {C:\work\2022\BP\Korner\RISC-V\RISCVonZED\RISCVonZED_Vivado\top_wrapper.xsa}\
-out {C:/work/2022/BP/Korner/RISC-V/RISCVonZED/RISCVonZED_Vitis}

platform write
domain create -name {standalone_ps7_cortexa9_0} -display-name {standalone_ps7_cortexa9_0} -os {standalone} -proc {ps7_cortexa9_0} -runtime {cpp} -arch {32-bit} -support-app {hello_world}
platform generate -domains 
platform active {top_wrapper}
domain active {zynq_fsbl}
domain active {standalone_ps7_cortexa9_0}
platform generate -quick
bsp reload
bsp setlib -name xilffs -ver 4.7
bsp write
bsp reload
catch {bsp regenerate}
platform generate
bsp reload
bsp config use_strfunc "2"
bsp write
bsp reload
catch {bsp regenerate}
platform generate -domains standalone_ps7_cortexa9_0 
