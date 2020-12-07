// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.1 (lin64) Build 2902540 Wed May 27 19:54:35 MDT 2020
// Date        : Sun Dec  6 20:26:50 2020
// Host        : XilinxDev running 64-bit Ubuntu 20.04.1 LTS
// Command     : write_verilog -force -mode synth_stub
//               /home/fbruno/git/books/Learn-FPGA-Programming/CH8/build/ddr2_example_board/ddr2_controller_ex/ddr2_controller_ex.srcs/sources_1/ip/vio_twm_ddrx/vio_twm_ddrx_stub.v
// Design      : vio_twm_ddrx
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "vio,Vivado 2020.1" *)
module vio_twm_ddrx(clk, probe_in0, probe_in1, probe_in2, probe_in3, 
  probe_in4, probe_in5, probe_in6, probe_in7, probe_in8, probe_in9, probe_in10, probe_in11, 
  probe_in12, probe_in13, probe_in14, probe_in15, probe_out0, probe_out1, probe_out2, probe_out3, 
  probe_out4, probe_out5, probe_out6, probe_out7, probe_out8, probe_out9, probe_out10, 
  probe_out11, probe_out12, probe_out13, probe_out14, probe_out15, probe_out16, probe_out17, 
  probe_out18, probe_out19, probe_out20, probe_out21, probe_out22, probe_out23, probe_out24, 
  probe_out25, probe_out26)
/* synthesis syn_black_box black_box_pad_pin="clk,probe_in0[0:0],probe_in1[5:0],probe_in2[5:0],probe_in3[5:0],probe_in4[0:0],probe_in5[164:0],probe_in6[6:0],probe_in7[3:0],probe_in8[6:0],probe_in9[8:0],probe_in10[8:0],probe_in11[8:0],probe_in12[0:0],probe_in13[0:0],probe_in14[47:0],probe_in15[47:0],probe_out0[8:0],probe_out1[4:0],probe_out2[0:0],probe_out3[3:0],probe_out4[2:0],probe_out5[3:0],probe_out6[1:0],probe_out7[9:0],probe_out8[0:0],probe_out9[0:0],probe_out10[2:0],probe_out11[0:0],probe_out12[0:0],probe_out13[0:0],probe_out14[0:0],probe_out15[0:0],probe_out16[0:0],probe_out17[0:0],probe_out18[0:0],probe_out19[0:0],probe_out20[0:0],probe_out21[0:0],probe_out22[0:0],probe_out23[0:0],probe_out24[0:0],probe_out25[3:0],probe_out26[1:0]" */;
  input clk;
  input [0:0]probe_in0;
  input [5:0]probe_in1;
  input [5:0]probe_in2;
  input [5:0]probe_in3;
  input [0:0]probe_in4;
  input [164:0]probe_in5;
  input [6:0]probe_in6;
  input [3:0]probe_in7;
  input [6:0]probe_in8;
  input [8:0]probe_in9;
  input [8:0]probe_in10;
  input [8:0]probe_in11;
  input [0:0]probe_in12;
  input [0:0]probe_in13;
  input [47:0]probe_in14;
  input [47:0]probe_in15;
  output [8:0]probe_out0;
  output [4:0]probe_out1;
  output [0:0]probe_out2;
  output [3:0]probe_out3;
  output [2:0]probe_out4;
  output [3:0]probe_out5;
  output [1:0]probe_out6;
  output [9:0]probe_out7;
  output [0:0]probe_out8;
  output [0:0]probe_out9;
  output [2:0]probe_out10;
  output [0:0]probe_out11;
  output [0:0]probe_out12;
  output [0:0]probe_out13;
  output [0:0]probe_out14;
  output [0:0]probe_out15;
  output [0:0]probe_out16;
  output [0:0]probe_out17;
  output [0:0]probe_out18;
  output [0:0]probe_out19;
  output [0:0]probe_out20;
  output [0:0]probe_out21;
  output [0:0]probe_out22;
  output [0:0]probe_out23;
  output [0:0]probe_out24;
  output [3:0]probe_out25;
  output [1:0]probe_out26;
endmodule
