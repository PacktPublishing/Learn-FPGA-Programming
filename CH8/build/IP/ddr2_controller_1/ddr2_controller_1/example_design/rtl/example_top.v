//*****************************************************************************
// (c) Copyright 2009 - 2011 Xilinx, Inc. All rights reserved.
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
//*****************************************************************************
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor             : Xilinx
// \   \   \/     Version            : 4.2
//  \   \         Application        : MIG
//  /   /         Filename           : example_top.v
// /___/   /\     Date Last Modified : $Date: 2011/06/02 08:35:03 $
// \   \  /  \    Date Created       : Fri Oct 14 2011
//  \___\/\___\
//
// Device           : 7 Series
// Design Name      : DDR2 SDRAM
// Purpose          :
//   Top-level  module. This module serves as an example,
//   and allows the user to synthesize a self-contained design,
//   which they can be used to test their hardware.
//   In addition to the memory controller, the module instantiates:
//     1. Synthesizable testbench - used to model user's backend logic
//        and generate different traffic patterns
// Reference        :
// Revision History :
//*****************************************************************************

`timescale 1ps/1ps

module example_top #
  (

   //***************************************************************************
   // Traffic Gen related parameters
   //***************************************************************************
   parameter BEGIN_ADDRESS         = 32'h00000000,
   parameter END_ADDRESS           = 32'h00ffffff,
   parameter PRBS_EADDR_MASK_POS   = 32'hff000000,
   parameter ENFORCE_RD_WR         = 0,
   parameter ENFORCE_RD_WR_CMD     = 8'h11,
   parameter ENFORCE_RD_WR_PATTERN = 3'b000,
   parameter C_EN_WRAP_TRANS       = 0,
   parameter C_AXI_NBURST_TEST     = 0,

   //***************************************************************************
   // The following parameters refer to width of various ports
   //***************************************************************************
   parameter BANK_WIDTH            = 3,
                                     // # of memory Bank Address bits.
   parameter COL_WIDTH             = 10,
                                     // # of memory Column Address bits.
   parameter CS_WIDTH              = 1,
                                     // # of unique CS outputs to memory.
   parameter DQ_WIDTH              = 16,
                                     // # of DQ (data)
   parameter DQS_WIDTH             = 2,
   parameter DQS_CNT_WIDTH         = 1,
                                     // = ceil(log2(DQS_WIDTH))
   parameter DRAM_WIDTH            = 8,
                                     // # of DQ per DQS
   parameter ECC                   = "OFF",
   parameter ECC_TEST              = "OFF",
   //parameter nBANK_MACHS           = 4,
   parameter nBANK_MACHS           = 8,
   parameter RANKS                 = 1,
                                     // # of Ranks.
   parameter ROW_WIDTH             = 13,
                                     // # of memory Row Address bits.
   parameter ADDR_WIDTH            = 27,
                                     // # = RANK_WIDTH + BANK_WIDTH
                                     //     + ROW_WIDTH + COL_WIDTH;
                                     // Chip Select is always tied to low for
                                     // single rank devices

   //***************************************************************************
   // The following parameters are mode register settings
   //***************************************************************************
   parameter BURST_MODE            = "8",
                                     // DDR3 SDRAM:
                                     // Burst Length (Mode Register 0).
                                     // # = "8", "4", "OTF".
                                     // DDR2 SDRAM:
                                     // Burst Length (Mode Register).
                                     // # = "8", "4".

   //***************************************************************************
   // Simulation parameters
   //***************************************************************************
   parameter SIMULATION            = "FALSE",
                                     // Should be TRUE during design simulations and
                                     // FALSE during implementations

   //***************************************************************************
   // IODELAY and PHY related parameters
   //***************************************************************************
   parameter TCQ                   = 100,
   


   
   //***************************************************************************
   // System clock frequency parameters
   //***************************************************************************
   parameter nCK_PER_CLK           = 4,
                                     // # of memory CKs per fabric CLK

   
   //***************************************************************************
   // AXI4 Shim parameters
   //***************************************************************************
   
   parameter UI_EXTRA_CLOCKS = "FALSE",
                                     // Generates extra clocks as
                                     // 1/2, 1/4 and 1/8 of fabrick clock.
                                     // Valid for DDR2/DDR3 AXI interfaces
                                     // based on GUI selection
   parameter C_S_AXI_ID_WIDTH              = 4,
                                             // Width of all master and slave ID signals.
                                             // # = >= 1.
   parameter C_S_AXI_ADDR_WIDTH            = 27,
                                             // Width of S_AXI_AWADDR, S_AXI_ARADDR, M_AXI_AWADDR and
                                             // M_AXI_ARADDR for all SI/MI slots.
                                             // # = 32.
   parameter C_S_AXI_DATA_WIDTH            = 128,
                                             // Width of WDATA and RDATA on SI slot.
                                             // Must be <= APP_DATA_WIDTH.
                                             // # = 32, 64, 128, 256.
   parameter C_S_AXI_SUPPORTS_NARROW_BURST = 0,
                                             // Indicates whether to instatiate upsizer
                                             // Range: 0, 1
   parameter C_S_AXI_CTRL_ADDR_WIDTH       = 32,
                                             // Width of AXI-4-Lite address bus
   parameter C_S_AXI_CTRL_DATA_WIDTH       = 32,
                                             // Width of AXI-4-Lite data buses
      

   //***************************************************************************
   // Debug parameters
   //***************************************************************************
   parameter DEBUG_PORT            = "ON"
                                     // # = "ON" Enable debug signals/controls.
                                     //   = "OFF" Disable debug signals/controls.
      
//   parameter RST_ACT_LOW           = 0
                                     // =1 for active low reset,
                                     // =0 for active high.
   )
  (

   // Inouts
   inout [15:0]                         ddr2_dq,
   inout [1:0]                        ddr2_dqs_n,
   inout [1:0]                        ddr2_dqs_p,

   // Outputs
   output [12:0]                       ddr2_addr,
   output [2:0]                      ddr2_ba,
   output                                       ddr2_ras_n,
   output                                       ddr2_cas_n,
   output                                       ddr2_we_n,
   
   output [0:0]                        ddr2_ck_p,
   output [0:0]                        ddr2_ck_n,
   output [0:0]                       ddr2_cke,
   output [0:0]           ddr2_cs_n,
   
   output [1:0]                        ddr2_dm,
   
   output [0:0]                       ddr2_odt,
   

   // Inputs
   // Single-ended system clock
   input                                        sys_clk_i,
   // Single-ended iodelayctrl clk (reference clock)
   input                                        clk_ref_i,
   
   output                                       tg_compare_error,
   output                                       init_calib_complete,
   
      

   // System reset - Default polarity of sys_rst pin is Active Low.
   // System reset polarity will change based on the option 
   // selected in GUI.
   input                                        sys_rst
   );

function integer clogb2 (input integer size);
    begin
      size = size - 1;
      for (clogb2=1; size>1; clogb2=clogb2+1)
        size = size >> 1;
    end
  endfunction // clogb2

  function integer STR_TO_INT;
    input [7:0] in;
    begin
      if(in == "8")
        STR_TO_INT = 8;
      else if(in == "4")
        STR_TO_INT = 4;
      else
        STR_TO_INT = 0;
    end
  endfunction


  localparam DATA_WIDTH            = 16;
  localparam RANK_WIDTH = clogb2(RANKS);
  localparam PAYLOAD_WIDTH         = (ECC_TEST == "OFF") ? DATA_WIDTH : DQ_WIDTH;
  localparam BURST_LENGTH          = STR_TO_INT(BURST_MODE);
  localparam APP_DATA_WIDTH        = 2 * nCK_PER_CLK * PAYLOAD_WIDTH;
  localparam APP_MASK_WIDTH        = APP_DATA_WIDTH / 8;

  //***************************************************************************
  // Traffic Gen related parameters (derived)
  //***************************************************************************
  localparam  TG_ADDR_WIDTH = ((CS_WIDTH == 1) ? 0 : RANK_WIDTH)
                                 + BANK_WIDTH + ROW_WIDTH + COL_WIDTH;
  localparam MASK_SIZE             = DATA_WIDTH/8;
  localparam DBG_WR_STS_WIDTH      = 40;
  localparam DBG_RD_STS_WIDTH      = 40;
      

  // Wire declarations
      
  wire                              clk;
  wire                              rst;
  wire                              mmcm_locked;
  reg                               aresetn;
  wire                              app_sr_active;
  wire                              app_ref_ack;
  wire                              app_zq_ack;
  wire                              app_rd_data_valid;
  wire [APP_DATA_WIDTH-1:0]         app_rd_data;

  wire                              mem_pattern_init_done;

  wire                              cmd_err;
  wire                              data_msmatch_err;
  wire                              write_err;
  wire                              read_err;
  wire                              test_cmptd;
  wire                              write_cmptd;
  wire                              read_cmptd;
  wire                              cmptd_one_wr_rd;

  // Slave Interface Write Address Ports
  wire [C_S_AXI_ID_WIDTH-1:0]       s_axi_awid;
  wire [C_S_AXI_ADDR_WIDTH-1:0]     s_axi_awaddr;
  wire [7:0]                        s_axi_awlen;
  wire [2:0]                        s_axi_awsize;
  wire [1:0]                        s_axi_awburst;
  wire [0:0]                        s_axi_awlock;
  wire [3:0]                        s_axi_awcache;
  wire [2:0]                        s_axi_awprot;
  wire                              s_axi_awvalid;
  wire                              s_axi_awready;
   // Slave Interface Write Data Ports
  wire [C_S_AXI_DATA_WIDTH-1:0]     s_axi_wdata;
  wire [(C_S_AXI_DATA_WIDTH/8)-1:0]   s_axi_wstrb;
  wire                              s_axi_wlast;
  wire                              s_axi_wvalid;
  wire                              s_axi_wready;
   // Slave Interface Write Response Ports
  wire                              s_axi_bready;
  wire [C_S_AXI_ID_WIDTH-1:0]       s_axi_bid;
  wire [1:0]                        s_axi_bresp;
  wire                              s_axi_bvalid;
   // Slave Interface Read Address Ports
  wire [C_S_AXI_ID_WIDTH-1:0]       s_axi_arid;
  wire [C_S_AXI_ADDR_WIDTH-1:0]     s_axi_araddr;
  wire [7:0]                        s_axi_arlen;
  wire [2:0]                        s_axi_arsize;
  wire [1:0]                        s_axi_arburst;
  wire [0:0]                        s_axi_arlock;
  wire [3:0]                        s_axi_arcache;
  wire [2:0]                        s_axi_arprot;
  wire                              s_axi_arvalid;
  wire                              s_axi_arready;
   // Slave Interface Read Data Ports
  wire                              s_axi_rready;
  wire [C_S_AXI_ID_WIDTH-1:0]       s_axi_rid;
  wire [C_S_AXI_DATA_WIDTH-1:0]     s_axi_rdata;
  wire [1:0]                        s_axi_rresp;
  wire                              s_axi_rlast;
  wire                              s_axi_rvalid;

  wire                              cmp_data_valid;
  wire [C_S_AXI_DATA_WIDTH-1:0]      cmp_data;     // Compare data
  wire [C_S_AXI_DATA_WIDTH-1:0]      rdata_cmp;      // Read data

  wire                              dbg_wr_sts_vld;
  wire [DBG_WR_STS_WIDTH-1:0]       dbg_wr_sts;
  wire                              dbg_rd_sts_vld;
  wire [DBG_RD_STS_WIDTH-1:0]       dbg_rd_sts;
    // Debug port wire declarations

  wire [255:0]                            ddr2_ila_basic_w;
  reg  [255:0]                            ddr2_ila_basic;
  wire [390:0]                            ddr2_ila_wrpath_w;
  reg  [390:0]                            ddr2_ila_wrpath;
  wire [1023:0]                           ddr2_ila_rdpath_w;
  reg  [1023:0]                           ddr2_ila_rdpath;

  // Signals for creating rising edge pulses for VIO outputs
  reg                                     vio_dbg_pi_f_inc_r1;
  reg                                     vio_dbg_pi_f_dec_r1;
  reg                                     vio_dbg_po_f_inc_r1;
  reg                                     vio_dbg_po_f_dec_r1;
  reg                                     vio_win_byte_select_inc_r1;
  reg                                     vio_win_byte_select_dec_r1;

  reg                                     vio_dbg_pi_f_inc_r2;
  reg                                     vio_dbg_pi_f_dec_r2;
  reg                                     vio_dbg_po_f_inc_r2;
  reg                                     vio_dbg_po_f_dec_r2;
  reg                                     vio_win_byte_select_inc_r2;
  reg                                     vio_win_byte_select_dec_r2;

  wire                                    vio_dbg_pi_f_inc_re;
  wire                                    vio_dbg_pi_f_dec_re;
  wire                                    vio_dbg_po_f_inc_re;
  wire                                    vio_dbg_po_f_dec_re;
  wire                                    vio_win_byte_select_inc_re;
  wire                                    vio_win_byte_select_dec_re;

  (* mark_debug = "TRUE" *) wire          dbg_mem_pattern_init_done;
  (* mark_debug = "TRUE" *) wire          dbg_tg_compare_error;
  (* mark_debug = "TRUE" *) wire [47:0]   dbg_tg_wr_data_counts;
  (* mark_debug = "TRUE" *) wire [47:0]   dbg_tg_rd_data_counts;

  (* mark_debug = "TRUE" *) wire [4:0]    dbg_dqs;
  (* mark_debug = "TRUE" *) wire [8:0]    dbg_bit;

  reg  [7:0]                              dbg_extn_trig_out_ack_r;
  (* mark_debug = "TRUE" *) wire          vio_modify_enable;
  (* mark_debug = "TRUE" *) wire [3:0]    vio_data_mode_value;
  (* mark_debug = "TRUE" *) wire          vio_pause_traffic;
  (* mark_debug = "TRUE" *) wire [2:0]    vio_addr_mode_value;
  (* mark_debug = "TRUE" *) wire [3:0]    vio_instr_mode_value;
  (* mark_debug = "TRUE" *) wire [1:0]    vio_bl_mode_value;
  (* mark_debug = "TRUE" *) wire [9:0]    vio_fixed_bl_value;
  (* mark_debug = "TRUE" *) wire [2:0]    vio_fixed_instr_value;
  (* mark_debug = "TRUE" *) wire          vio_data_mask_gen;
  (* mark_debug = "TRUE" *) wire          vio_tg_rst;
  (* mark_debug = "TRUE" *) wire          vio_dbg_sel_pi_incdec;
  (* mark_debug = "TRUE" *) wire          vio_dbg_pi_f_inc;
  (* mark_debug = "TRUE" *) wire          vio_dbg_pi_f_dec;
  (* mark_debug = "TRUE" *) wire          vio_dbg_sel_po_incdec;
  (* mark_debug = "TRUE" *) wire          vio_dbg_po_f_inc;
  (* mark_debug = "TRUE" *) wire          vio_dbg_po_f_stg23_sel;
  (* mark_debug = "TRUE" *) wire          vio_dbg_po_f_dec;
  (* mark_debug = "TRUE" *) wire          dbg_extn_trig_out;
  (* mark_debug = "TRUE" *) wire          dbg_extn_trig_out_ack;
  (* mark_debug = "TRUE" *) wire          dbg_init_calib_complete;
  (* mark_debug = "TRUE" *) wire          dbg_wrlvl_start;
  (* mark_debug = "TRUE" *) wire          dbg_wrlvl_done;
  (* mark_debug = "TRUE" *) wire          dbg_wrlvl_err;
  (* mark_debug = "TRUE" *) wire          dbg_pi_phaselock_start;
  (* mark_debug = "TRUE" *) wire          dbg_pi_phaselocked_done;
  (* mark_debug = "TRUE" *) wire          dbg_pi_phaselock_err;
  (* mark_debug = "TRUE" *) wire          dbg_pi_dqsfound_start;
  (* mark_debug = "TRUE" *) wire          dbg_pi_dqsfound_done;
  (* mark_debug = "TRUE" *) wire          dbg_pi_dqsfound_err;
  (* mark_debug = "TRUE" *) wire [1:0]    dbg_rdlvl_start;
  (* mark_debug = "TRUE" *) wire [1:0]    dbg_rdlvl_done;
  (* mark_debug = "TRUE" *) wire [1:0]    dbg_rdlvl_err;
  (* mark_debug = "TRUE" *) wire          dbg_oclkdelay_calib_start;
  (* mark_debug = "TRUE" *) wire          dbg_oclkdelay_calib_done;
  (* mark_debug = "TRUE" *) wire          dbg_wrcal_start;
  (* mark_debug = "TRUE" *) wire          dbg_wrcal_done;
  (* mark_debug = "TRUE" *) wire          dbg_wrcal_err;
  (* mark_debug = "TRUE" *) wire [5:0]    dbg_phy_init_5_0;
  (* mark_debug = "TRUE" *) wire          dbg_rddata_valid_r;
  (* mark_debug = "TRUE" *) wire [63:0]   dbg_rddata_r;
  (* mark_debug = "TRUE" *) wire          dbg_fine_adjust_done_r;
  (* mark_debug = "TRUE" *) wire          dbg_cmd_wdt_err_w;
  (* mark_debug = "TRUE" *) wire          dbg_rd_wdt_err_w;
  (* mark_debug = "TRUE" *) wire          dbg_wr_wdt_err_w;
  (* mark_debug = "TRUE" *) wire          dbg_cmp_data_valid;
  (* mark_debug = "TRUE" *) wire          dbg_cmp_error;
  (* mark_debug = "TRUE" *) wire [63:0]   dbg_cmp_data_r;
  (* mark_debug = "TRUE" *) wire [7:0]    dbg_dq_error_bytelane_cmp;
  (* mark_debug = "TRUE" *) wire [7:0]    dbg_cumlative_dq_lane_error;
  (* mark_debug = "TRUE" *) wire [31:0]   dbg_cmp_addr_i;
  (* mark_debug = "TRUE" *) wire [5:0]    dbg_cmp_bl_i;
  (* mark_debug = "TRUE" *) wire          dbg_mcb_cmd_full_i;
  (* mark_debug = "TRUE" *) wire          dbg_mcb_wr_full_i;
  (* mark_debug = "TRUE" *) wire          dbg_mcb_rd_empty_i;
  (* mark_debug = "TRUE" *) wire [1:0]    dbg_ddrx_ila_rdpath_765_764;
  (* mark_debug = "TRUE" *) wire [31:0]   dbg_axi_cmp_data;
  (* mark_debug = "TRUE" *) wire [31:0]   dbg_axi_rdata_cmp;

  // Write path debug signals
  (* mark_debug = "TRUE" *) wire [4:0]    dbg_wl_state_r;
  (* mark_debug = "TRUE" *) wire [3:0]    dbg_dqs_cnt_r;
  (* mark_debug = "TRUE" *) wire          dbg_wl_edge_detect_valid_r;
  (* mark_debug = "TRUE" *) wire          dbg_rd_data_edge_detect_r_by_dqs;
  (* mark_debug = "TRUE" *) wire [5:0]    dbg_wl_po_fine_cnt_by_dqs;
  (* mark_debug = "TRUE" *) wire [2:0]    dbg_wl_po_coarse_cnt_by_dqs;

  (* mark_debug = "TRUE" *) wire [3:0]    dbg_phy_oclkdelay_zfo;
  (* mark_debug = "TRUE" *) wire [5:0]    dbg_ocal_fuzz2oneeighty;
  (* mark_debug = "TRUE" *) wire [5:0]    dbg_ocal_fuzz2zero;
  (* mark_debug = "TRUE" *) wire [5:0]    dbg_ocal_oneeighty2fuzz;
  (* mark_debug = "TRUE" *) wire [5:0]    dbg_ocal_zero2fuzz;
  (* mark_debug = "TRUE" *) wire [2:0]    dbg_ocal_oclkdelay_calib_cnt;
  (* mark_debug = "TRUE" *) wire          dbg_ocal_scan_win_not_found;
  (* mark_debug = "TRUE" *) wire          dbg_ocal_lim_done;
  (* mark_debug = "TRUE" *) wire [5:0]    dbg_ocal_stg3_lim_left;
  (* mark_debug = "TRUE" *) wire [5:0]    dbg_ocal_stg3_lim_right;
  (* mark_debug = "TRUE" *) wire          dbg_ocal_center_calib_start;
  (* mark_debug = "TRUE" *) wire          dbg_ocal_center_calib_done;
  (* mark_debug = "TRUE" *) wire [53:0]   dbg_phy_oclkdelay_cal_taps;
  (* mark_debug = "TRUE" *) wire [5:0]    dbg_ocal_tap_cnt;

  (* mark_debug = "TRUE" *) wire          dbg_wrcal_pat_data_match_r;
  (* mark_debug = "TRUE" *) wire          dbg_wrcal_pat_data_match_valid_r;
  (* mark_debug = "TRUE" *) wire [3:0]    dbg_wrcal_dqs_cnt_r;
  (* mark_debug = "TRUE" *) wire [4:0]    cal2_state_r;
  (* mark_debug = "TRUE" *) wire [4:0]    not_empty_wait_cnt;
  (* mark_debug = "TRUE" *) wire          dbg_early1_data;
  (* mark_debug = "TRUE" *) wire          dbg_early2_data;
  (* mark_debug = "TRUE" *) wire          dbg_early1_data_match_r;
  (* mark_debug = "TRUE" *) wire          dbg_early2_data_match_r;
  (* mark_debug = "TRUE" *) wire          dbg_wcal_sanity_pat_data_match_valid_r;
  (* mark_debug = "TRUE" *) wire          dbg_wcal_sanity_chk_start;
  (* mark_debug = "TRUE" *) wire          dbg_wcal_sanity_chk_done;
  (* mark_debug = "TRUE" *) wire [7:0]    dbg_wcal_mux_rd_rise0_r;
  (* mark_debug = "TRUE" *) wire [7:0]    dbg_wcal_mux_rd_fall0_r;
  (* mark_debug = "TRUE" *) wire [7:0]    dbg_wcal_mux_rd_rise1_r;
  (* mark_debug = "TRUE" *) wire [7:0]    dbg_wcal_mux_rd_fall1_r;
  (* mark_debug = "TRUE" *) wire [7:0]    dbg_wcal_mux_rd_rise2_r;
  (* mark_debug = "TRUE" *) wire [7:0]    dbg_wcal_mux_rd_fall2_r;
  (* mark_debug = "TRUE" *) wire [7:0]    dbg_wcal_mux_rd_rise3_r;
  (* mark_debug = "TRUE" *) wire [7:0]    dbg_wcal_mux_rd_fall3_r;
  (* mark_debug = "TRUE" *) wire [3:0]    dbg_phy_oclkdelay_cal_57_54;
  (* mark_debug = "TRUE" *) wire [26:0]   dbg_phy_wrcal_po_coarse_cnt;
  (* mark_debug = "TRUE" *) wire [53:0]   dbg_phy_wrcal_po_fine_cnt;
  (* mark_debug = "TRUE" *) wire [53:0]   dbg_phy_wrlvl_128_75;
  (* mark_debug = "TRUE" *) wire [26:0]   dbg_phy_wrlvl_155_129;
  // Read path debug signals

  (* mark_debug = "TRUE" *) wire [11:0]   dbg_pi_phase_locked_phy4lanes;
  (* mark_debug = "TRUE" *) wire [11:0]   dbg_pi_dqs_found_lanes_phy4lanes;
  (* mark_debug = "TRUE" *) wire [11:0]   dbg_rd_data_offset;
  (* mark_debug = "TRUE" *) wire [5:0]    dbg_cal1_state_r;
  (* mark_debug = "TRUE" *) wire [3:0]    dbg_cal1_cnt_cpt_r;
  (* mark_debug = "TRUE" *) wire [7:0]    dbg_mux_rd_rise0_r;
  (* mark_debug = "TRUE" *) wire [7:0]    dbg_mux_rd_fall0_r;
  (* mark_debug = "TRUE" *) wire [7:0]    dbg_mux_rd_rise1_r;
  (* mark_debug = "TRUE" *) wire [7:0]    dbg_mux_rd_fall1_r;
  (* mark_debug = "TRUE" *) wire [7:0]    dbg_mux_rd_rise2_r;
  (* mark_debug = "TRUE" *) wire [7:0]    dbg_mux_rd_fall2_r;
  (* mark_debug = "TRUE" *) wire [7:0]    dbg_mux_rd_rise3_r;
  (* mark_debug = "TRUE" *) wire [7:0]    dbg_mux_rd_fall3_r;
  (* mark_debug = "TRUE" *) wire          dbg_rdlvl_pat_data_match_r;
  (* mark_debug = "TRUE" *) wire          dbg_mux_rd_valid_r;
  (* mark_debug = "TRUE" *) wire [5:0]    dbg_cpt_first_edge_cnt_by_dqs;
  (* mark_debug = "TRUE" *) wire [5:0]    dbg_cpt_second_edge_cnt_by_dqs;
  (* mark_debug = "TRUE" *) wire [5:0]    dbg_cpt_tap_cnt_by_dqs;
  (* mark_debug = "TRUE" *) wire [4:0]    dbg_dq_idelay_tap_cnt_by_dqs;
  (* mark_debug = "TRUE" *) wire [11:0]   dbg_dbg_calib_rd_data_offset_1;
  (* mark_debug = "TRUE" *) wire [11:0]   dbg_dbg_calib_rd_data_offset_2;
  (* mark_debug = "TRUE" *) wire [5:0]    dbg_data_offset;
  (* mark_debug = "TRUE" *) wire [5:0]    dbg_data_offset_1;
  (* mark_debug = "TRUE" *) wire [5:0]    dbg_data_offset_2;
  (* mark_debug = "TRUE" *) wire [107:0]  dbg_cpt_first_edge_cnt;
  (* mark_debug = "TRUE" *) wire [107:0]  dbg_cpt_second_edge_cnt;
  (* mark_debug = "TRUE" *) wire [107:0]  dbg_cpt_tap_cnt;
  (* mark_debug = "TRUE" *) wire [89:0]   dbg_dq_idelay_tap_cnt;

                            wire [254:0]  dbg_prbs_rdlvl;

  (* mark_debug = "TRUE" *) wire [ 47:0]  dbg_prbs_rdlvl_left_edge_pb;
  (* mark_debug = "TRUE" *) wire [ 15:0]  dbg_prbs_rdlvl_left_loss_pb;
  (* mark_debug = "TRUE" *) wire [ 47:0]  dbg_prbs_rdlvl_right_edge_pb;
  (* mark_debug = "TRUE" *) wire [ 15:0]  dbg_prbs_rdlvl_right_gain_pb;
  (* mark_debug = "TRUE" *) wire [  5:0]  dbg_prbs_rdlvl_pi_counter_read_val;
  (* mark_debug = "TRUE" *) wire [  5:0]  dbg_prbs_rdlvl_prbs_dqs_tap_cnt_r;
  (* mark_debug = "TRUE" *) wire          dbg_prbs_rdlvl_prbs_found_1st_edge_r;
  (* mark_debug = "TRUE" *) wire          dbg_prbs_rdlvl_prbs_found_2nd_edge_r;
  (* mark_debug = "TRUE" *) wire          dbg_prbs_rdlvl_compare_err;
  (* mark_debug = "TRUE" *) wire          dbg_prbs_rdlvl_phy_if_empty;
  (* mark_debug = "TRUE" *) wire          dbg_prbs_rdlvl_prbs_rdlvl_start;
  (* mark_debug = "TRUE" *) wire          dbg_prbs_rdlvl_prbs_rdlvl_done;
  (* mark_debug = "TRUE" *) wire [  4:0]  dbg_prbs_rdlvl_prbs_dqs_cnt_r;
  (* mark_debug = "TRUE" *) wire [  5:0]  dbg_prbs_rdlvl_left_edge_pb_dqs_cnt;
  (* mark_debug = "TRUE" *) wire [  5:0]  dbg_prbs_rdlvl_right_edge_pb_dqs_cnt;
  (* mark_debug = "TRUE" *) wire [  2:0]  dbg_prbs_rdlvl_rd_victim_sel;
  (* mark_debug = "TRUE" *) wire          dbg_prbs_rdlvl_complex_victim_inc;
  (* mark_debug = "TRUE" *) wire [  5:0]  dbg_prbs_rdlvl_right_gain_pb_dqs_cnt;
  (* mark_debug = "TRUE" *) wire [  2:0]  dbg_prbs_rdlvl_ref_bit;
  (* mark_debug = "TRUE" *) wire [  5:0]  dbg_prbs_rdlvl_prbs_state_r1;
  (* mark_debug = "TRUE" *) wire          dbg_prbs_rdlvl_rd_valid_r2;
  (* mark_debug = "TRUE" *) wire          dbg_prbs_rdlvl_compare_err_r0;
  (* mark_debug = "TRUE" *) wire          dbg_prbs_rdlvl_compare_err_f0;
  (* mark_debug = "TRUE" *) wire          dbg_prbs_rdlvl_compare_err_r1;
  (* mark_debug = "TRUE" *) wire          dbg_prbs_rdlvl_compare_err_f1;
  (* mark_debug = "TRUE" *) wire          dbg_prbs_rdlvl_compare_err_r2;
  (* mark_debug = "TRUE" *) wire          dbg_prbs_rdlvl_compare_err_f2;
  (* mark_debug = "TRUE" *) wire          dbg_prbs_rdlvl_compare_err_r3;
  (* mark_debug = "TRUE" *) wire          dbg_prbs_rdlvl_compare_err_f3;
  (* mark_debug = "TRUE" *) wire [  7:0]  dbg_prbs_rdlvl_left_edge_found_pb;
  (* mark_debug = "TRUE" *) wire [  7:0]  dbg_prbs_rdlvl_right_edge_found_pb;
  (* mark_debug = "TRUE" *) wire [  5:0]  dbg_prbs_rdlvl_largest_left_edge;
  (* mark_debug = "TRUE" *) wire [  5:0]  dbg_prbs_rdlvl_smallest_right_edge;
  (* mark_debug = "TRUE" *) wire [  7:0]  dbg_prbs_rdlvl_fine_delay_incdec_pb;
  (* mark_debug = "TRUE" *) wire          dbg_prbs_rdlvl_fine_delay_sel;
  (* mark_debug = "TRUE" *) wire [  7:0]  dbg_prbs_rdlvl_compare_err_pb_latch_r;
  (* mark_debug = "TRUE" *) wire [  5:0]  dbg_prbs_rdlvl_fine_pi_dec_cnt;
  (* mark_debug = "TRUE" *) wire [  4:0]  dbg_prbs_rdlvl_match_flag_and;
  (* mark_debug = "TRUE" *) wire [  1:0]  dbg_prbs_rdlvl_stage_cnt;
  (* mark_debug = "TRUE" *) wire          dbg_prbs_rdlvl_fine_inc_stage;
  (* mark_debug = "TRUE" *) wire          dbg_prbs_rdlvl_compare_err_pb_and;
  (* mark_debug = "TRUE" *) wire          dbg_prbs_rdlvl_right_edge_found;
  (* mark_debug = "TRUE" *) wire          dbg_prbs_rdlvl_fine_dly_error;

  (* mark_debug = "TRUE" *) wire          win_start;
  (* mark_debug = "TRUE" *) wire          win_sel_pi_pon;
  (* mark_debug = "TRUE" *) wire          vio_win_byte_select_inc;
  (* mark_debug = "TRUE" *) wire          vio_win_byte_select_dec;
  (* mark_debug = "TRUE" *) wire [5:0]    dbg_pi_counter_read_val;
  (* mark_debug = "TRUE" *) wire [8:0]    dbg_po_counter_read_val;
  (* mark_debug = "TRUE" *) wire [107:0]  dbg_prbs_final_dqs_tap_cnt_r;
  (* mark_debug = "TRUE" *) wire [107:0]  dbg_prbs_first_edge_taps;
  (* mark_debug = "TRUE" *) wire [107:0]  dbg_prbs_second_edge_taps;
  (* mark_debug = "TRUE" *) wire [5:0]    pi_win_left_ram_out;
  (* mark_debug = "TRUE" *) wire [5:0]    pi_win_right_ram_out;
  (* mark_debug = "TRUE" *) wire [8:0]    po_win_left_ram_out;
  (* mark_debug = "TRUE" *) wire [8:0]    po_win_right_ram_out;
  (* mark_debug = "TRUE" *) wire          win_clr_error;
  (* mark_debug = "TRUE" *) wire          manual_clear_error;

  (* mark_debug = "TRUE" *) wire          win_active;
  (* mark_debug = "TRUE" *) wire [4:0]    vio_sel_mux_rdd;
  (* mark_debug = "TRUE" *) wire [6:0]    win_current_bit;
  (* mark_debug = "TRUE" *) wire [4:0]    win_current_byte;
  (* mark_debug = "TRUE" *) wire [164:0]  dbg_win_chk;
  wire                                    pi_win_up;
  wire                                    pi_win_down;
  wire                                    po_win_up;
  wire                                    po_stg23_sel;
  wire                                    po_win_down;
  wire                                    po_win_tg_rst;

  reg                                     app_rd_data_valid_r1;
  reg                                     app_rd_data_valid_r2;
  reg                                     app_rd_data_valid_r3;
  (* mark_debug = "TRUE" *) reg [6:0]     win_byte_select;
  reg [(2*nCK_PER_CLK*PAYLOAD_WIDTH)-1:0]    app_rd_data_r1;
  reg [(2*nCK_PER_CLK*PAYLOAD_WIDTH)-1:0]    app_rd_data_r2;
  reg [(2*nCK_PER_CLK*PAYLOAD_WIDTH)-1:0]    app_rd_data_r3;
  reg [DQS_CNT_WIDTH:0]                       dbg_byte_sel_r;
  reg [255:0]                             tg_simple_data;
  (* mark_debug = "TRUE" *) wire [1:0]    vio_tg_simple_data_sel;
  (* mark_debug = "TRUE" *) wire          wdt_en_w;
  wire                                    cmd_wdt_err_w;
  wire                                    wr_wdt_err_w;
  wire                                    rd_wdt_err_w;
  (* mark_debug = "TRUE" *) wire          dbg_clear_error;

//***************************************************************************



  assign tg_compare_error = cmd_err | data_msmatch_err | write_err | read_err;
      
      


      
// Start of User Design top instance
//***************************************************************************
// The User design is instantiated below. The memory interface ports are
// connected to the top-level and the application interface ports are
// connected to the traffic generator module. This provides a reference
// for connecting the memory controller to system.
//***************************************************************************

  ddr2_controller_1 #
    (
//     #parameters_mapping_user_design_top_instance#
//     .RST_ACT_LOW                      (RST_ACT_LOW)
     )
    u_ddr2_controller_1
      (
       
       
// Memory interface ports
       .ddr2_addr                      (ddr2_addr),
       .ddr2_ba                        (ddr2_ba),
       .ddr2_cas_n                     (ddr2_cas_n),
       .ddr2_ck_n                      (ddr2_ck_n),
       .ddr2_ck_p                      (ddr2_ck_p),
       .ddr2_cke                       (ddr2_cke),
       .ddr2_ras_n                     (ddr2_ras_n),
       .ddr2_we_n                      (ddr2_we_n),
       .ddr2_dq                        (ddr2_dq),
       .ddr2_dqs_n                     (ddr2_dqs_n),
       .ddr2_dqs_p                     (ddr2_dqs_p),
       
       .init_calib_complete            (init_calib_complete),
      
       .ddr2_cs_n                      (ddr2_cs_n),
       .ddr2_dm                        (ddr2_dm),
       .ddr2_odt                       (ddr2_odt),
// Application interface ports
       .ui_clk                         (clk),
       .ui_clk_sync_rst                (rst),

       .mmcm_locked                    (mmcm_locked),
       .aresetn                        (aresetn),
       .app_sr_req                     (1'b0),
       .app_ref_req                    (1'b0),
       .app_zq_req                     (1'b0),
       .app_sr_active                  (app_sr_active),
       .app_ref_ack                    (app_ref_ack),
       .app_zq_ack                     (app_zq_ack),

// Slave Interface Write Address Ports
       .s_axi_awid                     (s_axi_awid),
       .s_axi_awaddr                   (s_axi_awaddr),
       .s_axi_awlen                    (s_axi_awlen),
       .s_axi_awsize                   (s_axi_awsize),
       .s_axi_awburst                  (s_axi_awburst),
       .s_axi_awlock                   (s_axi_awlock),
       .s_axi_awcache                  (s_axi_awcache),
       .s_axi_awprot                   (s_axi_awprot),
       .s_axi_awqos                    (4'h0),
       .s_axi_awvalid                  (s_axi_awvalid),
       .s_axi_awready                  (s_axi_awready),
// Slave Interface Write Data Ports
       .s_axi_wdata                    (s_axi_wdata),
       .s_axi_wstrb                    (s_axi_wstrb),
       .s_axi_wlast                    (s_axi_wlast),
       .s_axi_wvalid                   (s_axi_wvalid),
       .s_axi_wready                   (s_axi_wready),
// Slave Interface Write Response Ports
       .s_axi_bid                      (s_axi_bid),
       .s_axi_bresp                    (s_axi_bresp),
       .s_axi_bvalid                   (s_axi_bvalid),
       .s_axi_bready                   (s_axi_bready),
// Slave Interface Read Address Ports
       .s_axi_arid                     (s_axi_arid),
       .s_axi_araddr                   (s_axi_araddr),
       .s_axi_arlen                    (s_axi_arlen),
       .s_axi_arsize                   (s_axi_arsize),
       .s_axi_arburst                  (s_axi_arburst),
       .s_axi_arlock                   (s_axi_arlock),
       .s_axi_arcache                  (s_axi_arcache),
       .s_axi_arprot                   (s_axi_arprot),
       .s_axi_arqos                    (4'h0),
       .s_axi_arvalid                  (s_axi_arvalid),
       .s_axi_arready                  (s_axi_arready),
// Slave Interface Read Data Ports
       .s_axi_rid                      (s_axi_rid),
       .s_axi_rdata                    (s_axi_rdata),
       .s_axi_rresp                    (s_axi_rresp),
       .s_axi_rlast                    (s_axi_rlast),
       .s_axi_rvalid                   (s_axi_rvalid),
       .s_axi_rready                   (s_axi_rready),

      
// Debug Ports
       .ddr2_ila_basic                 (ddr2_ila_basic_w[119:0]),
       .ddr2_ila_wrpath                (ddr2_ila_wrpath_w),
       .ddr2_ila_rdpath                (ddr2_ila_rdpath_w),

       .ddr2_vio_sync_out              ({dbg_dqs,dbg_bit}),

       .dbg_pi_counter_read_val        (dbg_pi_counter_read_val),
       .dbg_sel_pi_incdec              (dbg_sel_pi_incdec),
       .dbg_po_counter_read_val        (dbg_po_counter_read_val),
       .dbg_prbs_final_dqs_tap_cnt_r   (dbg_prbs_final_dqs_tap_cnt_r),
       .dbg_prbs_first_edge_taps       (dbg_prbs_first_edge_taps),
       .dbg_prbs_second_edge_taps      (dbg_prbs_second_edge_taps),
       .dbg_sel_po_incdec              (dbg_sel_po_incdec),
       .dbg_byte_sel                   (dbg_byte_sel_r),
       .dbg_pi_f_inc                   (dbg_pi_f_inc),
       .dbg_pi_f_dec                   (dbg_pi_f_dec),
       .dbg_po_f_inc                   (dbg_po_f_inc),
       .dbg_po_f_stg23_sel             (dbg_po_f_stg23_sel),
       .dbg_po_f_dec                   (dbg_po_f_dec),
       
// System Clock Ports
       .sys_clk_i                       (sys_clk_i),
// Reference Clock Ports
       .clk_ref_i                      (clk_ref_i),
      
       .sys_rst                        (sys_rst)
       );
// End of User Design top instance


//***************************************************************************
// The traffic generation module instantiated below drives traffic (patterns)
// on the application interface of the memory controller
//***************************************************************************

   always @(posedge clk) begin
     aresetn <= ~rst;
   end

   mig_7series_v4_2_axi4_tg #(

     .C_AXI_ID_WIDTH                   (C_S_AXI_ID_WIDTH),
     .C_AXI_ADDR_WIDTH                 (C_S_AXI_ADDR_WIDTH),
     .C_AXI_DATA_WIDTH                 (C_S_AXI_DATA_WIDTH),
     .C_AXI_NBURST_SUPPORT             (C_AXI_NBURST_TEST),
     .C_EN_WRAP_TRANS                  (C_EN_WRAP_TRANS),
     .C_BEGIN_ADDRESS                  (BEGIN_ADDRESS),
     .C_END_ADDRESS                    (END_ADDRESS),
     .PRBS_EADDR_MASK_POS              (PRBS_EADDR_MASK_POS),
     .DBG_WR_STS_WIDTH                 (DBG_WR_STS_WIDTH),
     .DBG_RD_STS_WIDTH                 (DBG_RD_STS_WIDTH),
     .ENFORCE_RD_WR                    (ENFORCE_RD_WR),
     .ENFORCE_RD_WR_CMD                (ENFORCE_RD_WR_CMD),
     .EN_UPSIZER                       (C_S_AXI_SUPPORTS_NARROW_BURST),
     .ENFORCE_RD_WR_PATTERN            (ENFORCE_RD_WR_PATTERN)

   ) u_axi4_tg_inst
   (
     .aclk                             (clk),
     .aresetn                          (aresetn),

// Input control signals
     .init_cmptd                       (init_calib_complete),
     .init_test                        (1'b0),
     .wdog_mask                        (~init_calib_complete),
     .wrap_en                          (1'b0),

// AXI write address channel signals
     .axi_wready                       (s_axi_awready),
     .axi_wid                          (s_axi_awid),
     .axi_waddr                        (s_axi_awaddr),
     .axi_wlen                         (s_axi_awlen),
     .axi_wsize                        (s_axi_awsize),
     .axi_wburst                       (s_axi_awburst),
     .axi_wlock                        (s_axi_awlock),
     .axi_wcache                       (s_axi_awcache),
     .axi_wprot                        (s_axi_awprot),
     .axi_wvalid                       (s_axi_awvalid),

// AXI write data channel signals
     .axi_wd_wready                    (s_axi_wready),
     .axi_wd_wid                       (s_axi_wid),
     .axi_wd_data                      (s_axi_wdata),
     .axi_wd_strb                      (s_axi_wstrb),
     .axi_wd_last                      (s_axi_wlast),
     .axi_wd_valid                     (s_axi_wvalid),

// AXI write response channel signals
     .axi_wd_bid                       (s_axi_bid),
     .axi_wd_bresp                     (s_axi_bresp),
     .axi_wd_bvalid                    (s_axi_bvalid),
     .axi_wd_bready                    (s_axi_bready),

// AXI read address channel signals
     .axi_rready                       (s_axi_arready),
     .axi_rid                          (s_axi_arid),
     .axi_raddr                        (s_axi_araddr),
     .axi_rlen                         (s_axi_arlen),
     .axi_rsize                        (s_axi_arsize),
     .axi_rburst                       (s_axi_arburst),
     .axi_rlock                        (s_axi_arlock),
     .axi_rcache                       (s_axi_arcache),
     .axi_rprot                        (s_axi_arprot),
     .axi_rvalid                       (s_axi_arvalid),

// AXI read data channel signals
     .axi_rd_bid                       (s_axi_rid),
     .axi_rd_rresp                     (s_axi_rresp),
     .axi_rd_rvalid                    (s_axi_rvalid),
     .axi_rd_data                      (s_axi_rdata),
     .axi_rd_last                      (s_axi_rlast),
     .axi_rd_rready                    (s_axi_rready),

// Error status signals
     .cmd_err                          (cmd_err),
     .data_msmatch_err                 (data_msmatch_err),
     .write_err                        (write_err),
     .read_err                         (read_err),
     .test_cmptd                       (test_cmptd),
     .write_cmptd                      (write_cmptd),
     .read_cmptd                       (read_cmptd),
     .cmptd_one_wr_rd                  (cmptd_one_wr_rd),

// Debug status signals
     .cmp_data_en                      (cmp_data_valid),
     .cmp_data_o                       (cmp_data),
     .rdata_cmp                        (rdata_cmp),
     .dbg_wr_sts_vld                   (dbg_wr_sts_vld),
     .dbg_wr_sts                       (dbg_wr_sts),
     .dbg_rd_sts_vld                   (dbg_rd_sts_vld),
     .dbg_rd_sts                       (dbg_rd_sts)
);

      


 generate
    if (DEBUG_PORT=="ON") begin: CHIPSCOPE_INST


       assign ddr2_ila_basic_w[128]       = tg_compare_error;
       assign ddr2_ila_basic_w[129+:32]   = cmp_data[32*dbg_dqs+:32];
       assign ddr2_ila_basic_w[161+:32]   = rdata_cmp[32*dbg_dqs+:32];
       assign ddr2_ila_basic_w[255:193]   = 'b0;

        vio_twm_ddrx u_vio_twm_ddrx (
            .clk         (clk),
            .probe_in0   (win_start),//1
            .probe_in1   (dbg_pi_counter_read_val),//6
            .probe_in2   (pi_win_left_ram_out),//6
            .probe_in3   (pi_win_right_ram_out),//6
            .probe_in4   (win_active),//1
            .probe_in5   (dbg_win_chk),//165
            .probe_in6   (win_current_bit),//7
            .probe_in7   (win_current_byte[3:0]),//4
            .probe_in8   (win_byte_select),//7
            .probe_in9   (po_win_left_ram_out),//9
            .probe_in10  (po_win_right_ram_out),//9
            .probe_in11  (dbg_po_counter_read_val),//9
            .probe_in12  (dbg_mem_pattern_init_done),//1
            .probe_in13  (dbg_tg_compare_error),//1
            .probe_in14  (dbg_tg_wr_data_counts),//48
            .probe_in15  (dbg_tg_rd_data_counts),//48
            .probe_out0  (dbg_bit),//9
            .probe_out1  (dbg_dqs),//5
            .probe_out2  (vio_modify_enable),//1
            .probe_out3  (vio_data_mode_value),//4
            .probe_out4  (vio_addr_mode_value),//3
            .probe_out5  (vio_instr_mode_value),//4
            .probe_out6  (vio_bl_mode_value),//2
            .probe_out7  (vio_fixed_bl_value),//10
            .probe_out8  (vio_data_mask_gen),//1
            .probe_out9  (vio_pause_traffic),//1
            .probe_out10 (vio_fixed_instr_value),//3
            .probe_out11 (dbg_clear_error),//1
            .probe_out12 (vio_tg_rst),//1
            .probe_out13 (wdt_en_w),//1
            .probe_out14 (win_start),//1
            .probe_out15 (win_sel_pi_pon),//1
            .probe_out16 (vio_dbg_sel_pi_incdec),//1
            .probe_out17 (vio_dbg_sel_po_incdec),//1
            .probe_out18 (vio_dbg_pi_f_inc),//1
            .probe_out19 (vio_dbg_pi_f_dec),//1
            .probe_out20 (vio_dbg_po_f_inc),//1
            .probe_out21 (vio_dbg_po_f_dec),//1
            .probe_out22 (vio_dbg_po_f_stg23_sel),//1
            .probe_out23 (vio_win_byte_select_inc),//1
            .probe_out24 (vio_win_byte_select_dec),//1
            .probe_out25 (vio_sel_mux_rdd[3:0]),//4
            .probe_out26 (vio_tg_simple_data_sel)//2
        );


          always @ (posedge clk)
          begin
            if (rst)
            begin
              ddr2_ila_basic    <= 'b0;
              ddr2_ila_rdpath   <= 'b0;
              ddr2_ila_wrpath   <= 'b0;
            end
            else
            begin
              ddr2_ila_basic    <= ddr2_ila_basic_w;
              ddr2_ila_rdpath   <= ddr2_ila_rdpath_w;
              ddr2_ila_wrpath   <= ddr2_ila_wrpath_w;
            end
          end

       assign dbg_mem_pattern_init_done = mem_pattern_init_done;
       assign dbg_tg_wr_data_counts     = {40'h0, dbg_wr_sts[39:32]};
       assign dbg_tg_rd_data_counts     = {40'h0, dbg_rd_sts[39:32]};

       // Code for creating rising edge pulse for VIO outputs
       always @(posedge clk)
       begin
         vio_dbg_pi_f_inc_r1            <= #TCQ  vio_dbg_pi_f_inc        ;
         vio_dbg_pi_f_dec_r1            <= #TCQ  vio_dbg_pi_f_dec        ;
         vio_dbg_po_f_inc_r1            <= #TCQ  vio_dbg_po_f_inc        ;
         vio_dbg_po_f_dec_r1            <= #TCQ  vio_dbg_po_f_dec        ;
         vio_win_byte_select_inc_r1     <= #TCQ  vio_win_byte_select_inc ;
         vio_win_byte_select_dec_r1     <= #TCQ  vio_win_byte_select_dec ;

         vio_dbg_pi_f_inc_r2            <= #TCQ  vio_dbg_pi_f_inc_r1        ;
         vio_dbg_pi_f_dec_r2            <= #TCQ  vio_dbg_pi_f_dec_r1        ;
         vio_dbg_po_f_inc_r2            <= #TCQ  vio_dbg_po_f_inc_r1        ;
         vio_dbg_po_f_dec_r2            <= #TCQ  vio_dbg_po_f_dec_r1        ;
         vio_win_byte_select_inc_r2     <= #TCQ  vio_win_byte_select_inc_r1 ;
         vio_win_byte_select_dec_r2     <= #TCQ  vio_win_byte_select_dec_r1 ;
       end

       assign vio_dbg_pi_f_inc_re        = vio_dbg_pi_f_inc_r1        & ~vio_dbg_pi_f_inc_r2        ;
       assign vio_dbg_pi_f_dec_re        = vio_dbg_pi_f_dec_r1        & ~vio_dbg_pi_f_dec_r2        ;
       assign vio_dbg_po_f_inc_re        = vio_dbg_po_f_inc_r1        & ~vio_dbg_po_f_inc_r2        ;
       assign vio_dbg_po_f_dec_re        = vio_dbg_po_f_dec_r1        & ~vio_dbg_po_f_dec_r2        ;
       assign vio_win_byte_select_inc_re = vio_win_byte_select_inc_r1 & ~vio_win_byte_select_inc_r2 ;
       assign vio_win_byte_select_dec_re = vio_win_byte_select_dec_r1 & ~vio_win_byte_select_dec_r2 ;

       assign manual_clear_error = (!win_active) ? dbg_clear_error : win_clr_error;
       assign dbg_sel_pi_incdec  = (!win_active) ? vio_dbg_sel_pi_incdec : 1'b1;
       assign dbg_sel_po_incdec  = (!win_active) ? vio_dbg_sel_po_incdec : 1'b1;
       assign dbg_pi_f_inc       = (!win_active) ? vio_dbg_pi_f_inc_re : pi_win_up;
       assign dbg_pi_f_dec       = (!win_active) ? vio_dbg_pi_f_dec_re : pi_win_down;
       assign dbg_po_f_inc       = (!win_active) ? vio_dbg_po_f_inc_re : po_win_up;
       assign dbg_po_f_dec       = (!win_active) ? vio_dbg_po_f_dec_re : po_win_down;
       assign dbg_po_f_stg23_sel = (!win_active) ? vio_dbg_po_f_stg23_sel : po_stg23_sel;

        assign dbg_init_calib_complete          = ddr2_ila_basic[0];
        assign dbg_wrlvl_start                  = ddr2_ila_basic[1];
        assign dbg_wrlvl_done                   = ddr2_ila_basic[2];
        assign dbg_wrlvl_err                    = ddr2_ila_basic[3];
        assign dbg_pi_phaselock_start           = ddr2_ila_basic[4];
        assign dbg_pi_phaselocked_done          = ddr2_ila_basic[5];
        assign dbg_pi_phaselock_err             = ddr2_ila_basic[6];
        assign dbg_pi_dqsfound_start            = ddr2_ila_basic[7];
        assign dbg_pi_dqsfound_done             = ddr2_ila_basic[8];
        assign dbg_pi_dqsfound_err              = ddr2_ila_basic[9];
        assign dbg_rdlvl_start                  = ddr2_ila_basic[11:10];
        assign dbg_rdlvl_done                   = ddr2_ila_basic[13:12];
        assign dbg_rdlvl_err                    = ddr2_ila_basic[15:14];
        assign dbg_oclkdelay_calib_start        = ddr2_ila_basic[16];
        assign dbg_oclkdelay_calib_done         = ddr2_ila_basic[17];
        assign dbg_wrcal_start                  = ddr2_ila_basic[19];
        assign dbg_wrcal_done                   = ddr2_ila_basic[20];
        assign dbg_wrcal_err                    = ddr2_ila_basic[21];
        assign dbg_phy_init_5_0                 = ddr2_ila_basic[27:22];
        assign dbg_rddata_valid_r               = ddr2_ila_basic[28];
        assign dbg_rddata_r                     = ddr2_ila_basic[29+:64];
        assign dbg_fine_adjust_done_r           = ddr2_ila_basic[93];
        assign dbg_cmd_wdt_err_w                = ddr2_ila_basic[125];
        assign dbg_rd_wdt_err_w                 = ddr2_ila_basic[126];
        assign dbg_wr_wdt_err_w                 = ddr2_ila_basic[127];
        assign dbg_tg_compare_error             = ddr2_ila_basic[128];
        assign dbg_axi_cmp_data                 = ddr2_ila_basic[129+:32];
        assign dbg_axi_rdata_cmp                = ddr2_ila_basic[161+:32];

        assign dbg_wl_state_r                   = ddr2_ila_wrpath[0+:5];
        assign dbg_dqs_cnt_r                    = ddr2_ila_wrpath[6+:4];
        assign dbg_wl_edge_detect_valid_r       = ddr2_ila_wrpath[10];
        assign dbg_rd_data_edge_detect_r_by_dqs = ddr2_ila_wrpath[11];
        assign dbg_wl_po_fine_cnt_by_dqs        = ddr2_ila_wrpath[12+:6];
        assign dbg_wl_po_coarse_cnt_by_dqs      = ddr2_ila_wrpath[18+:3];

        assign dbg_phy_oclkdelay_zfo            = ddr2_ila_wrpath[ 30+: 4];   // 4
        assign dbg_ocal_fuzz2oneeighty          = ddr2_ila_wrpath[ 34+: 6];   // 6
        assign dbg_ocal_fuzz2zero               = ddr2_ila_wrpath[ 40+: 6];   // 6
        assign dbg_ocal_oneeighty2fuzz          = ddr2_ila_wrpath[ 46+: 6];   // 6
        assign dbg_ocal_zero2fuzz               = ddr2_ila_wrpath[ 52+: 6];   // 6
        assign dbg_ocal_oclkdelay_calib_cnt     = ddr2_ila_wrpath[ 58+: 3];   // 3
        assign dbg_ocal_scan_win_not_found      = ddr2_ila_wrpath[ 61+: 1];   // 1
        assign dbg_ocal_lim_done                = ddr2_ila_wrpath[ 62+: 1];   // 1
        assign dbg_ocal_stg3_lim_left           = ddr2_ila_wrpath[241+: 6];   // 6
        assign dbg_ocal_stg3_lim_right          = ddr2_ila_wrpath[247+: 6];   // 6
        assign dbg_ocal_center_calib_start      = ddr2_ila_wrpath[253+: 1];   // 1
        assign dbg_ocal_center_calib_done       = ddr2_ila_wrpath[254+: 1];   // 1
        assign dbg_phy_oclkdelay_cal_taps       = ddr2_ila_wrpath[255+:54];   // 54
        assign dbg_ocal_tap_cnt                 = ddr2_ila_wrpath[ 87+: 6];   // 6

        assign dbg_wrcal_pat_data_match_r       = ddr2_ila_wrpath[64];
        assign dbg_wrcal_pat_data_match_valid_r = ddr2_ila_wrpath[65];
        assign dbg_wrcal_dqs_cnt_r              = ddr2_ila_wrpath[66+:4];
        assign cal2_state_r                     = ddr2_ila_wrpath[70+:5];
        assign not_empty_wait_cnt               = ddr2_ila_wrpath[75+:5];
        assign dbg_early1_data                  = ddr2_ila_wrpath[80];
        assign dbg_early2_data                  = ddr2_ila_wrpath[81];
        assign dbg_early1_data_match_r          = ddr2_ila_wrpath[82];
        assign dbg_early2_data_match_r          = ddr2_ila_wrpath[83];
        assign dbg_wcal_sanity_pat_data_match_valid_r = ddr2_ila_wrpath[84];
        assign dbg_wcal_sanity_chk_start        = ddr2_ila_wrpath[85];
        assign dbg_wcal_sanity_chk_done         = ddr2_ila_wrpath[86];
        assign dbg_wcal_mux_rd_rise0_r          = ddr2_ila_wrpath[177+:8];
        assign dbg_wcal_mux_rd_fall0_r          = ddr2_ila_wrpath[185+:8];
        assign dbg_wcal_mux_rd_rise1_r          = ddr2_ila_wrpath[193+:8];
        assign dbg_wcal_mux_rd_fall1_r          = ddr2_ila_wrpath[201+:8];
        assign dbg_wcal_mux_rd_rise2_r          = ddr2_ila_wrpath[209+:8];
        assign dbg_wcal_mux_rd_fall2_r          = ddr2_ila_wrpath[217+:8];
        assign dbg_wcal_mux_rd_rise3_r          = ddr2_ila_wrpath[225+:8];
        assign dbg_wcal_mux_rd_fall3_r          = ddr2_ila_wrpath[233+:8];
        assign dbg_phy_oclkdelay_cal_57_54      = ddr2_ila_wrpath[91:88];
        assign dbg_phy_wrlvl_128_75             = ddr2_ila_wrpath[96+:54];
        assign dbg_phy_wrlvl_155_129            = ddr2_ila_wrpath[150+:27];
        assign dbg_phy_wrcal_po_coarse_cnt      = ddr2_ila_wrpath[336:310]; // 27
        assign dbg_phy_wrcal_po_fine_cnt        = ddr2_ila_wrpath[390:337]; // 54
        assign dbg_pi_phase_locked_phy4lanes    = ddr2_ila_rdpath[0+:12];
        assign dbg_pi_dqs_found_lanes_phy4lanes = ddr2_ila_rdpath[12+:12];
        assign dbg_rd_data_offset               = ddr2_ila_rdpath[24+:12];
        assign dbg_cal1_state_r                 = ddr2_ila_rdpath[40+:6];
        assign dbg_cal1_cnt_cpt_r               = ddr2_ila_rdpath[46+:4];
        assign dbg_mux_rd_rise0_r               = ddr2_ila_rdpath[50+:8];
        assign dbg_mux_rd_fall0_r               = ddr2_ila_rdpath[58+:8];
        assign dbg_mux_rd_rise1_r               = ddr2_ila_rdpath[66+:8];
        assign dbg_mux_rd_fall1_r               = ddr2_ila_rdpath[74+:8];
        assign dbg_mux_rd_rise2_r               = ddr2_ila_rdpath[82+:8];
        assign dbg_mux_rd_fall2_r               = ddr2_ila_rdpath[90+:8];
        assign dbg_mux_rd_rise3_r               = ddr2_ila_rdpath[98+:8];
        assign dbg_mux_rd_fall3_r               = ddr2_ila_rdpath[106+:8];
        assign dbg_rdlvl_pat_data_match_r       = ddr2_ila_rdpath[114];
        assign dbg_mux_rd_valid_r               = ddr2_ila_rdpath[115];
        assign dbg_cpt_first_edge_cnt_by_dqs    = ddr2_ila_rdpath[116+:6];
        assign dbg_cpt_second_edge_cnt_by_dqs   = ddr2_ila_rdpath[122+:6];
        assign dbg_cpt_tap_cnt_by_dqs           = ddr2_ila_rdpath[128+:6];
        assign dbg_dq_idelay_tap_cnt_by_dqs     = ddr2_ila_rdpath[134+:5];
        assign dbg_dbg_calib_rd_data_offset_1   = ddr2_ila_rdpath[164+:12];
        assign dbg_dbg_calib_rd_data_offset_2   = ddr2_ila_rdpath[176+:12];
        assign dbg_data_offset                  = ddr2_ila_rdpath[188+:6];
        assign dbg_data_offset_1                = ddr2_ila_rdpath[194+:6];
        assign dbg_data_offset_2                = ddr2_ila_rdpath[200+:6];
        assign dbg_cpt_first_edge_cnt           = ddr2_ila_rdpath[206+:108];
        assign dbg_cpt_second_edge_cnt          = ddr2_ila_rdpath[314+:108];
        assign dbg_cpt_tap_cnt                  = ddr2_ila_rdpath[422+:108];
        assign dbg_dq_idelay_tap_cnt            = ddr2_ila_rdpath[530+:90];
        assign dbg_prbs_rdlvl                   = ddr2_ila_rdpath[620+:255];

        assign dbg_prbs_rdlvl_left_edge_pb[ 0+:6]       = dbg_prbs_rdlvl [0+:6] ;
        assign dbg_prbs_rdlvl_left_loss_pb[ 0+:2]       = dbg_prbs_rdlvl [7:6]  ;
        assign dbg_prbs_rdlvl_left_edge_pb[ 6+:6]       = dbg_prbs_rdlvl [8+:6] ;
        assign dbg_prbs_rdlvl_left_loss_pb[ 2+:2]       = dbg_prbs_rdlvl [15:14];
        assign dbg_prbs_rdlvl_left_edge_pb[12+:6]       = dbg_prbs_rdlvl [16+:6];
        assign dbg_prbs_rdlvl_left_loss_pb[ 4+:2]       = dbg_prbs_rdlvl [23:22];
        assign dbg_prbs_rdlvl_left_edge_pb[18+:6]       = dbg_prbs_rdlvl [24+:6];
        assign dbg_prbs_rdlvl_left_loss_pb[ 6+:2]       = dbg_prbs_rdlvl [31:30];
        assign dbg_prbs_rdlvl_left_edge_pb[24+:6]       = dbg_prbs_rdlvl [32+:6];
        assign dbg_prbs_rdlvl_left_loss_pb[ 8+:2]       = dbg_prbs_rdlvl [39:38];
        assign dbg_prbs_rdlvl_left_edge_pb[30+:6]       = dbg_prbs_rdlvl [40+:6];
        assign dbg_prbs_rdlvl_left_loss_pb[10+:2]       = dbg_prbs_rdlvl [47:46];
        assign dbg_prbs_rdlvl_left_edge_pb[36+:6]       = dbg_prbs_rdlvl [48+:6];
        assign dbg_prbs_rdlvl_left_loss_pb[12+:2]       = dbg_prbs_rdlvl [55:54];
        assign dbg_prbs_rdlvl_left_edge_pb[42+:6]       = dbg_prbs_rdlvl [56+:6];
        assign dbg_prbs_rdlvl_left_loss_pb[14+:2]       = dbg_prbs_rdlvl [63:62];
        assign dbg_prbs_rdlvl_right_edge_pb[ 0+:6]      = dbg_prbs_rdlvl [64+:6]  ;
        assign dbg_prbs_rdlvl_right_gain_pb[ 0+:2]      = dbg_prbs_rdlvl [71:70]  ;
        assign dbg_prbs_rdlvl_right_edge_pb[ 6+:6]      = dbg_prbs_rdlvl [72+:6]  ;
        assign dbg_prbs_rdlvl_right_gain_pb[ 2+:2]      = dbg_prbs_rdlvl [79:78]  ;
        assign dbg_prbs_rdlvl_right_edge_pb[12+:6]      = dbg_prbs_rdlvl [80+:6]  ;
        assign dbg_prbs_rdlvl_right_gain_pb[ 4+:2]      = dbg_prbs_rdlvl [87:86]  ;
        assign dbg_prbs_rdlvl_right_edge_pb[18+:6]      = dbg_prbs_rdlvl [88+:6]  ;
        assign dbg_prbs_rdlvl_right_gain_pb[ 6+:2]      = dbg_prbs_rdlvl [95:94]  ;
        assign dbg_prbs_rdlvl_right_edge_pb[24+:6]      = dbg_prbs_rdlvl [96+:6]  ;
        assign dbg_prbs_rdlvl_right_gain_pb[ 8+:2]      = dbg_prbs_rdlvl [103:102];
        assign dbg_prbs_rdlvl_right_edge_pb[30+:6]      = dbg_prbs_rdlvl [104+:6] ;
        assign dbg_prbs_rdlvl_right_gain_pb[10+:2]      = dbg_prbs_rdlvl [111:110];
        assign dbg_prbs_rdlvl_right_edge_pb[36+:6]      = dbg_prbs_rdlvl [112+:6] ;
        assign dbg_prbs_rdlvl_right_gain_pb[12+:2]      = dbg_prbs_rdlvl [119:118];
        assign dbg_prbs_rdlvl_right_edge_pb[42+:6]      = dbg_prbs_rdlvl [120+:6] ;
        assign dbg_prbs_rdlvl_right_gain_pb[14+:2]      = dbg_prbs_rdlvl [127:126];
        assign dbg_prbs_rdlvl_pi_counter_read_val       = dbg_prbs_rdlvl [128+:6];
        assign dbg_prbs_rdlvl_prbs_dqs_tap_cnt_r        = dbg_prbs_rdlvl [134+:6];
        assign dbg_prbs_rdlvl_prbs_found_1st_edge_r     = dbg_prbs_rdlvl [140]    ;
        assign dbg_prbs_rdlvl_prbs_found_2nd_edge_r     = dbg_prbs_rdlvl [141]    ;
        assign dbg_prbs_rdlvl_compare_err               = dbg_prbs_rdlvl [142]    ;
        assign dbg_prbs_rdlvl_phy_if_empty              = dbg_prbs_rdlvl [143]    ;
        assign dbg_prbs_rdlvl_prbs_rdlvl_start          = dbg_prbs_rdlvl [144]    ;
        assign dbg_prbs_rdlvl_prbs_rdlvl_done           = dbg_prbs_rdlvl [145]    ;
        assign dbg_prbs_rdlvl_prbs_dqs_cnt_r            = dbg_prbs_rdlvl [146+:5] ;
        assign dbg_prbs_rdlvl_left_edge_pb_dqs_cnt      = dbg_prbs_rdlvl [151+:6] ;
        assign dbg_prbs_rdlvl_right_edge_pb_dqs_cnt     = dbg_prbs_rdlvl [157+:6] ;
        assign dbg_prbs_rdlvl_rd_victim_sel             = dbg_prbs_rdlvl [163+:3] ;
        assign dbg_prbs_rdlvl_complex_victim_inc        = dbg_prbs_rdlvl [166]    ;
        assign dbg_prbs_rdlvl_right_gain_pb_dqs_cnt     = dbg_prbs_rdlvl [169+:6] ;
        assign dbg_prbs_rdlvl_ref_bit                   = dbg_prbs_rdlvl [177:175];
        assign dbg_prbs_rdlvl_prbs_state_r1             = dbg_prbs_rdlvl [178+:6];
        assign dbg_prbs_rdlvl_rd_valid_r2               = dbg_prbs_rdlvl [184];
        assign dbg_prbs_rdlvl_compare_err_r0            = dbg_prbs_rdlvl [185];
        assign dbg_prbs_rdlvl_compare_err_f0            = dbg_prbs_rdlvl [186];
        assign dbg_prbs_rdlvl_compare_err_r1            = dbg_prbs_rdlvl [187];
        assign dbg_prbs_rdlvl_compare_err_f1            = dbg_prbs_rdlvl [188];
        assign dbg_prbs_rdlvl_compare_err_r2            = dbg_prbs_rdlvl [189];
        assign dbg_prbs_rdlvl_compare_err_f2            = dbg_prbs_rdlvl [190];
        assign dbg_prbs_rdlvl_compare_err_r3            = dbg_prbs_rdlvl [191];
        assign dbg_prbs_rdlvl_compare_err_f3            = dbg_prbs_rdlvl [192];
        assign dbg_prbs_rdlvl_left_edge_found_pb        = dbg_prbs_rdlvl [193+:8];
        assign dbg_prbs_rdlvl_right_edge_found_pb       = dbg_prbs_rdlvl [201+:8];
        assign dbg_prbs_rdlvl_largest_left_edge         = dbg_prbs_rdlvl [209+:6];
        assign dbg_prbs_rdlvl_smallest_right_edge       = dbg_prbs_rdlvl [215+:6];
        assign dbg_prbs_rdlvl_fine_delay_incdec_pb      = dbg_prbs_rdlvl [221+:8];
        assign dbg_prbs_rdlvl_fine_delay_sel            = dbg_prbs_rdlvl [229];
        assign dbg_prbs_rdlvl_compare_err_pb_latch_r    = dbg_prbs_rdlvl [230+:8];
        assign dbg_prbs_rdlvl_fine_pi_dec_cnt           = dbg_prbs_rdlvl [238+:6];
        assign dbg_prbs_rdlvl_match_flag_and            = dbg_prbs_rdlvl [244+:5];
        assign dbg_prbs_rdlvl_stage_cnt                 = dbg_prbs_rdlvl [249+:2];
        assign dbg_prbs_rdlvl_fine_inc_stage            = dbg_prbs_rdlvl [251];
        assign dbg_prbs_rdlvl_compare_err_pb_and        = dbg_prbs_rdlvl [252];
        assign dbg_prbs_rdlvl_right_edge_found          = dbg_prbs_rdlvl [253];
        assign dbg_prbs_rdlvl_fine_dly_error            = dbg_prbs_rdlvl [254];

        always @(posedge clk)
        begin
            dbg_extn_trig_out_ack_r[0]    <= dbg_extn_trig_out;
            dbg_extn_trig_out_ack_r[7:1]  <= dbg_extn_trig_out_ack_r[6:0];
        end
        assign dbg_extn_trig_out_ack            = dbg_extn_trig_out_ack_r[7];

        ila_ddr2_axi u_ila_ddr2_axi(
          .clk          (clk),
          .trig_out     (dbg_extn_trig_out),
          .trig_out_ack (dbg_extn_trig_out_ack),
          .probe0       (dbg_init_calib_complete),
          .probe1       (dbg_wrlvl_start),
          .probe2       (dbg_wrlvl_done),
          .probe3       (dbg_wrlvl_err),
          .probe4       (dbg_pi_phaselock_start),
          .probe5       (dbg_pi_phaselocked_done),
          .probe6       (dbg_pi_phaselock_err),
          .probe7       (dbg_pi_dqsfound_start),
          .probe8       (dbg_pi_dqsfound_done),
          .probe9       (dbg_pi_dqsfound_err),
          .probe10      (dbg_rdlvl_start),
          .probe11      (dbg_rdlvl_done),
          .probe12      (dbg_rdlvl_err),
          .probe13      (dbg_oclkdelay_calib_start),
          .probe14      (dbg_oclkdelay_calib_done),
          .probe15      (dbg_wrcal_start),
          .probe16      (dbg_wrcal_done),
          .probe17      (dbg_wrcal_err),
          .probe18      (dbg_phy_init_5_0),
          .probe19      (dbg_rddata_valid_r),
          .probe20      (dbg_rddata_r),
          .probe21      (dbg_fine_adjust_done_r),
          .probe22      (dbg_cmd_wdt_err_w),
          .probe23      (dbg_rd_wdt_err_w),
          .probe24      (dbg_wr_wdt_err_w),
          .probe25      (dbg_tg_compare_error),
          .probe26      (dbg_axi_cmp_data),
          .probe27      (dbg_axi_rdata_cmp),
          .probe28      (dbg_wl_state_r),
          .probe29      (dbg_dqs_cnt_r),
          .probe30      (dbg_wl_edge_detect_valid_r),
          .probe31      (dbg_rd_data_edge_detect_r_by_dqs),
          .probe32      (dbg_wl_po_fine_cnt_by_dqs),
          .probe33      (dbg_wl_po_coarse_cnt_by_dqs),

          .probe34      (dbg_phy_oclkdelay_zfo),
          .probe35      (dbg_ocal_fuzz2oneeighty),
          .probe36      (dbg_ocal_fuzz2zero),
          .probe37      (dbg_ocal_oneeighty2fuzz),
          .probe38      (dbg_ocal_zero2fuzz),
          .probe39      (dbg_ocal_oclkdelay_calib_cnt),
          .probe40      (dbg_ocal_scan_win_not_found),

          .probe41      (dbg_wrcal_pat_data_match_r),
          .probe42      (dbg_wrcal_pat_data_match_valid_r),
          .probe43      (dbg_wrcal_dqs_cnt_r),
          .probe44      (cal2_state_r),
          .probe45      (not_empty_wait_cnt),
          .probe46      (dbg_early1_data),
          .probe47      (dbg_early2_data),
          .probe48      (dbg_phy_oclkdelay_cal_57_54),
          .probe49      (dbg_phy_wrlvl_128_75),
          .probe50      (dbg_phy_wrlvl_155_129),
          .probe51      (dbg_pi_phase_locked_phy4lanes),
          .probe52      (dbg_pi_dqs_found_lanes_phy4lanes),
          .probe53      (dbg_rd_data_offset),
          .probe54      (dbg_cal1_state_r),
          .probe55      (dbg_cal1_cnt_cpt_r),
          .probe56      (dbg_mux_rd_rise0_r),
          .probe57      (dbg_mux_rd_fall0_r),
          .probe58      (dbg_mux_rd_rise1_r),
          .probe59      (dbg_mux_rd_fall1_r),
          .probe60      (dbg_mux_rd_rise2_r),
          .probe61      (dbg_mux_rd_fall2_r),
          .probe62      (dbg_mux_rd_rise3_r),
          .probe63      (dbg_mux_rd_fall3_r),
          .probe64      (dbg_rdlvl_pat_data_match_r),
          .probe65      (dbg_mux_rd_valid_r),
          .probe66      (dbg_cpt_first_edge_cnt_by_dqs),
          .probe67      (dbg_cpt_second_edge_cnt_by_dqs),
          .probe68      (dbg_cpt_tap_cnt_by_dqs),
          .probe69      (dbg_dq_idelay_tap_cnt_by_dqs),
          .probe70      (dbg_dbg_calib_rd_data_offset_1),
          .probe71      (dbg_dbg_calib_rd_data_offset_2),
          .probe72      (dbg_data_offset),
          .probe73      (dbg_data_offset_1),
          .probe74      (dbg_data_offset_2),
          .probe75      (dbg_cpt_first_edge_cnt),
          .probe76      (dbg_cpt_second_edge_cnt),
          .probe77      (dbg_cpt_tap_cnt),
          .probe78      (dbg_dq_idelay_tap_cnt),

          .probe79      (dbg_prbs_rdlvl_left_edge_pb),
          .probe80      (dbg_prbs_rdlvl_left_loss_pb),
          .probe81      (dbg_prbs_rdlvl_right_edge_pb),
          .probe82      (dbg_prbs_rdlvl_right_gain_pb),
          .probe83      (dbg_prbs_rdlvl_pi_counter_read_val),
          .probe84      (dbg_prbs_rdlvl_prbs_dqs_tap_cnt_r),
          .probe85      (dbg_prbs_rdlvl_prbs_found_1st_edge_r),
          .probe86      (dbg_prbs_rdlvl_prbs_found_2nd_edge_r),
          .probe87      (dbg_prbs_rdlvl_compare_err),
          .probe88      (dbg_prbs_rdlvl_phy_if_empty),
          .probe89      (dbg_prbs_rdlvl_prbs_rdlvl_start),
          .probe90      (dbg_prbs_rdlvl_prbs_rdlvl_done),
          .probe91      (dbg_prbs_rdlvl_prbs_dqs_cnt_r),
          .probe92      (dbg_prbs_rdlvl_left_edge_pb_dqs_cnt),
          .probe93      (dbg_prbs_rdlvl_right_edge_pb_dqs_cnt),
          .probe94      (dbg_prbs_rdlvl_rd_victim_sel),
          .probe95      (dbg_prbs_rdlvl_complex_victim_inc),
          .probe96      (dbg_prbs_rdlvl_right_gain_pb_dqs_cnt),
          .probe97      (dbg_prbs_rdlvl_ref_bit),
          .probe98      (dbg_prbs_rdlvl_prbs_state_r1),
          .probe99      (dbg_prbs_rdlvl_rd_valid_r2),
          .probe100     (dbg_prbs_rdlvl_compare_err_r0),
          .probe101     (dbg_prbs_rdlvl_compare_err_f0),
          .probe102     (dbg_prbs_rdlvl_compare_err_r1),
          .probe103     (dbg_prbs_rdlvl_compare_err_f1),
          .probe104     (dbg_prbs_rdlvl_compare_err_r2),
          .probe105     (dbg_prbs_rdlvl_compare_err_f2),
          .probe106     (dbg_prbs_rdlvl_compare_err_r3),
          .probe107     (dbg_prbs_rdlvl_compare_err_f3),
          .probe108     (dbg_prbs_rdlvl_left_edge_found_pb),
          .probe109     (dbg_prbs_rdlvl_right_edge_found_pb),
          .probe110     (dbg_prbs_rdlvl_largest_left_edge),
          .probe111     (dbg_prbs_rdlvl_smallest_right_edge),
          .probe112     (dbg_prbs_rdlvl_fine_delay_incdec_pb),
          .probe113     (dbg_prbs_rdlvl_fine_delay_sel),
          .probe114     (dbg_prbs_rdlvl_compare_err_pb_latch_r),
          .probe115     (dbg_prbs_rdlvl_fine_pi_dec_cnt),
          .probe116     (dbg_prbs_rdlvl_match_flag_and),
          .probe117     (dbg_prbs_rdlvl_stage_cnt),
          .probe118     (dbg_prbs_rdlvl_fine_inc_stage),
          .probe119     (dbg_prbs_rdlvl_compare_err_pb_and),
          .probe120     (dbg_prbs_rdlvl_right_edge_found),
          .probe121     (dbg_prbs_rdlvl_fine_dly_error),

          .probe122     (dbg_ocal_lim_done),
          .probe123     (dbg_ocal_stg3_lim_left),
          .probe124     (dbg_ocal_stg3_lim_right),
          .probe125     (dbg_ocal_center_calib_start),

          .probe126     (dbg_wcal_mux_rd_rise0_r),
          .probe127     (dbg_wcal_mux_rd_fall0_r),
          .probe128     (dbg_wcal_mux_rd_rise1_r),
          .probe129     (dbg_wcal_mux_rd_fall1_r),
          .probe130     (dbg_wcal_mux_rd_rise2_r),
          .probe131     (dbg_wcal_mux_rd_fall2_r),
          .probe132     (dbg_wcal_mux_rd_rise3_r),
          .probe133     (dbg_wcal_mux_rd_fall3_r),
          .probe134     (dbg_early1_data_match_r),
          .probe135     (dbg_early2_data_match_r),
          .probe136     (dbg_wcal_sanity_pat_data_match_valid_r),
          .probe137     (dbg_prbs_final_dqs_tap_cnt_r),//108
          .probe138     (dbg_prbs_first_edge_taps),//108
          .probe139     (dbg_prbs_second_edge_taps),//108

          .probe140     (dbg_ocal_center_calib_done),
          .probe141     (dbg_phy_oclkdelay_cal_taps),
          .probe142     (dbg_ocal_tap_cnt)

        );


       always @(posedge clk)
       begin
         app_rd_data_valid_r1  <= #TCQ app_rd_data_valid;
         app_rd_data_valid_r2  <= #TCQ app_rd_data_valid_r1;
         app_rd_data_valid_r3  <= #TCQ app_rd_data_valid_r2;
         app_rd_data_r1        <= app_rd_data;
         app_rd_data_r2        <= app_rd_data_r1;
         app_rd_data_r3        <= app_rd_data_r2;
       end

       always @(posedge clk)
         if (rst)
           win_byte_select <= #TCQ 'b0;
         else if (vio_win_byte_select_inc_re) begin
           if (win_byte_select == (DQ_WIDTH/DRAM_WIDTH))
             win_byte_select <= #TCQ 'b0;
           else
             win_byte_select <= #TCQ win_byte_select + 1;
         end else if (vio_win_byte_select_dec_re) begin
           if (win_byte_select == 0)
             win_byte_select <= #TCQ (DQ_WIDTH/DRAM_WIDTH) -1;
           else
             win_byte_select <= #TCQ win_byte_select - 1;
         end

       always @(posedge clk) begin
         if (rst)
           dbg_byte_sel_r <= #TCQ 'd0;
         else begin
           if (!win_active)
             dbg_byte_sel_r <= #TCQ vio_sel_mux_rdd;
           else
             dbg_byte_sel_r <= #TCQ win_current_byte;
         end
       end

       mig_7series_v4_2_chk_win #
         (
          .TCQ         (TCQ),
          .nCK_PER_CLK (nCK_PER_CLK),
          .DLY_WIDTH   (26),
          .DQ_PER_DQS  (DRAM_WIDTH),
          .DQ_WIDTH    (PAYLOAD_WIDTH),
          .SC_WIDTH    (3),
          .SDC_WIDTH   (5),
          .WIN_SIZE    (6),
          .SIM_OPTION  (SIMULATION)
          )
         u_chk_win
           (
            .clk                   (clk),
            .rst                   (rst),
            .mem_pattern_init_done (mem_pattern_init_done),
            .win_start             (win_start),
            .read_valid            (app_rd_data_valid_r2),
            .win_byte_select       (win_byte_select),
            .cmp_data              (cmp_data),
            .rd_data               (app_rd_data_r2),
            .win_sel_pi_pon        (win_sel_pi_pon),
            .pi_curr_tap_cnt       (dbg_pi_counter_read_val),
            .po_curr_tap_cnt       (dbg_po_counter_read_val),
            .pi_left_ram_out       (pi_win_left_ram_out),
            .pi_right_ram_out      (pi_win_right_ram_out),
            .po_left_ram_out       (po_win_left_ram_out),
            .po_right_ram_out      (po_win_right_ram_out),
            .win_active            (win_active),
            .win_clr_error         (win_clr_error),
            .pi_win_up             (pi_win_up),
            .pi_win_down           (pi_win_down),
            .po_win_up             (po_win_up),
            .po_stg23_sel          (po_stg23_sel),
            .po_win_down           (po_win_down),
            .po_win_tg_rst         (po_win_tg_rst),
            .win_current_bit       (win_current_bit),
            .win_current_byte      (win_current_byte[3:0]),
            .dbg_clear_error       (dbg_clear_error),
            .dbg_win_chk           (dbg_win_chk)
            );

    end
    else begin: NO_CHIPSCOPE
       assign vio_modify_enable     = 1'b0;
       assign vio_data_mode_value   = 4'b0010;
       assign vio_addr_mode_value   = 3'b011;
       assign vio_instr_mode_value  = 4'b0010;
       assign vio_bl_mode_value     = 2'b10;
       assign vio_fixed_bl_value    = 8'd16;
       assign vio_data_mask_gen     = 1'b0;
       assign vio_pause_traffic     = 1'b0;
       assign vio_fixed_instr_value = 3'b001;
       assign dbg_clear_error       = 1'b0;

       assign dbg_sel_pi_incdec       = 'b0;
       assign dbg_sel_po_incdec       = 'b0;
       assign manual_clear_error      = 'b0;
       assign dbg_pi_f_inc            = 'b0;
       assign dbg_pi_f_dec            = 'b0;
       assign dbg_po_f_inc            = 'b0;
       assign dbg_po_f_dec            = 'b0;
       assign dbg_po_f_stg23_sel      = 'b0;
       assign win_start               = 'b0;
       assign win_sel_pi_pon          = 'b0;

       assign vio_win_byte_select_inc = 'b0;
       assign vio_win_byte_select_dec = 'b0;
       assign vio_sel_mux_rdd         = 'b0;
       assign vio_tg_simple_data_sel  = 'b0;

    end
 endgenerate

       

endmodule


