# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "CLK_PER" -parent ${Page_0}
  ipgui::add_param $IPINST -name "NUM_SEGMENTS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "REFR_RATE" -parent ${Page_0}


}

proc update_PARAM_VALUE.CLK_PER { PARAM_VALUE.CLK_PER } {
	# Procedure called to update CLK_PER when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CLK_PER { PARAM_VALUE.CLK_PER } {
	# Procedure called to validate CLK_PER
	return true
}

proc update_PARAM_VALUE.NUM_SEGMENTS { PARAM_VALUE.NUM_SEGMENTS } {
	# Procedure called to update NUM_SEGMENTS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NUM_SEGMENTS { PARAM_VALUE.NUM_SEGMENTS } {
	# Procedure called to validate NUM_SEGMENTS
	return true
}

proc update_PARAM_VALUE.REFR_RATE { PARAM_VALUE.REFR_RATE } {
	# Procedure called to update REFR_RATE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.REFR_RATE { PARAM_VALUE.REFR_RATE } {
	# Procedure called to validate REFR_RATE
	return true
}


proc update_MODELPARAM_VALUE.NUM_SEGMENTS { MODELPARAM_VALUE.NUM_SEGMENTS PARAM_VALUE.NUM_SEGMENTS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NUM_SEGMENTS}] ${MODELPARAM_VALUE.NUM_SEGMENTS}
}

proc update_MODELPARAM_VALUE.CLK_PER { MODELPARAM_VALUE.CLK_PER PARAM_VALUE.CLK_PER } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CLK_PER}] ${MODELPARAM_VALUE.CLK_PER}
}

proc update_MODELPARAM_VALUE.REFR_RATE { MODELPARAM_VALUE.REFR_RATE PARAM_VALUE.REFR_RATE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.REFR_RATE}] ${MODELPARAM_VALUE.REFR_RATE}
}

