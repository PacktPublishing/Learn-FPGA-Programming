// (c) Copyright 1995-2013 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
//
// DO NOT MODIFY THIS FILE.
`timescale 1ns / 1ps
module vio_twm_ddrx (
clk,
probe_in0,probe_in1,probe_in2,probe_in3,probe_in4,probe_in5,probe_in6,probe_in7,probe_in8,probe_in9,probe_in10,probe_in11,probe_in12,probe_in13,probe_in14,probe_in15,
probe_out0,
probe_out1,
probe_out2,
probe_out3,
probe_out4,
probe_out5,
probe_out6,
probe_out7,
probe_out8,
probe_out9,
probe_out10,
probe_out11,
probe_out12,
probe_out13,
probe_out14,
probe_out15,
probe_out16,
probe_out17,
probe_out18,
probe_out19,
probe_out20,
probe_out21,
probe_out22,
probe_out23,
probe_out24,
probe_out25,
probe_out26
);

input clk;
input [0 : 0] probe_in0;
input [5 : 0] probe_in1;
input [5 : 0] probe_in2;
input [5 : 0] probe_in3;
input [0 : 0] probe_in4;
input [164 : 0] probe_in5;
input [6 : 0] probe_in6;
input [3 : 0] probe_in7;
input [6 : 0] probe_in8;
input [8 : 0] probe_in9;
input [8 : 0] probe_in10;
input [8 : 0] probe_in11;
input [0 : 0] probe_in12;
input [0 : 0] probe_in13;
input [47 : 0] probe_in14;
input [47 : 0] probe_in15;

output reg [8 : 0] probe_out0 = 'h000 ;
output reg [4 : 0] probe_out1 = 'h00 ;
output reg [0 : 0] probe_out2 = 'h0 ;
output reg [3 : 0] probe_out3 = 'h0 ;
output reg [2 : 0] probe_out4 = 'h0 ;
output reg [3 : 0] probe_out5 = 'h0 ;
output reg [1 : 0] probe_out6 = 'h0 ;
output reg [9 : 0] probe_out7 = 'h000 ;
output reg [0 : 0] probe_out8 = 'h0 ;
output reg [0 : 0] probe_out9 = 'h0 ;
output reg [2 : 0] probe_out10 = 'h0 ;
output reg [0 : 0] probe_out11 = 'h0 ;
output reg [0 : 0] probe_out12 = 'h0 ;
output reg [0 : 0] probe_out13 = 'h0 ;
output reg [0 : 0] probe_out14 = 'h0 ;
output reg [0 : 0] probe_out15 = 'h0 ;
output reg [0 : 0] probe_out16 = 'h0 ;
output reg [0 : 0] probe_out17 = 'h0 ;
output reg [0 : 0] probe_out18 = 'h0 ;
output reg [0 : 0] probe_out19 = 'h0 ;
output reg [0 : 0] probe_out20 = 'h0 ;
output reg [0 : 0] probe_out21 = 'h0 ;
output reg [0 : 0] probe_out22 = 'h0 ;
output reg [0 : 0] probe_out23 = 'h0 ;
output reg [0 : 0] probe_out24 = 'h0 ;
output reg [3 : 0] probe_out25 = 'h0 ;
output reg [1 : 0] probe_out26 = 'h0 ;


endmodule
