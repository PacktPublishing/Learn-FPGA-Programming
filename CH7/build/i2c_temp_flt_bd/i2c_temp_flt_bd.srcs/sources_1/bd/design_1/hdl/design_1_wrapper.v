//Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2020.1 (lin64) Build 2902540 Wed May 27 19:54:35 MDT 2020
//Date        : Fri Oct 30 21:36:38 2020
//Host        : XilinxDev running 64-bit Ubuntu 20.04.1 LTS
//Command     : generate_target design_1_wrapper.bd
//Design      : design_1_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module design_1_wrapper
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
  input reset;
  input reset_0;
  input sys_clock;

  wire LED;
  wire SW;
  wire TMP_CT;
  wire TMP_INT;
  wire TMP_SCL;
  wire TMP_SDA;
  wire [7:0]anode;
  wire [7:0]cathode;
  wire reset;
  wire reset_0;
  wire sys_clock;

  design_1 design_1_i
       (.LED(LED),
        .SW(SW),
        .TMP_CT(TMP_CT),
        .TMP_INT(TMP_INT),
        .TMP_SCL(TMP_SCL),
        .TMP_SDA(TMP_SDA),
        .anode(anode),
        .cathode(cathode),
        .reset(reset),
        .reset_0(reset_0),
        .sys_clock(sys_clock));
endmodule
