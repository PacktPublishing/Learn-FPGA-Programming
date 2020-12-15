// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.1 (lin64) Build 2902540 Wed May 27 19:54:35 MDT 2020
// Date        : Wed Oct 14 19:12:04 2020
// Host        : XilinxDev running 64-bit Ubuntu 20.04.1 LTS
// Command     : write_verilog -force ./outputs/logic_ex_post.v
// Design      : logic_ex
// Purpose     : This is a Verilog netlist of the current design or from a specific cell of the design. The output is an
//               IEEE 1364-2001 compliant Verilog HDL file that contains netlist information obtained from the input
//               design files.
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* ECO_CHECKSUM = "6eb68c0" *) 
(* STRUCTURAL_NETLIST = "yes" *)
module logic_ex
   (SW,
    LED);
  input [1:0]SW;
  output [3:0]LED;

  wire [3:0]LED;
  wire [3:0]LED_OBUF;
  wire [1:0]SW;
  wire [1:0]SW_IBUF;

  OBUF \LED_OBUF[0]_inst 
       (.I(LED_OBUF[0]),
        .O(LED[0]));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT1 #(
    .INIT(2'h1)) 
    \LED_OBUF[0]_inst_i_1 
       (.I0(SW_IBUF[0]),
        .O(LED_OBUF[0]));
  OBUF \LED_OBUF[1]_inst 
       (.I(LED_OBUF[1]),
        .O(LED[1]));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \LED_OBUF[1]_inst_i_1 
       (.I0(SW_IBUF[1]),
        .I1(SW_IBUF[0]),
        .O(LED_OBUF[1]));
  OBUF \LED_OBUF[2]_inst 
       (.I(LED_OBUF[2]),
        .O(LED[2]));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT2 #(
    .INIT(4'hE)) 
    \LED_OBUF[2]_inst_i_1 
       (.I0(SW_IBUF[1]),
        .I1(SW_IBUF[0]),
        .O(LED_OBUF[2]));
  OBUF \LED_OBUF[3]_inst 
       (.I(LED_OBUF[3]),
        .O(LED[3]));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT2 #(
    .INIT(4'h6)) 
    \LED_OBUF[3]_inst_i_1 
       (.I0(SW_IBUF[0]),
        .I1(SW_IBUF[1]),
        .O(LED_OBUF[3]));
  IBUF \SW_IBUF[0]_inst 
       (.I(SW[0]),
        .O(SW_IBUF[0]));
  IBUF \SW_IBUF[1]_inst 
       (.I(SW[1]),
        .O(SW_IBUF[1]));
endmodule
