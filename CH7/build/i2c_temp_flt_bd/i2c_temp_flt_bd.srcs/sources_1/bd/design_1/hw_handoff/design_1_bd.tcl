
################################################################
# This is a generated script based on design: design_1
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2020.1
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source design_1_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7a100tcsg324-1
   set_property BOARD_PART digilentinc.com:nexys4_ddr:part0:1.1 [current_project]
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name design_1

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_gid_msg -ssname BD::TCL -id 2002 -severity "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_gid_msg -ssname BD::TCL -id 2003 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_gid_msg -ssname BD::TCL -id 2005 -severity "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2006 -severity "ERROR" $errMsg}
   return $nRet
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports

  # Create ports
  set LED [ create_bd_port -dir O LED ]
  set SW [ create_bd_port -dir I SW ]
  set TMP_CT [ create_bd_port -dir IO TMP_CT ]
  set TMP_INT [ create_bd_port -dir IO TMP_INT ]
  set TMP_SCL [ create_bd_port -dir IO TMP_SCL ]
  set TMP_SDA [ create_bd_port -dir IO TMP_SDA ]
  set anode [ create_bd_port -dir O -from 7 -to 0 anode ]
  set cathode [ create_bd_port -dir O -from 7 -to 0 cathode ]
  set reset [ create_bd_port -dir I -type rst reset ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_LOW} \
 ] $reset
  set reset_0 [ create_bd_port -dir I -type rst reset_0 ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_LOW} \
 ] $reset_0
  set sys_clock [ create_bd_port -dir I -type clk -freq_hz 100000000 sys_clock ]
  set_property -dict [ list \
   CONFIG.PHASE {0.000} \
 ] $sys_clock

  # Create instance: adt7420_i2c_0, and set properties
  set adt7420_i2c_0 [ create_bd_cell -type ip -vlnv packtpub.com:user:adt7420_i2c:1.0 adt7420_i2c_0 ]

  # Create instance: clk_wiz_0, and set properties
  set clk_wiz_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz_0 ]
  set_property -dict [ list \
   CONFIG.CLK_IN1_BOARD_INTERFACE {sys_clock} \
   CONFIG.RESET_BOARD_INTERFACE {reset} \
   CONFIG.USE_BOARD_FLOW {true} \
 ] $clk_wiz_0

  # Create instance: fixed_to_float, and set properties
  set fixed_to_float [ create_bd_cell -type ip -vlnv xilinx.com:ip:floating_point:7.1 fixed_to_float ]
  set_property -dict [ list \
   CONFIG.A_Precision_Type {Custom} \
   CONFIG.C_A_Exponent_Width {12} \
   CONFIG.C_A_Fraction_Width {4} \
   CONFIG.C_Accum_Input_Msb {32} \
   CONFIG.C_Accum_Lsb {-31} \
   CONFIG.C_Accum_Msb {32} \
   CONFIG.C_Latency {6} \
   CONFIG.C_Mult_Usage {No_Usage} \
   CONFIG.C_Rate {1} \
   CONFIG.C_Result_Exponent_Width {8} \
   CONFIG.C_Result_Fraction_Width {24} \
   CONFIG.Flow_Control {NonBlocking} \
   CONFIG.Has_RESULT_TREADY {false} \
   CONFIG.Operation_Type {Fixed_to_float} \
   CONFIG.Result_Precision_Type {Single} \
 ] $fixed_to_float

  # Create instance: float_to_fixed, and set properties
  set float_to_fixed [ create_bd_cell -type ip -vlnv xilinx.com:ip:floating_point:7.1 float_to_fixed ]
  set_property -dict [ list \
   CONFIG.C_Latency {6} \
   CONFIG.C_Mult_Usage {No_Usage} \
   CONFIG.C_Rate {1} \
   CONFIG.C_Result_Exponent_Width {12} \
   CONFIG.C_Result_Fraction_Width {4} \
   CONFIG.Flow_Control {NonBlocking} \
   CONFIG.Has_RESULT_TREADY {false} \
   CONFIG.Operation_Type {Float_to_fixed} \
   CONFIG.Result_Precision_Type {Custom} \
 ] $float_to_fixed

  # Create instance: flt_temp_0, and set properties
  set flt_temp_0 [ create_bd_cell -type ip -vlnv user.org:user:flt_temp:1.0 flt_temp_0 ]

  # Create instance: fp_addsub, and set properties
  set fp_addsub [ create_bd_cell -type ip -vlnv xilinx.com:ip:floating_point:7.1 fp_addsub ]
  set_property -dict [ list \
   CONFIG.C_Latency {11} \
   CONFIG.Flow_Control {NonBlocking} \
   CONFIG.Has_RESULT_TREADY {false} \
 ] $fp_addsub

  # Create instance: fp_fused, and set properties
  set fp_fused [ create_bd_cell -type ip -vlnv xilinx.com:ip:floating_point:7.1 fp_fused ]
  set_property -dict [ list \
   CONFIG.Add_Sub_Value {Add} \
   CONFIG.C_Latency {16} \
   CONFIG.C_Mult_Usage {Medium_Usage} \
   CONFIG.C_Rate {1} \
   CONFIG.C_Result_Exponent_Width {8} \
   CONFIG.C_Result_Fraction_Width {24} \
   CONFIG.Flow_Control {NonBlocking} \
   CONFIG.Has_RESULT_TREADY {false} \
   CONFIG.Operation_Type {FMA} \
   CONFIG.Result_Precision_Type {Single} \
 ] $fp_fused

  # Create instance: fp_mult, and set properties
  set fp_mult [ create_bd_cell -type ip -vlnv xilinx.com:ip:floating_point:7.1 fp_mult ]
  set_property -dict [ list \
   CONFIG.Add_Sub_Value {Both} \
   CONFIG.C_Latency {6} \
   CONFIG.C_Mult_Usage {Max_Usage} \
   CONFIG.C_Rate {1} \
   CONFIG.C_Result_Exponent_Width {8} \
   CONFIG.C_Result_Fraction_Width {24} \
   CONFIG.Flow_Control {NonBlocking} \
   CONFIG.Has_RESULT_TREADY {false} \
   CONFIG.Operation_Type {Multiply} \
   CONFIG.Result_Precision_Type {Single} \
 ] $fp_mult

  # Create instance: reset_inv_0, and set properties
  set reset_inv_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 reset_inv_0 ]
  set_property -dict [ list \
   CONFIG.C_OPERATION {not} \
   CONFIG.C_SIZE {1} \
 ] $reset_inv_0

  # Create instance: rst_design_1_100M, and set properties
  set rst_design_1_100M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_design_1_100M ]
  set_property -dict [ list \
   CONFIG.RESET_BOARD_INTERFACE {reset} \
   CONFIG.USE_BOARD_FLOW {true} \
 ] $rst_design_1_100M

  # Create instance: seven_segment_0, and set properties
  set seven_segment_0 [ create_bd_cell -type ip -vlnv user.org:user:seven_segment:1.0 seven_segment_0 ]

  # Create instance: system_ila_0, and set properties
  set system_ila_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:system_ila:1.1 system_ila_0 ]
  set_property -dict [ list \
   CONFIG.C_MON_TYPE {INTERFACE} \
   CONFIG.C_NUM_MONITOR_SLOTS {1} \
   CONFIG.C_SLOT_0_APC_EN {0} \
   CONFIG.C_SLOT_0_AXI_DATA_SEL {1} \
   CONFIG.C_SLOT_0_AXI_TRIG_SEL {1} \
   CONFIG.C_SLOT_0_INTF_TYPE {xilinx.com:interface:axis_rtl:1.0} \
 ] $system_ila_0

  # Create interface connections
  connect_bd_intf_net -intf_net adt7420_i2c_0_fix_temp [get_bd_intf_pins adt7420_i2c_0/fix_temp] [get_bd_intf_pins fixed_to_float/S_AXIS_A]
  connect_bd_intf_net -intf_net fixed_to_float_M_AXIS_RESULT [get_bd_intf_pins fixed_to_float/M_AXIS_RESULT] [get_bd_intf_pins flt_temp_0/fix_temp]
  connect_bd_intf_net -intf_net float_to_fixed_M_AXIS_RESULT [get_bd_intf_pins float_to_fixed/M_AXIS_RESULT] [get_bd_intf_pins flt_temp_0/fx_temp]
  connect_bd_intf_net -intf_net flt_temp_0_addsub_a [get_bd_intf_pins flt_temp_0/addsub_a] [get_bd_intf_pins fp_addsub/S_AXIS_A]
  connect_bd_intf_net -intf_net flt_temp_0_addsub_b [get_bd_intf_pins flt_temp_0/addsub_b] [get_bd_intf_pins fp_addsub/S_AXIS_B]
  connect_bd_intf_net -intf_net flt_temp_0_addsub_op [get_bd_intf_pins flt_temp_0/addsub_op] [get_bd_intf_pins fp_addsub/S_AXIS_OPERATION]
  connect_bd_intf_net -intf_net flt_temp_0_fp_temp [get_bd_intf_pins float_to_fixed/S_AXIS_A] [get_bd_intf_pins flt_temp_0/fp_temp]
  connect_bd_intf_net -intf_net flt_temp_0_fused_a [get_bd_intf_pins flt_temp_0/fused_a] [get_bd_intf_pins fp_fused/S_AXIS_A]
  connect_bd_intf_net -intf_net flt_temp_0_fused_b [get_bd_intf_pins flt_temp_0/fused_b] [get_bd_intf_pins fp_fused/S_AXIS_B]
  connect_bd_intf_net -intf_net flt_temp_0_fused_c [get_bd_intf_pins flt_temp_0/fused_c] [get_bd_intf_pins fp_fused/S_AXIS_C]
  connect_bd_intf_net -intf_net flt_temp_0_mult_a [get_bd_intf_pins flt_temp_0/mult_a] [get_bd_intf_pins fp_mult/S_AXIS_A]
  connect_bd_intf_net -intf_net flt_temp_0_mult_b [get_bd_intf_pins flt_temp_0/mult_b] [get_bd_intf_pins fp_mult/S_AXIS_B]
  connect_bd_intf_net -intf_net flt_temp_0_seven_segment [get_bd_intf_pins flt_temp_0/seven_segment] [get_bd_intf_pins seven_segment_0/seven_segment]
  connect_bd_intf_net -intf_net fp_addsub_M_AXIS_RESULT [get_bd_intf_pins flt_temp_0/addsub] [get_bd_intf_pins fp_addsub/M_AXIS_RESULT]
connect_bd_intf_net -intf_net [get_bd_intf_nets fp_addsub_M_AXIS_RESULT] [get_bd_intf_pins fp_addsub/M_AXIS_RESULT] [get_bd_intf_pins system_ila_0/SLOT_0_AXIS]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_intf_nets fp_addsub_M_AXIS_RESULT]
  connect_bd_intf_net -intf_net fp_fused_M_AXIS_RESULT [get_bd_intf_pins flt_temp_0/fused] [get_bd_intf_pins fp_fused/M_AXIS_RESULT]
  connect_bd_intf_net -intf_net fp_mult_M_AXIS_RESULT [get_bd_intf_pins flt_temp_0/mult] [get_bd_intf_pins fp_mult/M_AXIS_RESULT]

  # Create port connections
  connect_bd_net -net Net [get_bd_ports TMP_SCL] [get_bd_pins adt7420_i2c_0/TMP_SCL]
  connect_bd_net -net Net1 [get_bd_ports TMP_SDA] [get_bd_pins adt7420_i2c_0/TMP_SDA]
  connect_bd_net -net Net2 [get_bd_ports TMP_INT] [get_bd_pins adt7420_i2c_0/TMP_INT]
  connect_bd_net -net Net3 [get_bd_ports TMP_CT] [get_bd_pins adt7420_i2c_0/TMP_CT]
  connect_bd_net -net SW_0_1 [get_bd_ports SW] [get_bd_pins flt_temp_0/SW]
  connect_bd_net -net clk_wiz_0_clk_out1 [get_bd_pins adt7420_i2c_0/clk] [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins fixed_to_float/aclk] [get_bd_pins float_to_fixed/aclk] [get_bd_pins flt_temp_0/clk] [get_bd_pins fp_addsub/aclk] [get_bd_pins fp_fused/aclk] [get_bd_pins fp_mult/aclk] [get_bd_pins rst_design_1_100M/slowest_sync_clk] [get_bd_pins seven_segment_0/clk] [get_bd_pins system_ila_0/clk]
  connect_bd_net -net flt_temp_0_LED [get_bd_ports LED] [get_bd_pins flt_temp_0/LED]
  connect_bd_net -net reset_0_1 [get_bd_ports reset_0] [get_bd_pins rst_design_1_100M/ext_reset_in]
  connect_bd_net -net reset_1 [get_bd_ports reset] [get_bd_pins reset_inv_0/Op1]
  connect_bd_net -net reset_inv_0_Res [get_bd_pins clk_wiz_0/reset] [get_bd_pins reset_inv_0/Res]
  connect_bd_net -net rst_design_1_100M_peripheral_aresetn [get_bd_pins rst_design_1_100M/peripheral_aresetn] [get_bd_pins system_ila_0/resetn]
  connect_bd_net -net seven_segment_0_anode [get_bd_ports anode] [get_bd_pins seven_segment_0/anode]
  connect_bd_net -net seven_segment_0_cathode [get_bd_ports cathode] [get_bd_pins seven_segment_0/cathode]
  connect_bd_net -net sys_clock_1 [get_bd_ports sys_clock] [get_bd_pins clk_wiz_0/clk_in1]

  # Create address segments


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


