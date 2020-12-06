module tb_final_project;

  logic          clk;
  logic          vga_hsync;
  logic          vga_vsync;
  logic [11:0]   vga_rgb;

  logic [4:0]    SW; // Switches to configure resolution
  logic          button_c;  // Center button
  logic          cpu_resetn;  // When pressed, reset

  // Master memory
  logic          mem_clk;
  logic          mem_reset;

  logic [7:0]    mem_arid;
  logic [31:0]   mem_araddr;
  logic [7:0]    mem_arlen;
  logic [2:0]    mem_arsize;
  logic [1:0]    mem_arburst;
  logic          mem_arlock;
  logic          mem_arvalid;
  logic          mem_arready;

  logic          mem_rready;
  logic [7:0]    mem_rid;
  logic [31:0]   mem_rdata;
  logic [1:0]    mem_rresp;
  logic          mem_rlast;
  logic          mem_rvalid;

  wire [12:0]    ddr2_addr;
  wire [2:0]     ddr2_ba;
  wire           ddr2_cas_n;
  wire [0:0]     ddr2_ck_n;
  wire [0:0]     ddr2_ck_p;
  wire [0:0]     ddr2_cke;
  wire           ddr2_ras_n;
  wire           ddr2_we_n;
  wire [15:0]    ddr2_dq;
  wire [1:0]     ddr2_dqs_n;
  wire [1:0]     ddr2_dqs_p;

  wire [0:0]     ddr2_cs_n;
  wire [1:0]     ddr2_dm;
  wire [0:0]     ddr2_odt;

  tri1           ps2_clk;
  tri1           ps2_data;

  initial clk = '0;
  always begin
    clk = #5 ~clk;
  end

  final_project u_vga
    (
     .*
     );

  ddr2_model u_ddr2_model
    (
     .ck        (ddr2_ck_p),
     .ck_n      (ddr2_ck_n),
     .cke       (ddr2_cke),
     .cs_n      (ddr2_cs_n),
     .ras_n     (ddr2_ras_n),
     .cas_n     (ddr2_cas_n),
     .we_n      (ddr2_we_n),
     .dm_rdqs   (ddr2_dm),
     .ba        (ddr2_ba),
     .addr      (ddr2_addr),
     .dq        (ddr2_dq),
     .dqs       (ddr2_dqs_p),
     .dqs_n     (ddr2_dqs_n),
     .rdqs_n    (),
     .odt       (ddr2_odt)
     );

  initial begin
    SW       <= 8;
    button_c <= '1;
    repeat (1000) @(posedge clk);
    while (~u_vga.init_calib_complete) @(posedge clk);
    $display("DDR calibration complete");
    while (~u_vga.locked) @(posedge clk);
    //button_c <= '1;
    repeat (100) @(posedge clk);
    button_c <= '0;
    repeat (10000) @(posedge clk);
  end

endmodule // tb_sv
