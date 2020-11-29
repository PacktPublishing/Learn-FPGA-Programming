//Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2020.1 (lin64) Build 2902540 Wed May 27 19:54:35 MDT 2020
//Date        : Fri Oct 30 21:36:38 2020
//Host        : XilinxDev running 64-bit Ubuntu 20.04.1 LTS
//Command     : generate_target design_1.bd
//Design      : design_1
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "design_1,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=design_1,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=12,numReposBlks=12,numNonXlnxBlks=3,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,da_board_cnt=2,da_clkrst_cnt=6,synth_mode=Global}" *) (* HW_HANDOFF = "design_1.hwdef" *) 
module design_1
   (LED,
    SW,
    TMP_CT,
    TMP_INT,
    TMP_SCL,
    TMP_SDA,
    anode,
    cathode,
    reset,
    reset_0,
    sys_clock);
  output LED;
  input SW;
  inout TMP_CT;
  inout TMP_INT;
  inout TMP_SCL;
  inout TMP_SDA;
  output [7:0]anode;
  output [7:0]cathode;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.RESET RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.RESET, INSERT_VIP 0, POLARITY ACTIVE_LOW" *) input reset;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.RESET_0 RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.RESET_0, INSERT_VIP 0, POLARITY ACTIVE_LOW" *) input reset_0;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.SYS_CLOCK CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.SYS_CLOCK, CLK_DOMAIN design_1_sys_clock, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.000" *) input sys_clock;

  wire Net;
  wire Net1;
  wire Net2;
  wire Net3;
  wire SW_0_1;
  wire [15:0]adt7420_i2c_0_fix_temp_TDATA;
  wire adt7420_i2c_0_fix_temp_TVALID;
  wire clk_wiz_0_clk_out1;
  wire [31:0]fixed_to_float_M_AXIS_RESULT_TDATA;
  wire fixed_to_float_M_AXIS_RESULT_TVALID;
  wire [15:0]float_to_fixed_M_AXIS_RESULT_TDATA;
  wire float_to_fixed_M_AXIS_RESULT_TVALID;
  wire flt_temp_0_LED;
  wire [31:0]flt_temp_0_addsub_a_TDATA;
  wire flt_temp_0_addsub_a_TVALID;
  wire [31:0]flt_temp_0_addsub_b_TDATA;
  wire flt_temp_0_addsub_b_TVALID;
  wire [7:0]flt_temp_0_addsub_op_TDATA;
  wire flt_temp_0_addsub_op_TVALID;
  wire [31:0]flt_temp_0_fp_temp_TDATA;
  wire flt_temp_0_fp_temp_TVALID;
  wire [31:0]flt_temp_0_fused_a_TDATA;
  wire flt_temp_0_fused_a_TVALID;
  wire [31:0]flt_temp_0_fused_b_TDATA;
  wire flt_temp_0_fused_b_TVALID;
  wire [31:0]flt_temp_0_fused_c_TDATA;
  wire flt_temp_0_fused_c_TVALID;
  wire [31:0]flt_temp_0_mult_a_TDATA;
  wire flt_temp_0_mult_a_TVALID;
  wire [31:0]flt_temp_0_mult_b_TDATA;
  wire flt_temp_0_mult_b_TVALID;
  wire [31:0]flt_temp_0_seven_segment_TDATA;
  wire [7:0]flt_temp_0_seven_segment_TUSER;
  wire flt_temp_0_seven_segment_TVALID;
  (* CONN_BUS_INFO = "fp_addsub_M_AXIS_RESULT xilinx.com:interface:axis:1.0 None TDATA" *) (* DEBUG = "true" *) (* MARK_DEBUG *) wire [31:0]fp_addsub_M_AXIS_RESULT_TDATA;
  (* CONN_BUS_INFO = "fp_addsub_M_AXIS_RESULT xilinx.com:interface:axis:1.0 None TVALID" *) (* DEBUG = "true" *) (* MARK_DEBUG *) wire fp_addsub_M_AXIS_RESULT_TVALID;
  wire [31:0]fp_fused_M_AXIS_RESULT_TDATA;
  wire fp_fused_M_AXIS_RESULT_TVALID;
  wire [31:0]fp_mult_M_AXIS_RESULT_TDATA;
  wire fp_mult_M_AXIS_RESULT_TVALID;
  wire reset_0_1;
  wire reset_1;
  wire [0:0]reset_inv_0_Res;
  wire [0:0]rst_design_1_100M_peripheral_aresetn;
  wire [7:0]seven_segment_0_anode;
  wire [7:0]seven_segment_0_cathode;
  wire sys_clock_1;

  assign LED = flt_temp_0_LED;
  assign SW_0_1 = SW;
  assign anode[7:0] = seven_segment_0_anode;
  assign cathode[7:0] = seven_segment_0_cathode;
  assign reset_0_1 = reset_0;
  assign reset_1 = reset;
  assign sys_clock_1 = sys_clock;
  design_1_adt7420_i2c_0_0 adt7420_i2c_0
       (.TMP_CT(TMP_CT),
        .TMP_INT(TMP_INT),
        .TMP_SCL(TMP_SCL),
        .TMP_SDA(TMP_SDA),
        .clk(clk_wiz_0_clk_out1),
        .fix_temp_tdata(adt7420_i2c_0_fix_temp_TDATA),
        .fix_temp_tvalid(adt7420_i2c_0_fix_temp_TVALID));
  design_1_clk_wiz_0_0 clk_wiz_0
       (.clk_in1(sys_clock_1),
        .clk_out1(clk_wiz_0_clk_out1),
        .reset(reset_inv_0_Res));
  design_1_floating_point_0_0 fixed_to_float
       (.aclk(clk_wiz_0_clk_out1),
        .m_axis_result_tdata(fixed_to_float_M_AXIS_RESULT_TDATA),
        .m_axis_result_tvalid(fixed_to_float_M_AXIS_RESULT_TVALID),
        .s_axis_a_tdata(adt7420_i2c_0_fix_temp_TDATA),
        .s_axis_a_tvalid(adt7420_i2c_0_fix_temp_TVALID));
  design_1_floating_point_0_1 float_to_fixed
       (.aclk(clk_wiz_0_clk_out1),
        .m_axis_result_tdata(float_to_fixed_M_AXIS_RESULT_TDATA),
        .m_axis_result_tvalid(float_to_fixed_M_AXIS_RESULT_TVALID),
        .s_axis_a_tdata(flt_temp_0_fp_temp_TDATA),
        .s_axis_a_tvalid(flt_temp_0_fp_temp_TVALID));
  design_1_flt_temp_0_0 flt_temp_0
       (.LED(flt_temp_0_LED),
        .SW(SW_0_1),
        .addsub_a_tdata(flt_temp_0_addsub_a_TDATA),
        .addsub_a_tvalid(flt_temp_0_addsub_a_TVALID),
        .addsub_b_tdata(flt_temp_0_addsub_b_TDATA),
        .addsub_b_tvalid(flt_temp_0_addsub_b_TVALID),
        .addsub_op_tdata(flt_temp_0_addsub_op_TDATA),
        .addsub_op_tvalid(flt_temp_0_addsub_op_TVALID),
        .addsub_tdata(fp_addsub_M_AXIS_RESULT_TDATA),
        .addsub_tvalid(fp_addsub_M_AXIS_RESULT_TVALID),
        .clk(clk_wiz_0_clk_out1),
        .fix_temp_tdata(fixed_to_float_M_AXIS_RESULT_TDATA),
        .fix_temp_tvalid(fixed_to_float_M_AXIS_RESULT_TVALID),
        .fp_temp_tdata(flt_temp_0_fp_temp_TDATA),
        .fp_temp_tvalid(flt_temp_0_fp_temp_TVALID),
        .fused_a_tdata(flt_temp_0_fused_a_TDATA),
        .fused_a_tvalid(flt_temp_0_fused_a_TVALID),
        .fused_b_tdata(flt_temp_0_fused_b_TDATA),
        .fused_b_tvalid(flt_temp_0_fused_b_TVALID),
        .fused_c_tdata(flt_temp_0_fused_c_TDATA),
        .fused_c_tvalid(flt_temp_0_fused_c_TVALID),
        .fused_tdata(fp_fused_M_AXIS_RESULT_TDATA),
        .fused_tvalid(fp_fused_M_AXIS_RESULT_TVALID),
        .fx_temp_tdata(float_to_fixed_M_AXIS_RESULT_TDATA),
        .fx_temp_tvalid(float_to_fixed_M_AXIS_RESULT_TVALID),
        .mult_a_tdata(flt_temp_0_mult_a_TDATA),
        .mult_a_tvalid(flt_temp_0_mult_a_TVALID),
        .mult_b_tdata(flt_temp_0_mult_b_TDATA),
        .mult_b_tvalid(flt_temp_0_mult_b_TVALID),
        .mult_tdata(fp_mult_M_AXIS_RESULT_TDATA),
        .mult_tvalid(fp_mult_M_AXIS_RESULT_TVALID),
        .seven_segment_tdata(flt_temp_0_seven_segment_TDATA),
        .seven_segment_tuser(flt_temp_0_seven_segment_TUSER),
        .seven_segment_tvalid(flt_temp_0_seven_segment_TVALID));
  design_1_floating_point_0_2 fp_addsub
       (.aclk(clk_wiz_0_clk_out1),
        .m_axis_result_tdata(fp_addsub_M_AXIS_RESULT_TDATA),
        .m_axis_result_tvalid(fp_addsub_M_AXIS_RESULT_TVALID),
        .s_axis_a_tdata(flt_temp_0_addsub_a_TDATA),
        .s_axis_a_tvalid(flt_temp_0_addsub_a_TVALID),
        .s_axis_b_tdata(flt_temp_0_addsub_b_TDATA),
        .s_axis_b_tvalid(flt_temp_0_addsub_b_TVALID),
        .s_axis_operation_tdata(flt_temp_0_addsub_op_TDATA),
        .s_axis_operation_tvalid(flt_temp_0_addsub_op_TVALID));
  design_1_floating_point_0_3 fp_fused
       (.aclk(clk_wiz_0_clk_out1),
        .m_axis_result_tdata(fp_fused_M_AXIS_RESULT_TDATA),
        .m_axis_result_tvalid(fp_fused_M_AXIS_RESULT_TVALID),
        .s_axis_a_tdata(flt_temp_0_fused_a_TDATA),
        .s_axis_a_tvalid(flt_temp_0_fused_a_TVALID),
        .s_axis_b_tdata(flt_temp_0_fused_b_TDATA),
        .s_axis_b_tvalid(flt_temp_0_fused_b_TVALID),
        .s_axis_c_tdata(flt_temp_0_fused_c_TDATA),
        .s_axis_c_tvalid(flt_temp_0_fused_c_TVALID));
  design_1_floating_point_0_4 fp_mult
       (.aclk(clk_wiz_0_clk_out1),
        .m_axis_result_tdata(fp_mult_M_AXIS_RESULT_TDATA),
        .m_axis_result_tvalid(fp_mult_M_AXIS_RESULT_TVALID),
        .s_axis_a_tdata(flt_temp_0_mult_a_TDATA),
        .s_axis_a_tvalid(flt_temp_0_mult_a_TVALID),
        .s_axis_b_tdata(flt_temp_0_mult_b_TDATA),
        .s_axis_b_tvalid(flt_temp_0_mult_b_TVALID));
  design_1_reset_inv_0_0 reset_inv_0
       (.Op1(reset_1),
        .Res(reset_inv_0_Res));
  design_1_rst_design_1_100M_0 rst_design_1_100M
       (.aux_reset_in(1'b1),
        .dcm_locked(1'b1),
        .ext_reset_in(reset_0_1),
        .mb_debug_sys_rst(1'b0),
        .peripheral_aresetn(rst_design_1_100M_peripheral_aresetn),
        .slowest_sync_clk(clk_wiz_0_clk_out1));
  design_1_seven_segment_0_0 seven_segment_0
       (.anode(seven_segment_0_anode),
        .cathode(seven_segment_0_cathode),
        .clk(clk_wiz_0_clk_out1),
        .seven_segment_tdata(flt_temp_0_seven_segment_TDATA),
        .seven_segment_tuser(flt_temp_0_seven_segment_TUSER),
        .seven_segment_tvalid(flt_temp_0_seven_segment_TVALID));
  design_1_system_ila_0_0 system_ila_0
       (.SLOT_0_AXIS_tdata(fp_addsub_M_AXIS_RESULT_TDATA),
        .SLOT_0_AXIS_tlast(1'b0),
        .SLOT_0_AXIS_tvalid(fp_addsub_M_AXIS_RESULT_TVALID),
        .clk(clk_wiz_0_clk_out1),
        .resetn(rst_design_1_100M_peripheral_aresetn));
endmodule
