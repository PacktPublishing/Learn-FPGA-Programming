// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.1 (lin64) Build 2902540 Wed May 27 19:54:35 MDT 2020
// Date        : Sun Dec  6 20:28:53 2020
// Host        : XilinxDev running 64-bit Ubuntu 20.04.1 LTS
// Command     : write_verilog -force -mode synth_stub
//               /home/fbruno/git/books/Learn-FPGA-Programming/CH8/build/ddr2_example_board/ddr2_controller_ex/ddr2_controller_ex.srcs/sources_1/ip/ila_ddr2_axi/ila_ddr2_axi_stub.v
// Design      : ila_ddr2_axi
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "ila,Vivado 2020.1" *)
module ila_ddr2_axi(clk, trig_out, trig_out_ack, probe0, probe1, 
  probe2, probe3, probe4, probe5, probe6, probe7, probe8, probe9, probe10, probe11, probe12, probe13, 
  probe14, probe15, probe16, probe17, probe18, probe19, probe20, probe21, probe22, probe23, probe24, 
  probe25, probe26, probe27, probe28, probe29, probe30, probe31, probe32, probe33, probe34, probe35, 
  probe36, probe37, probe38, probe39, probe40, probe41, probe42, probe43, probe44, probe45, probe46, 
  probe47, probe48, probe49, probe50, probe51, probe52, probe53, probe54, probe55, probe56, probe57, 
  probe58, probe59, probe60, probe61, probe62, probe63, probe64, probe65, probe66, probe67, probe68, 
  probe69, probe70, probe71, probe72, probe73, probe74, probe75, probe76, probe77, probe78, probe79, 
  probe80, probe81, probe82, probe83, probe84, probe85, probe86, probe87, probe88, probe89, probe90, 
  probe91, probe92, probe93, probe94, probe95, probe96, probe97, probe98, probe99, probe100, probe101, 
  probe102, probe103, probe104, probe105, probe106, probe107, probe108, probe109, probe110, probe111, 
  probe112, probe113, probe114, probe115, probe116, probe117, probe118, probe119, probe120, probe121, 
  probe122, probe123, probe124, probe125, probe126, probe127, probe128, probe129, probe130, probe131, 
  probe132, probe133, probe134, probe135, probe136, probe137, probe138, probe139, probe140, probe141, 
  probe142)
/* synthesis syn_black_box black_box_pad_pin="clk,trig_out,trig_out_ack,probe0[0:0],probe1[0:0],probe2[0:0],probe3[0:0],probe4[0:0],probe5[0:0],probe6[0:0],probe7[0:0],probe8[0:0],probe9[0:0],probe10[1:0],probe11[1:0],probe12[1:0],probe13[0:0],probe14[0:0],probe15[0:0],probe16[0:0],probe17[0:0],probe18[5:0],probe19[0:0],probe20[63:0],probe21[0:0],probe22[0:0],probe23[0:0],probe24[0:0],probe25[0:0],probe26[31:0],probe27[31:0],probe28[4:0],probe29[3:0],probe30[0:0],probe31[0:0],probe32[5:0],probe33[2:0],probe34[3:0],probe35[5:0],probe36[5:0],probe37[5:0],probe38[5:0],probe39[2:0],probe40[0:0],probe41[0:0],probe42[0:0],probe43[3:0],probe44[4:0],probe45[4:0],probe46[0:0],probe47[0:0],probe48[3:0],probe49[53:0],probe50[26:0],probe51[11:0],probe52[11:0],probe53[11:0],probe54[5:0],probe55[3:0],probe56[7:0],probe57[7:0],probe58[7:0],probe59[7:0],probe60[7:0],probe61[7:0],probe62[7:0],probe63[7:0],probe64[0:0],probe65[0:0],probe66[5:0],probe67[5:0],probe68[5:0],probe69[4:0],probe70[11:0],probe71[11:0],probe72[5:0],probe73[5:0],probe74[5:0],probe75[107:0],probe76[107:0],probe77[107:0],probe78[89:0],probe79[47:0],probe80[15:0],probe81[47:0],probe82[15:0],probe83[5:0],probe84[5:0],probe85[0:0],probe86[0:0],probe87[0:0],probe88[0:0],probe89[0:0],probe90[0:0],probe91[4:0],probe92[5:0],probe93[5:0],probe94[2:0],probe95[0:0],probe96[5:0],probe97[2:0],probe98[5:0],probe99[0:0],probe100[0:0],probe101[0:0],probe102[0:0],probe103[0:0],probe104[0:0],probe105[0:0],probe106[0:0],probe107[0:0],probe108[7:0],probe109[7:0],probe110[5:0],probe111[5:0],probe112[7:0],probe113[0:0],probe114[7:0],probe115[5:0],probe116[4:0],probe117[1:0],probe118[0:0],probe119[0:0],probe120[0:0],probe121[0:0],probe122[0:0],probe123[5:0],probe124[5:0],probe125[0:0],probe126[7:0],probe127[7:0],probe128[7:0],probe129[7:0],probe130[7:0],probe131[7:0],probe132[7:0],probe133[7:0],probe134[0:0],probe135[0:0],probe136[0:0],probe137[107:0],probe138[107:0],probe139[107:0],probe140[0:0],probe141[53:0],probe142[5:0]" */;
  input clk;
  output trig_out;
  input trig_out_ack;
  input [0:0]probe0;
  input [0:0]probe1;
  input [0:0]probe2;
  input [0:0]probe3;
  input [0:0]probe4;
  input [0:0]probe5;
  input [0:0]probe6;
  input [0:0]probe7;
  input [0:0]probe8;
  input [0:0]probe9;
  input [1:0]probe10;
  input [1:0]probe11;
  input [1:0]probe12;
  input [0:0]probe13;
  input [0:0]probe14;
  input [0:0]probe15;
  input [0:0]probe16;
  input [0:0]probe17;
  input [5:0]probe18;
  input [0:0]probe19;
  input [63:0]probe20;
  input [0:0]probe21;
  input [0:0]probe22;
  input [0:0]probe23;
  input [0:0]probe24;
  input [0:0]probe25;
  input [31:0]probe26;
  input [31:0]probe27;
  input [4:0]probe28;
  input [3:0]probe29;
  input [0:0]probe30;
  input [0:0]probe31;
  input [5:0]probe32;
  input [2:0]probe33;
  input [3:0]probe34;
  input [5:0]probe35;
  input [5:0]probe36;
  input [5:0]probe37;
  input [5:0]probe38;
  input [2:0]probe39;
  input [0:0]probe40;
  input [0:0]probe41;
  input [0:0]probe42;
  input [3:0]probe43;
  input [4:0]probe44;
  input [4:0]probe45;
  input [0:0]probe46;
  input [0:0]probe47;
  input [3:0]probe48;
  input [53:0]probe49;
  input [26:0]probe50;
  input [11:0]probe51;
  input [11:0]probe52;
  input [11:0]probe53;
  input [5:0]probe54;
  input [3:0]probe55;
  input [7:0]probe56;
  input [7:0]probe57;
  input [7:0]probe58;
  input [7:0]probe59;
  input [7:0]probe60;
  input [7:0]probe61;
  input [7:0]probe62;
  input [7:0]probe63;
  input [0:0]probe64;
  input [0:0]probe65;
  input [5:0]probe66;
  input [5:0]probe67;
  input [5:0]probe68;
  input [4:0]probe69;
  input [11:0]probe70;
  input [11:0]probe71;
  input [5:0]probe72;
  input [5:0]probe73;
  input [5:0]probe74;
  input [107:0]probe75;
  input [107:0]probe76;
  input [107:0]probe77;
  input [89:0]probe78;
  input [47:0]probe79;
  input [15:0]probe80;
  input [47:0]probe81;
  input [15:0]probe82;
  input [5:0]probe83;
  input [5:0]probe84;
  input [0:0]probe85;
  input [0:0]probe86;
  input [0:0]probe87;
  input [0:0]probe88;
  input [0:0]probe89;
  input [0:0]probe90;
  input [4:0]probe91;
  input [5:0]probe92;
  input [5:0]probe93;
  input [2:0]probe94;
  input [0:0]probe95;
  input [5:0]probe96;
  input [2:0]probe97;
  input [5:0]probe98;
  input [0:0]probe99;
  input [0:0]probe100;
  input [0:0]probe101;
  input [0:0]probe102;
  input [0:0]probe103;
  input [0:0]probe104;
  input [0:0]probe105;
  input [0:0]probe106;
  input [0:0]probe107;
  input [7:0]probe108;
  input [7:0]probe109;
  input [5:0]probe110;
  input [5:0]probe111;
  input [7:0]probe112;
  input [0:0]probe113;
  input [7:0]probe114;
  input [5:0]probe115;
  input [4:0]probe116;
  input [1:0]probe117;
  input [0:0]probe118;
  input [0:0]probe119;
  input [0:0]probe120;
  input [0:0]probe121;
  input [0:0]probe122;
  input [5:0]probe123;
  input [5:0]probe124;
  input [0:0]probe125;
  input [7:0]probe126;
  input [7:0]probe127;
  input [7:0]probe128;
  input [7:0]probe129;
  input [7:0]probe130;
  input [7:0]probe131;
  input [7:0]probe132;
  input [7:0]probe133;
  input [0:0]probe134;
  input [0:0]probe135;
  input [0:0]probe136;
  input [107:0]probe137;
  input [107:0]probe138;
  input [107:0]probe139;
  input [0:0]probe140;
  input [53:0]probe141;
  input [5:0]probe142;
endmodule
