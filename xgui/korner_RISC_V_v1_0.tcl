# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "C_NUM_REGS" -parent ${Page_0}
  set C_RAM_DELAY [ipgui::add_param $IPINST -name "C_RAM_DELAY" -parent ${Page_0}]
  set_property tooltip {Delay used in intenal memory} ${C_RAM_DELAY}
  ipgui::add_param $IPINST -name "C_S00_AXI_ADDR_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_S00_AXI_DATA_WIDTH" -parent ${Page_0}

  ipgui::add_param $IPINST -name "C_LED_WIDTH"
  ipgui::add_param $IPINST -name "C_SWITCH_WIDTH"
  ipgui::add_param $IPINST -name "C_GPIO_WIDTH"

}

proc update_PARAM_VALUE.C_GPIO_WIDTH { PARAM_VALUE.C_GPIO_WIDTH } {
	# Procedure called to update C_GPIO_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_GPIO_WIDTH { PARAM_VALUE.C_GPIO_WIDTH } {
	# Procedure called to validate C_GPIO_WIDTH
	return true
}

proc update_PARAM_VALUE.C_LED_WIDTH { PARAM_VALUE.C_LED_WIDTH } {
	# Procedure called to update C_LED_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_LED_WIDTH { PARAM_VALUE.C_LED_WIDTH } {
	# Procedure called to validate C_LED_WIDTH
	return true
}

proc update_PARAM_VALUE.C_NUM_REGS { PARAM_VALUE.C_NUM_REGS } {
	# Procedure called to update C_NUM_REGS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_NUM_REGS { PARAM_VALUE.C_NUM_REGS } {
	# Procedure called to validate C_NUM_REGS
	return true
}

proc update_PARAM_VALUE.C_RAM_DELAY { PARAM_VALUE.C_RAM_DELAY } {
	# Procedure called to update C_RAM_DELAY when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_RAM_DELAY { PARAM_VALUE.C_RAM_DELAY } {
	# Procedure called to validate C_RAM_DELAY
	return true
}

proc update_PARAM_VALUE.C_S00_AXI_ADDR_WIDTH { PARAM_VALUE.C_S00_AXI_ADDR_WIDTH } {
	# Procedure called to update C_S00_AXI_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S00_AXI_ADDR_WIDTH { PARAM_VALUE.C_S00_AXI_ADDR_WIDTH } {
	# Procedure called to validate C_S00_AXI_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S00_AXI_DATA_WIDTH { PARAM_VALUE.C_S00_AXI_DATA_WIDTH } {
	# Procedure called to update C_S00_AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S00_AXI_DATA_WIDTH { PARAM_VALUE.C_S00_AXI_DATA_WIDTH } {
	# Procedure called to validate C_S00_AXI_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_SWITCH_WIDTH { PARAM_VALUE.C_SWITCH_WIDTH } {
	# Procedure called to update C_SWITCH_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_SWITCH_WIDTH { PARAM_VALUE.C_SWITCH_WIDTH } {
	# Procedure called to validate C_SWITCH_WIDTH
	return true
}


proc update_MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH PARAM_VALUE.C_S00_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S00_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH PARAM_VALUE.C_S00_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S00_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.C_NUM_REGS { MODELPARAM_VALUE.C_NUM_REGS PARAM_VALUE.C_NUM_REGS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_NUM_REGS}] ${MODELPARAM_VALUE.C_NUM_REGS}
}

proc update_MODELPARAM_VALUE.C_RAM_DELAY { MODELPARAM_VALUE.C_RAM_DELAY PARAM_VALUE.C_RAM_DELAY } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_RAM_DELAY}] ${MODELPARAM_VALUE.C_RAM_DELAY}
}

proc update_MODELPARAM_VALUE.C_LED_WIDTH { MODELPARAM_VALUE.C_LED_WIDTH PARAM_VALUE.C_LED_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_LED_WIDTH}] ${MODELPARAM_VALUE.C_LED_WIDTH}
}

proc update_MODELPARAM_VALUE.C_SWITCH_WIDTH { MODELPARAM_VALUE.C_SWITCH_WIDTH PARAM_VALUE.C_SWITCH_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_SWITCH_WIDTH}] ${MODELPARAM_VALUE.C_SWITCH_WIDTH}
}

proc update_MODELPARAM_VALUE.C_GPIO_WIDTH { MODELPARAM_VALUE.C_GPIO_WIDTH PARAM_VALUE.C_GPIO_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_GPIO_WIDTH}] ${MODELPARAM_VALUE.C_GPIO_WIDTH}
}

