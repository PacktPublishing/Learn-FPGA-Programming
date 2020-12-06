module final_project
  (
   input wire          clk,
   output logic        vga_hsync,
   output logic        vga_vsync,
   output logic [11:0] vga_rgb,

   input [4:0]         SW, // Switches to configure resolution
   input               button_c, // Center button
   input               cpu_resetn, // When pressed, reset

   output [12:0]       ddr2_addr,
   output [2:0]        ddr2_ba,
   output              ddr2_cas_n,
   output [0:0]        ddr2_ck_n,
   output [0:0]        ddr2_ck_p,
   output [0:0]        ddr2_cke,
   output              ddr2_ras_n,
   output              ddr2_we_n,
   inout [15:0]        ddr2_dq,
   inout [1:0]         ddr2_dqs_n,
   inout [1:0]         ddr2_dqs_p,

   output [0:0]        ddr2_cs_n,
   output [1:0]        ddr2_dm,
   output [0:0]        ddr2_odt,

   inout               ps2_clk,
   inout               ps2_data,

   output logic [0:0]  LED
   );

  logic                init_calib_complete;
  logic                vga_hblank;
  logic                vga_vblank;
  logic                mc_clk;
  logic                clk200;
  logic                clk200_reset;
  typedef struct packed
                 {
                   logic [7:0] data;
                   logic       error;
                 } ps2_t;

  localparam PS2_DEPTH = 8;
  ps2_t ps2_data_capt;
  logic [PS2_DEPTH*2-1:0][7:0] ps2_data_store;
  logic                        ps2_toggle;
  (* async_reg = "TRUE" *) logic [2:0] ps2_sync;
  (* mark_debug = "TRUE" *) logic update_ps2;
  (* mark_debug = "TRUE" *) logic clear_ps2;

  debounce
    #
    (
     .CYCLES   (32)
     )
  u_debounce
    (
     .clk      (clk200),
     .reset    (reset),

     .sig_in   (~cpu_resetn),
     .sig_out  (clk200_reset)
     );

  assign LED[0] = clk200_reset;

  sys_clk u_sys_pll
    (
     .clk_out1         (clk200),
     .clk_out2         (mc_clk),
     .clk_in1          (clk)
     );

  logic [11:0]         s_axi_awaddr;
  logic [1:0]          s_axi_awvalid;
  logic [1:0]          s_axi_awready;
  logic [31:0]         s_axi_wdata;
  logic [1:0]          s_axi_wvalid;
  logic [1:0]          s_axi_wready;
  logic                locked;
  logic                pll_rst;

  pix_clk u_clk
    (
     .s_axi_aclk       (clk200),
     .s_axi_aresetn    (1'b1),
     .s_axi_awaddr     (s_axi_awaddr),
     .s_axi_awvalid    (s_axi_awvalid[0]),
     .s_axi_awready    (s_axi_awready[0]),
     .s_axi_wdata      (s_axi_wdata),
     .s_axi_wstrb      (4'hF),
     .s_axi_wvalid     (s_axi_wvalid[0]),
     .s_axi_wready     (s_axi_wready[0]),
     .s_axi_bresp      (),
     .s_axi_bvalid     (),
     .s_axi_bready     (1'b1),
     .s_axi_araddr     (11'b0),
     .s_axi_arvalid    (1'b0),
     .s_axi_arready    (),
     .s_axi_rdata      (),
     .s_axi_rresp      (),
     .s_axi_rvalid     (),
     .s_axi_rready     (1'b1),

     // Clock out ports
     .clk_out1         (vga_clk),
     // Status and control signals
     .locked           (locked),
     // Clock in ports
     .clk_in1          (clk200)
     );

  logic [7:0]          char_index;
  logic [2:0]          char_y;
  logic [7:0]          char_slice;

  logic                ui_clk;

  text_rom u_text_rom
    (
     .clock            (ui_clk),         // Clock
     .index            (char_index),  // Character Index
     .sub_index        (char_y),         // Y position in character

     .bitmap_out       (char_slice)      // 8 bit horizontal slice of character
     );

  logic                ui_clk_sync_rst;
  logic                mmcm_locked;
  logic                aresetn = '1;
  logic                app_sr_req = '0;;
  logic                app_ref_req = '0;
  logic                app_zq_req = '0;
  logic                app_sr_active;
  logic                app_ref_ack;
  logic                app_zq_ack;
  logic [3:0]          s_ddr_awid    = '0;
  logic [26:0]         s_ddr_awaddr;
  logic [7:0]          s_ddr_awlen   = '0;
  logic [2:0]          s_ddr_awsize  = 3'b100;
  logic [1:0]          s_ddr_awburst = 2'b01;
  logic [0:0]          s_ddr_awlock  = '0;
  logic [3:0]          s_ddr_awcache = '0;
  logic [2:0]          s_ddr_awprot  = '0;
  logic [3:0]          s_ddr_awqos   = '0;
  logic                s_ddr_awvalid = '0;
  logic                s_ddr_awready;
  logic [127:0]        s_ddr_wdata;
  logic [15:0]         s_ddr_wstrb = '0;
  logic                s_ddr_wlast = '0;
  logic                s_ddr_wvalid = '0;
  logic                s_ddr_wready;
  logic [3:0]          s_ddr_bid;
  logic [1:0]          s_ddr_bresp;
  logic                s_ddr_bvalid;
  logic                s_ddr_bready = '1;
  logic [3:0]          s_ddr_arid    = '0;
  logic [26:0]         s_ddr_araddr;
  logic [7:0]          s_ddr_arlen;
  logic [2:0]          s_ddr_arsize  = 3'b100; // 16 bytes
  logic [1:0]          s_ddr_arburst = 2'b01;  // incrementing
  logic [0:0]          s_ddr_arlock;
  logic [3:0]          s_ddr_arcache = '0;;
  logic [2:0]          s_ddr_arprot  = '0;
  logic [3:0]          s_ddr_arqos   = '0;
  logic                s_ddr_arvalid;
  logic                s_ddr_arready;
  logic [3:0]          s_ddr_rid;
  logic [127:0]        s_ddr_rdata;
  logic [1:0]          s_ddr_rresp;
  logic                s_ddr_rlast;
  logic                s_ddr_rvalid;
  logic                s_ddr_rready;

  ddr2_vga u_ddr2_vga
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
     .ui_clk                         (ui_clk),
     .ui_clk_sync_rst                (ui_clk_sync_rst),
     .mmcm_locked                    (mmcm_locked),
     .aresetn                        (aresetn),
     .app_sr_req                     (app_sr_req),
     .app_ref_req                    (app_ref_req),
     .app_zq_req                     (app_zq_req),
     .app_sr_active                  (app_sr_active),
     .app_ref_ack                    (app_ref_ack),
     .app_zq_ack                     (app_zq_ack),
     // Slave Interface Write Address Ports
     .s_axi_awid                     (s_ddr_awid),
     .s_axi_awaddr                   (s_ddr_awaddr),
     .s_axi_awlen                    (s_ddr_awlen),
     .s_axi_awsize                   (s_ddr_awsize),
     .s_axi_awburst                  (s_ddr_awburst),
     .s_axi_awlock                   (s_ddr_awlock),
     .s_axi_awcache                  (s_ddr_awcache),
     .s_axi_awprot                   (s_ddr_awprot),
     .s_axi_awqos                    (s_ddr_awqos),
     .s_axi_awvalid                  (s_ddr_awvalid),
     .s_axi_awready                  (s_ddr_awready),
     // Slave Interface Write Data Ports
     .s_axi_wdata                    (s_ddr_wdata),
     .s_axi_wstrb                    (s_ddr_wstrb),
     .s_axi_wlast                    (s_ddr_wlast),
     .s_axi_wvalid                   (s_ddr_wvalid),
     .s_axi_wready                   (s_ddr_wready),
     // Slave Interface Write Response Ports
     .s_axi_bid                      (s_ddr_bid),
     .s_axi_bresp                    (s_ddr_bresp),
     .s_axi_bvalid                   (s_ddr_bvalid),
     .s_axi_bready                   (s_ddr_bready),
     // Slave Interface Read Address Ports
     .s_axi_arid                     (s_ddr_arid),
     .s_axi_araddr                   (s_ddr_araddr),
     .s_axi_arlen                    (s_ddr_arlen),
     .s_axi_arsize                   (s_ddr_arsize),
     .s_axi_arburst                  (s_ddr_arburst),
     .s_axi_arlock                   (s_ddr_arlock),
     .s_axi_arcache                  (s_ddr_arcache),
     .s_axi_arprot                   (s_ddr_arprot),
     .s_axi_arqos                    (s_ddr_arqos),
     .s_axi_arvalid                  (s_ddr_arvalid),
     .s_axi_arready                  (s_ddr_arready),
     // Slave Interface Read Data Ports
     .s_axi_rid                      (s_ddr_rid),
     .s_axi_rdata                    (s_ddr_rdata),
     .s_axi_rresp                    (s_ddr_rresp),
     .s_axi_rlast                    (s_ddr_rlast),
     .s_axi_rvalid                   (s_ddr_rvalid),
     .s_axi_rready                   (s_ddr_rready),
     // System Clock Ports
     .sys_clk_i                      (mc_clk),
     // Reference Clock Ports
     .clk_ref_i                      (clk200),
     .sys_rst                        (1'b0)
     );

  wire [23:0]          int_vga_rgb;

  vga_core u_vga_core
    (
     // Register address
     .reg_clk      (clk200),
     .reg_reset    (ui_clk_sync_rst),

     .reg_awvalid  (s_axi_awvalid[1]),
     .reg_awready  (s_axi_awready[1]),
     .reg_awaddr   (s_axi_awaddr),

     .reg_wvalid   (s_axi_wvalid[1]),
     .reg_wready   (s_axi_wready[1]),
     .reg_wdata    (s_axi_wdata),
     .reg_wstrb    (4'b1111),

     .reg_bready   (1'b1),
     .reg_bvalid   (),
     .reg_bresp    (),

     .reg_arvalid  (1'b0),
     .reg_arready  (),
     .reg_araddr   ('0),

     .reg_rready   (1'b1),
     .reg_rvalid   (),
     .reg_rdata    (),
     .reg_rresp    (),

     // Master memory
     .mem_clk      (ui_clk),
     .mem_reset    (),

     .mem_arid     (s_ddr_arid),
     .mem_araddr   (s_ddr_araddr),
     .mem_arlen    (s_ddr_arlen),
     .mem_arsize   (s_ddr_arsize),
     .mem_arburst  (s_ddr_arburst),
     .mem_arlock   (s_ddr_arlock),
     .mem_arvalid  (s_ddr_arvalid),
     .mem_arready  (s_ddr_arready),

     .mem_rready   (s_ddr_rready),
     .mem_rid      (s_ddr_rid),
     .mem_rdata    (s_ddr_rdata),
     .mem_rresp    (s_ddr_rresp),
     .mem_rlast    (s_ddr_rlast),
     .mem_rvalid   (s_ddr_rvalid),

     .vga_clk      (vga_clk),
     .vga_hsync    (vga_hsync),
     .vga_hblank   (vga_hblank),
     .vga_vsync    (vga_vsync),
     .vga_vblank   (vga_vblank),
     .vga_rgb      (int_vga_rgb)
     );

  assign vga_rgb = {int_vga_rgb[23:20],int_vga_rgb[15:12], int_vga_rgb[7:4]};

  typedef struct packed {
    logic [7:0 ]  divide_count;
    logic [15:8]  mult_integer;
    logic [25:16] mult_fraction;
    logic [7:0]   divide_integer;
    logic [17:0]  divide_fraction;
    logic [11:0]  horiz_display_start;
    logic [11:0]  horiz_display_width;
    logic [11:0]  horiz_sync_width;
    logic [11:0]  horiz_total_width;
    logic [11:0]  vert_display_start;
    logic [11:0]  vert_display_width;
    logic [11:0]  vert_sync_width;
    logic [11:0]  vert_total_width;
    logic         hpol;
    logic         vpol;
    logic [12:0]  pitch;
  } resolution_t;

  resolution_t resolution[18];

  logic [17:0][15:0][7:0] res_text;
  logic [15:0][7:0]       res_text_capt;

  initial begin
    res_text                           = '{default:" "};

    // 25.18 Mhz 640x480 @ 60Hz
    resolution[0].divide_count         = 8'd9;
    resolution[0].mult_integer         = 8'd50;
    resolution[0].mult_fraction        = 10'd000;
    resolution[0].divide_integer       = 8'd44;
    resolution[0].divide_fraction      = 10'd125;
    resolution[0].horiz_display_start  = 12'd47; // BP -1
    resolution[0].horiz_display_width  = 12'd640;
    resolution[0].horiz_sync_width     = 12'd96;
    resolution[0].horiz_total_width    = 12'd799; // -1
    resolution[0].vert_display_start   = 12'd32;  // -1
    //resolution[0].vert_display_start   = 12'd2;  // -1
    resolution[0].vert_display_width   = 12'd480;
    resolution[0].vert_sync_width      = 12'd2;
    resolution[0].vert_total_width     = 12'd524; //-1
    resolution[0].hpol                 = '0;
    resolution[0].vpol                 = '0;
    resolution[0].pitch                = 13'd5*16; // 5 rows at 1bpp
    //resolution[0].pitch                = 13'd2046; // 5 rows at 1bpp
    res_text[0]                        = "  zH06 @ 084x046";
    // 31.5Mhz 640x480 @ 72 Hz
    resolution[1].divide_count         = 8'd8;
    resolution[1].mult_integer         = 8'd39;
    resolution[1].mult_fraction        = 10'd375;
    resolution[1].divide_integer       = 8'd31;
    resolution[1].divide_fraction      = 10'd250;
    resolution[1].horiz_display_start  = 12'd127;
    resolution[1].horiz_display_width  = 12'd640;
    resolution[1].horiz_sync_width     = 12'd40;
    resolution[1].horiz_total_width    = 12'd831;
    resolution[1].vert_display_start   = 12'd27;
    resolution[1].vert_display_width   = 12'd480;
    resolution[1].vert_sync_width      = 12'd3;
    resolution[1].vert_total_width     = 12'd519;
    resolution[1].hpol                 = '0;
    resolution[1].vpol                 = '0;
    resolution[1].pitch                = 13'd5*16; // 5 rows at 1bpp
    res_text[1]                        = "  zH27 @ 084x046";
    // 31.5Mhz 640x480 @ 75 Hz
    resolution[2].divide_count         = 8'd8;
    resolution[2].mult_integer         = 8'd39;
    resolution[2].mult_fraction        = 10'd375;
    resolution[2].divide_integer       = 8'd31;
    resolution[2].divide_fraction      = 10'd250;
    resolution[2].horiz_display_start  = 12'd47;
    resolution[2].horiz_display_width  = 12'd640;
    resolution[2].horiz_sync_width     = 12'd96;
    resolution[2].horiz_total_width    = 12'd800;
    resolution[2].vert_display_start   = 12'd31;
    resolution[2].vert_display_width   = 12'd480;
    resolution[2].vert_sync_width      = 12'd2;
    resolution[2].vert_total_width     = 12'd520;
    resolution[2].hpol                 = '0;
    resolution[2].vpol                 = '0;
    resolution[2].pitch                = 13'd5*16; // 5 rows at 1bpp
    res_text[2]                        = "  zH57 @ 084x046";
    // 36 Mhz 640x480 @ 85 Hz
    resolution[3].divide_count         = 8'd5;
    resolution[3].mult_integer         = 8'd24;
    resolution[3].mult_fraction        = 10'd750;
    resolution[3].divide_integer       = 8'd27;
    resolution[3].divide_fraction      = 10'd500;
    resolution[3].horiz_display_start  = 12'd111;
    resolution[3].horiz_display_width  = 12'd640;
    resolution[3].horiz_sync_width     = 12'd48;
    resolution[3].horiz_total_width    = 12'd831;
    resolution[3].vert_display_start   = 12'd23;
    resolution[3].vert_display_width   = 12'd480;
    resolution[3].vert_sync_width      = 12'd3;
    resolution[3].vert_total_width     = 12'd508;
    resolution[3].hpol                 = '0;
    resolution[3].vpol                 = '0;
    resolution[3].pitch                = 13'd5*16; // 5 rows at 1bpp
    res_text[3]                        = "  zH58 @ 084x046";
    // 40 Mhz 800x600 @ 60 Hz
    resolution[4].divide_count         = 8'd1;
    resolution[4].mult_integer         = 8'd5;
    resolution[4].mult_fraction        = 10'd000;
    resolution[4].divide_integer       = 8'd20;
    resolution[4].divide_fraction      = 10'd000;
    resolution[4].horiz_display_start  = 12'd87;
    resolution[4].horiz_display_width  = 12'd800;
    resolution[4].horiz_sync_width     = 12'd128;
    resolution[4].horiz_total_width    = 12'd1055;
    resolution[4].vert_display_start   = 12'd22;
    resolution[4].vert_display_width   = 12'd600;
    resolution[4].vert_sync_width      = 12'd4;
    resolution[4].vert_total_width     = 12'd627;
    resolution[4].hpol                 = '1;
    resolution[4].vpol                 = '1;
    resolution[4].pitch                = 13'd7*16; // 6.25 rows at 1bpp
    res_text[4]                        = "  zH06 @ 006x008";
    // 49.5 Mhz 800x600 @ 75 Hz
    resolution[5].divide_count         = 8'd5;
    resolution[5].mult_integer         = 8'd24;
    resolution[5].mult_fraction        = 10'd750;
    resolution[5].divide_integer       = 8'd20;
    resolution[5].divide_fraction      = 10'd000;
    resolution[5].horiz_display_start  = 12'd159;
    resolution[5].horiz_display_width  = 12'd800;
    resolution[5].horiz_sync_width     = 12'd80;
    resolution[5].horiz_total_width    = 12'd1055;
    resolution[5].vert_display_start   = 12'd20;
    resolution[5].vert_display_width   = 12'd600;
    resolution[5].vert_sync_width      = 12'd2;
    resolution[5].vert_total_width     = 12'd624;
    resolution[5].hpol                 = '1;
    resolution[5].vpol                 = '1;
    resolution[5].pitch                = 13'd7*16; // 6.25 rows at 1bpp
    res_text[5]                        = "  zH57 @ 006x008";
    // 50 Mhz 800x600 @ 72 Hz
    resolution[6].divide_count         = 8'd1;
    resolution[6].mult_integer         = 8'd5;
    resolution[6].mult_fraction        = 10'd000;
    resolution[6].divide_integer       = 8'd20;
    resolution[6].divide_fraction      = 10'd000;
    resolution[6].horiz_display_start  = 12'd63;
    resolution[6].horiz_display_width  = 12'd800;
    resolution[6].horiz_sync_width     = 12'd120;
    resolution[6].horiz_total_width    = 12'd1039;
    resolution[6].vert_display_start   = 12'd22;
    resolution[6].vert_display_width   = 12'd600;
    resolution[6].vert_sync_width      = 12'd6;
    resolution[6].vert_total_width     = 12'd665;
    resolution[6].hpol                 = '1;
    resolution[6].vpol                 = '1;
    resolution[6].pitch                = 13'd7*16; // 6.25 rows at 1bpp
    res_text[6]                        = "  zH27 @ 006x008";
    // 56.25 Mhz 800x600 @ 85 Hz
    resolution[7].divide_count         = 8'd2;
    resolution[7].mult_integer         = 8'd10;
    resolution[7].mult_fraction        = 10'd125;
    resolution[7].divide_integer       = 8'd18;
    resolution[7].divide_fraction      = 10'd000;
    resolution[7].horiz_display_start  = 12'd151;
    resolution[7].horiz_display_width  = 12'd800;
    resolution[7].horiz_sync_width     = 12'd64;
    resolution[7].horiz_total_width    = 12'd1047;
    resolution[7].vert_display_start   = 12'd26;
    resolution[7].vert_display_width   = 12'd600;
    resolution[7].vert_sync_width      = 12'd3;
    resolution[7].vert_total_width     = 12'd630;
    resolution[7].hpol                 = '1;
    resolution[7].vpol                 = '1;
    resolution[7].pitch                = 13'd7*16; // 6.25 rows at 1bpp
    res_text[7]                        = "  zH58 @ 006x008";
    // 65 Mhz 1024x768 @ 60 Hz
    resolution[8].divide_count         = 8'd10;
    resolution[8].mult_integer         = 8'd50;
    resolution[8].mult_fraction        = 10'd375;
    resolution[8].divide_integer       = 8'd15;
    resolution[8].divide_fraction      = 10'd500;
    resolution[8].horiz_display_start  = 12'd159;
    resolution[8].horiz_display_width  = 12'd1024;
    resolution[8].horiz_sync_width     = 12'd136;
    resolution[8].horiz_total_width    = 12'd1339;
    resolution[8].vert_display_start   = 12'd28;
    resolution[8].vert_display_width   = 12'd768;
    resolution[8].vert_sync_width      = 12'd6;
    resolution[8].vert_total_width     = 12'd805;
    resolution[8].hpol                 = '0;
    resolution[8].vpol                 = '0;
    resolution[8].pitch                = 13'd8*16;
    res_text[8]                        = " zH06 @ 867x4201";
    // 75 Mhz 1024x768 @ 70 Hz
    resolution[9].divide_count         = 8'd8;
    resolution[9].mult_integer         = 8'd40;
    resolution[9].mult_fraction        = 10'd125;
    resolution[9].divide_integer       = 8'd13;
    resolution[9].divide_fraction      = 10'd375;
    resolution[9].horiz_display_start  = 12'd143;
    resolution[9].horiz_display_width  = 12'd1024;
    resolution[9].horiz_sync_width     = 12'd136;
    resolution[9].horiz_total_width    = 12'd1327;
    resolution[9].vert_display_start   = 12'd28;
    resolution[9].vert_display_width   = 12'd768;
    resolution[9].vert_sync_width      = 12'd6;
    resolution[9].vert_total_width     = 12'd805;
    resolution[9].hpol                 = '0;
    resolution[9].vpol                 = '0;
    resolution[9].pitch                = 13'd8*16;
    res_text[9]                        = " zH07 @ 867x4201";
    // 78.75 Mhz 1024x768 @ 75 Hz
    resolution[10].divide_count        = 8'd8;
    resolution[10].mult_integer        = 8'd39;
    resolution[10].mult_fraction       = 10'd375;
    resolution[10].divide_integer      = 8'd12;
    resolution[10].divide_fraction     = 10'd500;
    resolution[10].horiz_display_start = 12'd175;
    resolution[10].horiz_display_width = 12'd1024;
    resolution[10].horiz_sync_width    = 12'd96;
    resolution[10].horiz_total_width   = 12'd1311;
    resolution[10].vert_display_start  = 12'd27;
    resolution[10].vert_display_width  = 12'd768;
    resolution[10].vert_sync_width     = 12'd3;
    resolution[10].vert_total_width    = 12'd799;
    resolution[10].hpol                = '1;
    resolution[10].vpol                = '1;
    resolution[10].pitch               = 13'd8*16;
    res_text[10]                       = " zH57 @ 867x4201";
    // 94.5 Mhz 1024x768 @ 85 Hz
    resolution[11].divide_count        = 8'd5;
    resolution[11].mult_integer        = 8'd23;
    resolution[11].mult_fraction       = 10'd625;
    resolution[11].divide_integer      = 8'd10;
    resolution[11].divide_fraction     = 10'd000;
    resolution[11].horiz_display_start = 12'd207;
    resolution[11].horiz_display_width = 12'd1024;
    resolution[11].horiz_sync_width    = 12'd96;
    resolution[11].horiz_total_width   = 12'd1375;
    resolution[11].vert_display_start  = 12'd35;
    resolution[11].vert_display_width  = 12'd768;
    resolution[11].vert_sync_width     = 12'd3;
    resolution[11].vert_total_width    = 12'd807;
    resolution[11].hpol                = '1;
    resolution[11].vpol                = '1;
    resolution[11].pitch               = 13'd8*16;
    res_text[11]                       = " zH58 @ 867x4201";
    // 108 Mhz 1280x1024 @ 60 Hz
    resolution[12].divide_count        = 8'd2;
    resolution[12].mult_integer        = 8'd10;
    resolution[12].mult_fraction       = 10'd125;
    resolution[12].divide_integer      = 8'd9;
    resolution[12].divide_fraction     = 10'd375;
    resolution[12].horiz_display_start = 12'd247;
    resolution[12].horiz_display_width = 12'd1280;
    resolution[12].horiz_sync_width    = 12'd112;
    resolution[12].horiz_total_width   = 12'd1688;
    resolution[12].vert_display_start  = 12'd37;
    resolution[12].vert_display_width  = 12'd1024;
    resolution[12].vert_sync_width     = 12'd3;
    resolution[12].vert_total_width    = 12'd1066;
    resolution[12].hpol                = '1;
    resolution[12].vpol                = '1;
    resolution[12].pitch               = 13'd10*16;
    res_text[12]                       = "zH06 @ 4201x0821";
    // 135 Mhz 1280x1024 @ 75 Hz
    resolution[13].divide_count        = 8'd2;
    resolution[13].mult_integer        = 8'd10;
    resolution[13].mult_fraction       = 10'd125;
    resolution[13].divide_integer      = 8'd7;
    resolution[13].divide_fraction     = 10'd500;
    resolution[13].horiz_display_start = 12'd247;
    resolution[13].horiz_display_width = 12'd1280;
    resolution[13].horiz_sync_width    = 12'd144;
    resolution[13].horiz_total_width   = 12'd1688;
    resolution[13].vert_display_start  = 12'd37;
    resolution[13].vert_display_width  = 12'd1024;
    resolution[13].vert_sync_width     = 12'd3;
    resolution[13].vert_total_width    = 12'd1066;
    resolution[13].hpol                = '1;
    resolution[13].vpol                = '1;
    resolution[13].pitch               = 13'd10*16;
    res_text[13]                       = "zH57 @ 4201x0821";
    // 157.5 Mhz 1280x1024 @ 85 Hz
    resolution[14].divide_count        = 8'd8;
    resolution[14].mult_integer        = 8'd39;
    resolution[14].mult_fraction       = 10'd375;
    resolution[14].divide_integer      = 8'd6;
    resolution[14].divide_fraction     = 10'd250;
    resolution[14].horiz_display_start = 12'd223;
    resolution[14].horiz_display_width = 12'd1280;
    resolution[14].horiz_sync_width    = 12'd160;
    resolution[14].horiz_total_width   = 12'd1728;
    resolution[14].vert_display_start  = 12'd043;
    resolution[14].vert_display_width  = 12'd1024;
    resolution[14].vert_sync_width     = 12'd3;
    resolution[14].vert_total_width    = 12'd1072;
    resolution[14].hpol                = '1;
    resolution[14].vpol                = '1;
    resolution[14].pitch               = 13'd10*16;
    res_text[14]                       = "zH58 @ 4201x0821";
    // 162 Mhz 1600x1200 @ 60 Hz
    resolution[15].divide_count        = 8'd2;
    resolution[15].mult_integer        = 8'd10;
    resolution[15].mult_fraction       = 10'd125;
    resolution[15].divide_integer      = 8'd6;
    resolution[15].divide_fraction     = 10'd250;
    resolution[15].horiz_display_start = 12'd303;
    resolution[15].horiz_display_width = 12'd1600;
    resolution[15].horiz_sync_width    = 12'd192;
    resolution[15].horiz_total_width   = 12'd2160;
    resolution[15].vert_display_start  = 12'd45;
    resolution[15].vert_display_width  = 12'd1200;
    resolution[15].vert_sync_width     = 12'd3;
    resolution[15].vert_total_width    = 12'd1250;
    resolution[15].hpol                = '1;
    resolution[15].vpol                = '1;
    resolution[15].pitch               = 13'd13*16; // 12.5
    res_text[15]                       = "zH06 @ 0021x0061";
    // 195 Mhz 1920x1200 @ 60 Hz
    resolution[16].divide_count        = 8'd1;
    resolution[16].mult_integer        = 8'd4;
    resolution[16].mult_fraction       = 10'd875;
    resolution[16].divide_integer      = 8'd5;
    resolution[16].divide_fraction     = 10'd000;
    resolution[16].horiz_display_start = 12'd399;
    resolution[16].horiz_display_width = 12'd1920;
    resolution[16].horiz_sync_width    = 12'd200;
    resolution[16].horiz_total_width   = 12'd2616;
    resolution[16].vert_display_start  = 12'd35;
    resolution[16].vert_display_width  = 12'd1200;
    resolution[16].vert_sync_width     = 12'd3;
    resolution[16].vert_total_width    = 12'd1242;
    resolution[16].hpol                = '1;
    resolution[16].vpol                = '1;
    resolution[16].pitch               = 13'd15*16;
    res_text[16]                       = "zH06 @ 0021x0291";
    // 195 Mhz 1920x1200 @ 60 Hz
    resolution[17].divide_count        = 8'd8;
    resolution[17].mult_integer        = 8'd37;
    resolution[17].mult_fraction       = 10'd125;
    resolution[17].divide_integer      = 8'd6;
    resolution[17].divide_fraction     = 10'd250;
    resolution[17].horiz_display_start = 12'd147;
    resolution[17].horiz_display_width = 12'd1920;
    resolution[17].horiz_sync_width    = 12'd44;
    resolution[17].horiz_total_width   = 12'd2199;
    resolution[17].vert_display_start  = 12'd3;
    resolution[17].vert_display_width  = 12'd1080;
    resolution[17].vert_sync_width     = 12'd5;
    resolution[17].vert_total_width    = 12'd1124;
    resolution[17].hpol                = '1;
    resolution[17].vpol                = '1;
    resolution[17].pitch               = 13'd15*16;
    res_text[17]                       = "zH06 @ 0801x0291";
  end

  logic [11:0] addr_array[32];

  initial begin
    addr_array[0]  = 12'h200;
    addr_array[1]  = 12'h204;
    addr_array[2]  = 12'h208;
    addr_array[3]  = 12'h20C;
    addr_array[4]  = 12'h210;
    addr_array[5]  = 12'h214;
    addr_array[6]  = 12'h218;
    addr_array[7]  = 12'h21C;
    addr_array[8]  = 12'h220;
    addr_array[9]  = 12'h224;
    addr_array[10] = 12'h228;
    addr_array[11] = 12'h22C;
    addr_array[12] = 12'h230;
    addr_array[13] = 12'h234;
    addr_array[14] = 12'h238;
    addr_array[15] = 12'h23C;
    addr_array[16] = 12'h240;
    addr_array[17] = 12'h244;
    addr_array[18] = 12'h248;
    addr_array[19] = 12'h24C;
    addr_array[20] = 12'h250;
    addr_array[21] = 12'h254;
    addr_array[22] = 12'h258;
    addr_array[23] = 12'h25C;
    addr_array[24] = 12'h000;
    addr_array[25] = 12'h004;
    addr_array[26] = 12'h008;
    addr_array[27] = 12'h00C;
    addr_array[28] = 12'h010;
    addr_array[29] = 12'h100;
    addr_array[30] = 12'h104;
    addr_array[31] = 12'h108;
  end

  typedef enum bit [3:0]
               {
                CFG_IDLE[2],
                CFG_WR[6],
                WRITE_TEXT
                } cfg_state_t;

  cfg_state_t cfg_state;

  logic [31:0]         disp_addr;

  logic [2:0]          button_sync;
  logic [4:0]          sw_capt;
  logic [4:0]          wr_count;

  initial begin
    button_sync = '0;
    cfg_state   = CFG_IDLE0;
  end

  logic [1:0] last_write;
  logic       update_text;
  (* mark_debug = "TRUE" *) logic [2:0] update_text_sync;

  initial begin
    update_text      = '0;
    update_text_sync = '0;
  end

  // Clock reconfiguration
  always @(posedge clk200) begin
    button_sync <= button_sync << 1 | button_c;
    last_write[0]  <= wr_count == 24;
    last_write[1]  <= wr_count == 31;
    pll_rst        <= '1;
    case (cfg_state)
      CFG_IDLE0: begin
        update_text   <= ~update_text;
        cfg_state     <= CFG_IDLE1;
      end
      CFG_IDLE1: begin
        wr_count      <= '0;
        s_axi_awvalid <= '0;
        s_axi_wvalid  <= '0;
        if (button_sync[2:1] == 2'b10) begin
          // We can start writing the text as we are updating
          update_text   <= ~update_text;
          pll_rst       <= '0;
          wr_count      <= 3'b1;
          s_axi_awvalid <= 2'b1;
          s_axi_awaddr  <= addr_array[0];
          s_axi_wvalid  <= 2'b1;
          s_axi_wdata   <= {7'b0, resolution[SW].mult_fraction,
                            resolution[SW].mult_integer,
                            resolution[SW].divide_count};
          sw_capt       <= SW;
          cfg_state     <= CFG_WR0;
        end
      end
      CFG_WR0: begin
        pll_rst       <= '0;
        casez ({last_write[0], s_axi_awready[0], s_axi_wready[0]})
          3'b111: begin
            s_axi_awvalid <= '0;
            s_axi_wvalid  <= '0;
            cfg_state     <= CFG_WR3;
          end
          3'b011: begin
            wr_count      <= wr_count + 1'b1;
            s_axi_awvalid <= 2'b1;
            s_axi_wvalid  <= 2'b1;
            s_axi_awaddr  <= addr_array[wr_count];
            case (wr_count)
              1, 3, 6, 9, 12, 15, 18, 21: s_axi_wdata <= '0;
              5, 8, 11, 14, 17, 20:       s_axi_wdata <= 32'hA;
              4, 7, 10, 13, 16, 19, 22:   s_axi_wdata <= 32'hC350;
              2: begin
                s_axi_wdata <= {15'b0,
                                resolution[sw_capt].divide_fraction,
                                resolution[sw_capt].divide_integer};
              end
              23:  s_axi_wdata <= 32'b11;
              24: s_axi_wdata <= {4'b0,
                                    resolution[sw_capt].horiz_display_width,
                                    4'b0,
                                    resolution[sw_capt].horiz_display_start};
              25: s_axi_wdata <= {4'b0,
                                    resolution[sw_capt].horiz_total_width,
                                    4'b0,
                                    resolution[sw_capt].horiz_sync_width};
              26: s_axi_wdata <= {4'b0,
                                    resolution[sw_capt].vert_display_width,
                                    4'b0,
                                    resolution[sw_capt].vert_display_start};
              27: s_axi_wdata <= {4'b0,
                                    resolution[sw_capt].vert_total_width,
                                    4'b0,
                                    resolution[sw_capt].vert_sync_width};
              28: s_axi_wdata <= {16'b0, 8'd0, 6'b0,
                                    resolution[sw_capt].hpol,
                                    resolution[sw_capt].vpol};
              29: s_axi_wdata <= '0;
              30: s_axi_wdata <= {18'b0, resolution[sw_capt].pitch};
              31: s_axi_wdata <= 32'b1;
            endcase // case (wr_count)
          end // case: 3'b011
          3'bz10: begin
            s_axi_awvalid <= 2'b1;
            cfg_state     <= CFG_WR1;
          end
          3'bz01: begin
            s_axi_wvalid <= 2'b1;
            cfg_state     <= CFG_WR2;
          end
        endcase // casez ({last_write, s_axi_awready, s_axi_wready})
      end // case: CFG_WR0
      CFG_WR1: begin
        pll_rst       <= '0;
        casez ({last_write[0], s_axi_wready[0]})
          2'b11: begin
            s_axi_awvalid <= '0;
            s_axi_wvalid  <= '0;
            cfg_state     <= CFG_WR3;
          end
          2'b01: begin
            wr_count      <= wr_count + 1'b1;
            s_axi_awvalid <= 2'b1;
            s_axi_wvalid  <= 2'b1;
            cfg_state     <= CFG_WR0;
            s_axi_awaddr  <= addr_array[wr_count];
            case (wr_count)
              1, 3, 6, 9, 12, 15, 18, 21: s_axi_wdata <= '0;
              5, 8, 11, 14, 17, 20:       s_axi_wdata <= 32'hA;
              4, 7, 10, 13, 16, 19, 22:   s_axi_wdata <= 32'hC350;
              2: begin
                s_axi_wdata <= {15'b0,
                                resolution[sw_capt].divide_fraction,
                                resolution[sw_capt].divide_integer};
              end
              23:  s_axi_wdata <= 32'b11;
              24: s_axi_wdata <= {4'b0,
                                    resolution[sw_capt].horiz_display_width,
                                    4'b0,
                                    resolution[sw_capt].horiz_display_start};
              25: s_axi_wdata <= {4'b0,
                                    resolution[sw_capt].horiz_total_width,
                                    4'b0,
                                    resolution[sw_capt].horiz_sync_width};
              26: s_axi_wdata <= {4'b0,
                                    resolution[sw_capt].vert_display_width,
                                    4'b0,
                                    resolution[sw_capt].vert_display_start};
              27: s_axi_wdata <= {4'b0,
                                    resolution[sw_capt].vert_total_width,
                                    4'b0,
                                    resolution[sw_capt].vert_sync_width};
              28: s_axi_wdata <= {16'b0, 8'd0, 6'b0,
                                    resolution[sw_capt].hpol,
                                    resolution[sw_capt].vpol};
              29: s_axi_wdata <= '0;
              30: s_axi_wdata <= {18'b0, resolution[sw_capt].pitch};
              31: s_axi_wdata <= 32'b1;
            endcase // case (wr_count)
          end // case: 3'b011
        endcase // casez ({last_write, s_axi_awready, s_axi_wready})
      end // case: CFG_WR1
      CFG_WR2: begin
        pll_rst       <= '0;
        casez ({last_write[0], s_axi_awready[0]})
          2'b11: begin
            s_axi_awvalid <= '0;
            s_axi_wvalid  <= '0;
            cfg_state     <= CFG_WR3;
          end
          2'b01: begin
            wr_count      <= wr_count + 1'b1;
            s_axi_awvalid <= 2'b1;
            s_axi_wvalid  <= 2'b1;
            cfg_state     <= CFG_WR0;
            s_axi_awaddr  <= addr_array[wr_count];
            case (wr_count)
              1, 3, 6, 9, 12, 15, 18, 21: s_axi_wdata <= '0;
              5, 8, 11, 14, 17, 20:       s_axi_wdata <= 32'hA;
              4, 7, 10, 13, 16, 19, 22:   s_axi_wdata <= 32'hC350;
              2: begin
                s_axi_wdata <= {15'b0,
                                resolution[sw_capt].divide_fraction,
                                resolution[sw_capt].divide_integer};
              end
              23: s_axi_wdata <= 32'b11;
              24: s_axi_wdata <= {4'b0,
                                    resolution[sw_capt].horiz_display_width,
                                    4'b0,
                                    resolution[sw_capt].horiz_display_start};
              25: s_axi_wdata <= {4'b0,
                                    resolution[sw_capt].horiz_total_width,
                                    4'b0,
                                    resolution[sw_capt].horiz_sync_width};
              26: s_axi_wdata <= {4'b0,
                                    resolution[sw_capt].vert_display_width,
                                    4'b0,
                                    resolution[sw_capt].vert_display_start};
              27: s_axi_wdata <= {4'b0,
                                    resolution[sw_capt].vert_total_width,
                                    4'b0,
                                    resolution[sw_capt].vert_sync_width};
              28: s_axi_wdata <= {16'b0, 8'd0, 6'b0,
                                    resolution[sw_capt].hpol,
                                    resolution[sw_capt].vpol};
              29: s_axi_wdata <= '0;
              30: s_axi_wdata <= {18'b0, resolution[sw_capt].pitch};
              31: s_axi_wdata <= 32'b1;
            endcase // case (wr_count)
          end // case: 3'b011
        endcase // casez ({last_write, s_axi_awready, s_axi_wready})
      end // case: CFG_WR1
      CFG_WR3: begin
        pll_rst       <= '0;
        casez ({last_write[1], s_axi_awready[1], s_axi_wready[1]})
          3'b111: begin
            wr_count      <= '0;
            s_axi_awvalid <= '0;
            s_axi_wvalid  <= '0;
            cfg_state     <= CFG_IDLE1;
          end
          3'b011: begin
            wr_count      <= wr_count + 1'b1;
            s_axi_awvalid <= 2'b10;
            s_axi_wvalid  <= 2'b10;
            s_axi_awaddr  <= addr_array[wr_count];
            case (wr_count)
              1, 3, 6, 9, 12, 15, 18, 21: s_axi_wdata <= '0;
              5, 8, 11, 14, 17, 20:       s_axi_wdata <= 32'hA;
              4, 7, 10, 13, 16, 19, 22:   s_axi_wdata <= 32'hC350;
              2: begin
                s_axi_wdata <= {15'b0,
                                resolution[sw_capt].divide_fraction,
                                resolution[sw_capt].divide_integer};
              end
              23:  s_axi_wdata <= 32'b11;
              24: s_axi_wdata <= {4'b0,
                                    resolution[sw_capt].horiz_display_width,
                                    4'b0,
                                    resolution[sw_capt].horiz_display_start};
              25: s_axi_wdata <= {4'b0,
                                    resolution[sw_capt].horiz_total_width,
                                    4'b0,
                                    resolution[sw_capt].horiz_sync_width};
              26: s_axi_wdata <= {4'b0,
                                    resolution[sw_capt].vert_display_width,
                                    4'b0,
                                    resolution[sw_capt].vert_display_start};
              27: s_axi_wdata <= {4'b0,
                                    resolution[sw_capt].vert_total_width,
                                    4'b0,
                                    resolution[sw_capt].vert_sync_width};
              28: s_axi_wdata <= {16'b0, 8'd0, 6'b0,
                                    resolution[sw_capt].hpol,
                                    resolution[sw_capt].vpol};
              29: s_axi_wdata <= '0;
              30: s_axi_wdata <= {18'b0, resolution[sw_capt].pitch};
              31: s_axi_wdata <= 32'b1;
            endcase // case (wr_count)
          end // case: 3'b011
          3'bz10: begin
            s_axi_awvalid <= 2'b10;
            cfg_state     <= CFG_WR1;
          end
          3'bz01: begin
            s_axi_wvalid <= 2'b10;
            cfg_state     <= CFG_WR2;
          end
        endcase // casez ({last_write, s_axi_awready, s_axi_wready})
      end // case: CFG_WR0
      CFG_WR4: begin
        pll_rst       <= '0;
        casez ({last_write[1], s_axi_wready[1]})
          2'b11: begin
            wr_count      <= '0;
            s_axi_awvalid <= '0;
            s_axi_wvalid  <= '0;
            cfg_state     <= CFG_IDLE1;
          end
          2'b01: begin
            wr_count      <= wr_count + 1'b1;
            s_axi_awvalid <= 2'b10;
            s_axi_wvalid  <= 2'b10;
            cfg_state     <= CFG_WR0;
            s_axi_awaddr  <= addr_array[wr_count];
            case (wr_count)
              1, 3, 6, 9, 12, 15, 18, 21: s_axi_wdata <= '0;
              5, 8, 11, 14, 17, 20:       s_axi_wdata <= 32'hA;
              4, 7, 10, 13, 16, 19, 22:   s_axi_wdata <= 32'hC350;
              2: begin
                s_axi_wdata <= {15'b0,
                                resolution[sw_capt].divide_fraction,
                                resolution[sw_capt].divide_integer};
              end
              23:  s_axi_wdata <= 32'b11;
              24: s_axi_wdata <= {4'b0,
                                    resolution[sw_capt].horiz_display_width,
                                    4'b0,
                                    resolution[sw_capt].horiz_display_start};
              25: s_axi_wdata <= {4'b0,
                                    resolution[sw_capt].horiz_total_width,
                                    4'b0,
                                    resolution[sw_capt].horiz_sync_width};
              26: s_axi_wdata <= {4'b0,
                                    resolution[sw_capt].vert_display_width,
                                    4'b0,
                                    resolution[sw_capt].vert_display_start};
              27: s_axi_wdata <= {4'b0,
                                    resolution[sw_capt].vert_total_width,
                                    4'b0,
                                    resolution[sw_capt].vert_sync_width};
              28: s_axi_wdata <= {16'b0, 8'd0, 6'b0,
                                    resolution[sw_capt].hpol,
                                    resolution[sw_capt].vpol};
              29: s_axi_wdata <= '0;
              30: s_axi_wdata <= {18'b0, resolution[sw_capt].pitch};
              31: s_axi_wdata <= 32'b1;
            endcase // case (wr_count)
          end // case: 3'b011
        endcase // casez ({last_write, s_axi_awready, s_axi_wready})
      end // case: CFG_WR1
      CFG_WR5: begin
        pll_rst       <= '0;
        casez ({last_write[1], s_axi_awready[1]})
          2'b11: begin
            wr_count      <= '0;
            s_axi_awvalid <= '0;
            s_axi_wvalid  <= '0;
            cfg_state     <= CFG_IDLE1;
          end
          2'b01: begin
            wr_count      <= wr_count + 1'b1;
            s_axi_awvalid <= 2'b10;
            s_axi_wvalid  <= 2'b10;
            cfg_state     <= CFG_WR0;
            s_axi_awaddr  <= addr_array[wr_count];
            case (wr_count)
              1, 3, 6, 9, 12, 15, 18, 21: s_axi_wdata <= '0;
              5, 8, 11, 14, 17, 20:       s_axi_wdata <= 32'hA;
              4, 7, 10, 13, 16, 19, 22:   s_axi_wdata <= 32'hC350;
              2: begin
                s_axi_wdata <= {15'b0,
                                resolution[sw_capt].divide_fraction,
                                resolution[sw_capt].divide_integer};
              end
              23: s_axi_wdata <= 32'b11;
              24: s_axi_wdata <= {4'b0,
                                    resolution[sw_capt].horiz_display_width,
                                    4'b0,
                                    resolution[sw_capt].horiz_display_start};
              25: s_axi_wdata <= {4'b0,
                                    resolution[sw_capt].horiz_total_width,
                                    4'b0,
                                    resolution[sw_capt].horiz_sync_width};
              26: s_axi_wdata <= {4'b0,
                                    resolution[sw_capt].vert_display_width,
                                    4'b0,
                                    resolution[sw_capt].vert_display_start};
              27: s_axi_wdata <= {4'b0,
                                    resolution[sw_capt].vert_total_width,
                                    4'b0,
                                    resolution[sw_capt].vert_sync_width};
              28: s_axi_wdata <= {16'b0, 8'd0, 6'b0,
                                    resolution[sw_capt].hpol,
                                    resolution[sw_capt].vpol};
              29: s_axi_wdata <= '0;
              30: s_axi_wdata <= {18'b0, resolution[sw_capt].pitch};
              31: s_axi_wdata <= 32'b1;
            endcase // case (wr_count)
          end // case: 3'b011
        endcase // casez ({last_write, s_axi_awready, s_axi_wready})
      end // case: CFG_WR1
    endcase // case (cfg_state)
  end // always @ (posedge mc_clk)

  // State machine to load initial text
  // 1. Clear screen
  // 2. Draw the text on the first 8 scanlines
  logic done;
  typedef enum bit [3:0]
               {
                TEXT_IDLE,
                TEXT_CLR[3],
                TEXT_WRITE[6]
                } text_sm_t;

  (* mark_debug = "true" *) text_sm_t text_sm;

  initial begin
    text_sm = TEXT_IDLE;
  end

  logic [25:0]      total_page;
  logic [2:0][3:0]  char_x;
  logic [12:0]      real_pitch;
  logic [15:0][7:0] capt_text;
  logic [26:0]      y_offset;

  always @(posedge ui_clk) begin
    update_text_sync <= update_text_sync << 1 | update_text;
    s_ddr_awvalid    <= '0;
    done             <= s_ddr_awaddr >= total_page;
    char_x[1]        <= char_x[0];
    char_x[2]        <= char_x[1];
    real_pitch       <= {resolution[sw_capt].pitch[12:4], 4'b0} +
                        |resolution[sw_capt].pitch[3:0];
    clear_ps2        <= '0;
    case (text_sm)
      TEXT_IDLE: begin
        char_x        <= '0;
        char_y        <= '0;
        if (^update_text_sync[2:1]) begin
          // Clear the screen
          res_text_capt <= res_text[sw_capt];
          total_page <= resolution[sw_capt].vert_display_width *
                        real_pitch;
          y_offset      <= '0;
          s_ddr_awaddr  <= '0;
          s_ddr_awvalid <= '1;
          s_ddr_wdata   <= '0;
          s_ddr_wstrb   <= '1;
          s_ddr_wlast   <= '1;
          s_ddr_wvalid  <= '1;
          char_index    <= res_text[sw_capt][0];
          capt_text     <= res_text[sw_capt];
          text_sm       <= TEXT_CLR0;
        end else if (update_ps2) begin // if (^update_text_sync[2:1])
          // We'll start the PS2 output on line 8
          y_offset      <= 8 * real_pitch;
          clear_ps2     <= '1;
          char_index    <= ps2_data_store[0];
          capt_text     <= ps2_data_store;
          s_ddr_awvalid <= '0;
          s_ddr_wvalid  <= '0;
          text_sm       <= TEXT_WRITE0;
        end
      end // case: TEXT_IDLE
      TEXT_CLR0: begin
        casez ({done, s_ddr_awready, s_ddr_wready})
          3'b111: begin
            s_ddr_awvalid <= '0;
            s_ddr_wvalid  <= '0;
            text_sm       <= TEXT_WRITE0;
          end
          3'b011: begin
            s_ddr_awaddr  <= s_ddr_awaddr + 16;
            s_ddr_awvalid <= '1;
            s_ddr_wvalid  <= '1;
            text_sm       <= TEXT_CLR0;
          end
          3'b010: begin
            s_ddr_awvalid <= '0;
            s_ddr_wvalid  <= '1;
            text_sm       <= TEXT_CLR1;
          end
          3'b001: begin
            s_ddr_awvalid <= '1;
            s_ddr_wvalid  <= '0;
            text_sm       <= TEXT_CLR2;
          end
        endcase // casez ({done, s_ddr_awready, s_ddr_wready})
      end
      TEXT_CLR1: begin
        casez ({done, s_ddr_wready})
          2'b11: begin
            s_ddr_awvalid <= '0;
            s_ddr_wvalid  <= '0;
            text_sm       <= TEXT_WRITE0;
          end
          2'b01: begin
            s_ddr_awaddr  <= s_ddr_awaddr + 16;
            s_ddr_awvalid <= '1;
            s_ddr_wvalid  <= '1;
            text_sm       <= TEXT_CLR0;
          end
        endcase // casez ({done, s_ddr_awready, s_ddr_wready})
      end
      TEXT_CLR2: begin
        casez ({done, s_ddr_awready})
          2'b11: begin
            s_ddr_awvalid <= '0;
            s_ddr_wvalid  <= '0;
            text_sm       <= TEXT_WRITE0;
          end
          2'b01: begin
            s_ddr_awaddr  <= s_ddr_awaddr + 16;
            s_ddr_awvalid <= '1;
            s_ddr_wvalid  <= '1;
            text_sm       <= TEXT_CLR0;
          end
        endcase // casez ({done, s_ddr_awready, s_ddr_wready})
      end // case: TEXT_CLR2
      TEXT_WRITE0: begin
        char_index               <= capt_text[char_x[0]];
        char_x[0]                <= char_x[0] + 1'b1;
        text_sm                  <= TEXT_WRITE1;
      end
      TEXT_WRITE1: begin
        char_x[0]                   <= char_x[0] + 1'b1;
        char_index                  <= capt_text[char_x[0]];
        s_ddr_wdata[char_x[2]*8+:8] <= char_slice;
        s_ddr_awaddr                <= char_y * real_pitch + y_offset;
        if (&char_x[2]) begin
          s_ddr_awvalid <= '1;
          s_ddr_wvalid  <= '1;
          text_sm       <= TEXT_WRITE2;
        end else begin
          text_sm       <= TEXT_WRITE1;
        end
      end
      TEXT_WRITE2: begin
        casez ({&char_y, s_ddr_awready, s_ddr_wready})
          3'b111: begin
            s_ddr_awvalid <= '0;
            s_ddr_wvalid  <= '0;
            text_sm       <= TEXT_IDLE;
          end
          3'b011: begin
            char_x        <= '0;
            char_y        <= char_y + 1'b1;
            s_ddr_awvalid <= '0;
            s_ddr_wvalid  <= '0;
            text_sm       <= TEXT_WRITE0;
          end
          3'b010: begin
            s_ddr_awvalid <= '0;
            s_ddr_wvalid  <= '1;
            text_sm       <= TEXT_WRITE3;
          end
          3'b001: begin
            s_ddr_awvalid <= '1;
            s_ddr_wvalid  <= '0;
            text_sm       <= TEXT_WRITE4;
          end
        endcase // casez ({done, s_ddr_awready, s_ddr_wready})
      end
      TEXT_WRITE3: begin
        casez ({&char_y, s_ddr_wready})
          2'b11: begin
            s_ddr_awvalid <= '0;
            s_ddr_wvalid  <= '0;
            text_sm       <= TEXT_IDLE;
          end
          2'b01: begin
            char_x        <= '0;
            char_y        <= char_y + 1'b1;
            s_ddr_awvalid <= '0;
            s_ddr_wvalid  <= '0;
            text_sm       <= TEXT_WRITE0;
          end
        endcase // casez ({done, s_ddr_awready, s_ddr_wready})
      end
      TEXT_WRITE4: begin
        casez ({done, s_ddr_awready})
          2'b11: begin
            s_ddr_awvalid <= '0;
            s_ddr_wvalid  <= '0;
            text_sm       <= TEXT_IDLE;
          end
          2'b01: begin
            char_x        <= '0;
            char_y        <= char_y + 1'b1;
            s_ddr_awvalid <= '0;
            s_ddr_wvalid  <= '0;
            text_sm       <= TEXT_WRITE0;
          end
        endcase // casez ({done, s_ddr_awready, s_ddr_wready})
      end // case: TEXT_CLR2
    endcase // case (text_sm)
  end // always @ (posedge ui_clk)

  (* mark_debug = "TRUE" *) logic [7:0]  ps2_rx_data;
  logic        ps2_rx_user;
  (* mark_debug = "TRUE" *) logic        ps2_rx_valid;
  logic        ps2_rx_err;
  // PS/2 interface
  ps2_host
    #
    (
     .CLK_PER          (5),
     .CYCLES           (32)
     )
  u_ps2_host
    (
     .clk              (clk200),
     .reset            (clk200_reset),

     .ps2_clk          (ps2_clk),
     .ps2_data         (ps2_data),

     .tx_valid         (1'b0),
     .tx_data          (8'b0),
     .tx_ready         (),

     .rx_data          (ps2_rx_data),
     .rx_user          (ps2_rx_err),
     .rx_valid         (ps2_rx_valid),
     .rx_ready         (1'b1)
     );

  // Clock crossing logic
  initial begin
    ps2_toggle     = '0;
    for (int i = 0; i < 16; i++)
      ps2_data_store[i] = i;
  end

  // toggle sync and capture the data
  always @(posedge clk200) begin
    if (ps2_rx_valid) begin
      ps2_toggle    <= ~ps2_toggle;
      ps2_data_capt <= '{data: ps2_rx_data, error: ps2_rx_err};
    end
  end

  // synchronize data on the UI clock
  always @(posedge ui_clk) begin
    ps2_sync <= ps2_sync << 1 | ps2_toggle;

    if (clear_ps2) begin
      update_ps2 <= '0;
    end
    if (^ps2_sync[2:1]) begin
      update_ps2 <= '1;
      for (int i = PS2_DEPTH-1; i >= 0; i--) begin
        if (i == 0) begin
          for (int j = 1; j >= 0; j--) begin
            case (ps2_data_capt.data[j*4+:4])
              0:  ps2_data_store[i*2+j] <= 8'h30;
              1:  ps2_data_store[i*2+j] <= 8'h31;
              2:  ps2_data_store[i*2+j] <= 8'h32;
              3:  ps2_data_store[i*2+j] <= 8'h33;
              4:  ps2_data_store[i*2+j] <= 8'h34;
              5:  ps2_data_store[i*2+j] <= 8'h35;
              6:  ps2_data_store[i*2+j] <= 8'h36;
              7:  ps2_data_store[i*2+j] <= 8'h37;
              8:  ps2_data_store[i*2+j] <= 8'h38;
              9:  ps2_data_store[i*2+j] <= 8'h39;
              10: ps2_data_store[i*2+j] <= 8'h41;
              11: ps2_data_store[i*2+j] <= 8'h42;
              12: ps2_data_store[i*2+j] <= 8'h43;
              13: ps2_data_store[i*2+j] <= 8'h44;
              14: ps2_data_store[i*2+j] <= 8'h45;
              15: ps2_data_store[i*2+j] <= 8'h46;
            endcase // case (ps2_data_capt[i*4+:4])
          end
        end else begin
          ps2_data_store[i*2+:2] <= ps2_data_store[(i-1)*2+:2];
        end
      end // for (int i = 0; i < PS2_DEPTH; i++)
      /*
      for (int i = 0; i < PS2_DEPTH; i++) begin
        if (i == PS2_DEPTH-1) begin
          for (int j = 1; j >= 0; j--) begin
            case (ps2_data_capt.data[j*4+:4])
              0:  ps2_data_store[i*2+j] <= 8'h30;
              1:  ps2_data_store[i*2+j] <= 8'h31;
              2:  ps2_data_store[i*2+j] <= 8'h32;
              3:  ps2_data_store[i*2+j] <= 8'h33;
              4:  ps2_data_store[i*2+j] <= 8'h34;
              5:  ps2_data_store[i*2+j] <= 8'h35;
              6:  ps2_data_store[i*2+j] <= 8'h36;
              7:  ps2_data_store[i*2+j] <= 8'h37;
              8:  ps2_data_store[i*2+j] <= 8'h38;
              9:  ps2_data_store[i*2+j] <= 8'h39;
              10: ps2_data_store[i*2+j] <= 8'h41;
              11: ps2_data_store[i*2+j] <= 8'h42;
              12: ps2_data_store[i*2+j] <= 8'h43;
              13: ps2_data_store[i*2+j] <= 8'h44;
              14: ps2_data_store[i*2+j] <= 8'h45;
              15: ps2_data_store[i*2+j] <= 8'h46;
            endcase // case (ps2_data_capt[i*4+:4])
          end
        end else begin
          ps2_data_store[i*2+:2] <= ps2_data_store[(i+1)*2+:2];
        end
      end
       */
    end
  end // always @ (posedge ui_clk)

endmodule // vga
