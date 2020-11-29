# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "CLK_PER" -parent ${Page_0}
  ipgui::add_param $IPINST -name "INTERVAL" -parent ${Page_0}


}

proc update_PARAM_VALUE.CLK_PER { PARAM_VALUE.CLK_PER } {
	# Procedure called to update CLK_PER when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CLK_PER { PARAM_VALUE.CLK_PER } {
	# Procedure called to validate CLK_PER
	return true
}

proc update_PARAM_VALUE.INTERVAL { PARAM_VALUE.INTERVAL } {
	# Procedure called to update INTERVAL when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.INTERVAL { PARAM_VALUE.INTERVAL } {
	# Procedure called to validate INTERVAL
	return true
}


proc update_MODELPARAM_VALUE.INTERVAL { MODELPARAM_VALUE.INTERVAL PARAM_VALUE.INTERVAL } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.INTERVAL}] ${MODELPARAM_VALUE.INTERVAL}
}

proc update_MODELPARAM_VALUE.CLK_PER { MODELPARAM_VALUE.CLK_PER PARAM_VALUE.CLK_PER } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CLK_PER}] ${MODELPARAM_VALUE.CLK_PER}
}

