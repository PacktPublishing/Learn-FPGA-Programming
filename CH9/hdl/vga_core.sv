module vga_core
  (
   // Register address
   input wire           reg_clk,
   input wire           reg_reset,

   input wire           reg_awvalid,
   output logic         reg_awready,
   input wire [11:0]    reg_awaddr,

   input wire           reg_wvalid,
   output logic         reg_wready,
   input wire [31:0]    reg_wdata,
   input wire [3:0]     reg_wstrb,

   input wire           reg_bready,
   output logic         reg_bvalid,
   output logic [1:0]   reg_bresp,

   input wire           reg_arvalid,
   output logic         reg_arready,
   input wire [11:0]    reg_araddr,

   input wire           reg_rready,
   output logic         reg_rvalid,
   output logic [31:0]  reg_rdata,
   output logic [1:0]   reg_rresp,

   // Master memory
   input wire           mem_clk,
   input wire           mem_reset,

   output logic [3:0]   mem_arid,
   output logic [26:0]  mem_araddr,
   output logic [7:0]   mem_arlen,
   output logic [2:0]   mem_arsize,
   output logic [1:0]   mem_arburst,
   output logic         mem_arlock,
   output logic         mem_arvalid,
   input wire           mem_arready,

   output logic         mem_rready,
   input wire [3:0]     mem_rid,
   input wire [127:0]   mem_rdata,
   input wire [1:0]     mem_rresp,
   input wire           mem_rlast,
   input wire           mem_rvalid,

   input wire           vga_clk,
   output logic         vga_hsync,
   output logic         vga_hblank,
   output logic         vga_vsync,
   output logic         vga_vblank,
   output logic [23:0]  vga_rgb
   );

  localparam H_DISP_START_WIDTH     = 12'h000;
  localparam H_DISP_FPEND_TOTAL     = 12'h004;
  localparam V_DISP_START_WIDTH     = 12'h008;
  localparam V_DISP_FPEND_TOTAL     = 12'h00C;
  localparam V_DISP_POLARITY_FORMAT = 12'h010;
  localparam DISPLAY_ADDR           = 12'h100;
  localparam DISPLAY_PITCH          = 12'h104;
  localparam VGA_LOAD_MODE          = 12'h108;

  typedef enum bit [1:0]
               {
                REG_IDLE,
                REG_W4ADDR,
                REG_W4DATA,
                REG_BRESP
                } reg_cs_t;

  reg_cs_t reg_cs;

  logic [11:0] reg_addr;
  logic        reg_we;
  logic [31:0] reg_din;
  logic [3:0]  reg_be;
  logic [11:0] horiz_display_start_reg;
  logic [11:0] horiz_display_width_reg;
  logic [11:0] horiz_sync_width_reg;
  logic [11:0] horiz_total_width_reg;
  logic [11:0] vert_display_start_reg;
  logic [11:0] vert_display_width_reg;
  logic [11:0] vert_sync_width_reg;
  logic [11:0] vert_total_width_reg;
  logic [31:0] disp_addr_reg;
  logic [7:0]  pixel_depth_reg;
  logic [1:0]  polarity_reg;
  logic [12:0] pitch_reg;
  logic [11:0] horiz_display_start;
  logic [11:0] horiz_display_width;
  logic [11:0] horiz_sync_width;
  logic [11:0] horiz_total_width;
  logic [11:0] vert_display_start;
  logic [11:0] vert_display_width;
  logic [11:0] vert_sync_width;
  logic [11:0] vert_total_width;
  logic [31:0] disp_addr;
  logic [7:0]  pixel_depth;
  logic [1:0]  polarity;
  logic [12:0] pitch;
  logic        vga_pop;
  logic [127:0] vga_data;
  logic         vga_empty;

  initial begin
    reg_cs = REG_IDLE;
  end

  always @(posedge reg_clk) begin
    reg_we     <= '0;
    reg_bvalid <= '0;

    case (reg_cs)
      REG_IDLE: begin
        reg_awready <= '1;
        reg_wready  <= '1;
        case ({reg_awvalid, reg_awvalid})
          2'b11: begin
            // Addr and data are available
            reg_addr    <= reg_awaddr;
            reg_we      <= '1;
            reg_din     <= reg_wdata;
            reg_be      <= reg_wstrb;
            if (reg_bready) begin
              reg_awready <= '1;
              reg_wready  <= '1;
              reg_bvalid  <= '1;
              reg_bresp   <= '0; // Okay
            end else begin
              reg_awready <= '0;
              reg_wready  <= '0;
              reg_cs      <= REG_BRESP;
            end
          end
          2'b10: begin
            // Address only
            reg_awready <= '0;
            reg_addr    <= reg_awaddr;
            reg_cs      <= REG_W4DATA;
          end
          2'b01: begin
            reg_wready <= '0;
            reg_din    <= reg_wdata;
            reg_be     <= reg_wstrb;
            reg_cs     <= REG_W4ADDR;
          end
        endcase // case ({reg_awvalid, reg_awvalid})
      end // case: REG_IDLE
      REG_W4DATA: begin
        reg_we      <= '1;
        reg_din     <= reg_wdata;
        reg_be      <= reg_wstrb;
        if (reg_bready) begin
          reg_awready <= '1;
          reg_wready  <= '1;
          reg_bvalid  <= '1;
          reg_bresp   <= '0; // Okay
          reg_cs      <= REG_IDLE;
        end else begin
          reg_awready <= '0;
          reg_wready  <= '0;
          reg_cs      <= REG_BRESP;
        end
      end
      REG_W4ADDR: begin
        reg_addr    <= reg_awaddr;
        reg_we      <= '1;
        if (reg_bready) begin
          reg_awready <= '1;
          reg_wready  <= '1;
          reg_bvalid  <= '1;
          reg_bresp   <= '0; // Okay
          reg_cs      <= REG_IDLE;
        end else begin
          reg_awready <= '0;
          reg_wready  <= '0;
          reg_cs      <= REG_BRESP;
        end
      end
      REG_BRESP: begin
        if (reg_bready) begin
          reg_awready <= '1;
          reg_wready  <= '1;
          reg_bvalid  <= '1;
          reg_bresp   <= '0; // Okay
          reg_cs      <= REG_IDLE;
        end else begin
          reg_awready <= '0;
          reg_wready  <= '0;
          reg_cs      <= REG_BRESP;
        end
      end
    endcase // case (reg_cs)
  end // always @ (posedge reg_clk)

  logic       load_mode;
  (* async_reg = "TRUE" *) logic [2:0] load_mode_sync;

  initial begin
    horiz_display_start_reg = 47;
    horiz_display_width_reg = 640;
    horiz_sync_width_reg    = 96;
    horiz_total_width_reg   = 799;
    vert_display_start_reg  = 32;
    //vert_display_start_reg  = 2;
    vert_display_width_reg  = 480;
    vert_sync_width_reg     = 2;
    vert_total_width_reg    = 524;
    disp_addr_reg           = 0;
    polarity_reg            = '0;
    //pitch_reg               = 2046;
    pitch_reg               = 5*16;
    horiz_display_start     = 47;
    horiz_display_width     = 640;
    horiz_sync_width        = 96;
    horiz_total_width       = 799;
    //vert_display_start      = 2;
    vert_display_start      = 32;
    vert_display_width      = 480;
    vert_sync_width         = 2;
    vert_total_width        = 524;
    disp_addr               = 0;
    load_mode               = '0;
    polarity                = '0;
    //pitch                   = 2046;
    pitch                   = 5*16;
  end

  always @(posedge reg_clk) begin
    if (reg_we) begin
      case (reg_addr)
        H_DISP_START_WIDTH: begin
          if (reg_be[0]) horiz_display_start_reg[7:0]  <= reg_din[7:0];
          if (reg_be[1]) horiz_display_start_reg[11:8] <= reg_din[11:8];
          if (reg_be[2]) horiz_display_width_reg[7:0]  <= reg_din[23:16];
          if (reg_be[3]) horiz_display_width_reg[11:8] <= reg_din[27:24];
        end
        H_DISP_FPEND_TOTAL: begin
          if (reg_be[0]) horiz_sync_width_reg[7:0]   <= reg_din[7:0];
          if (reg_be[1]) horiz_sync_width_reg[11:8]  <= reg_din[11:8];
          if (reg_be[2]) horiz_total_width_reg[7:0]  <= reg_din[23:16];
          if (reg_be[3]) horiz_total_width_reg[11:8] <= reg_din[27:24];
        end
        V_DISP_START_WIDTH: begin
          if (reg_be[0]) vert_display_start_reg[7:0]  <= reg_din[7:0];
          if (reg_be[1]) vert_display_start_reg[11:8] <= reg_din[11:8];
          if (reg_be[2]) vert_display_width_reg[7:0]  <= reg_din[23:16];
          if (reg_be[3]) vert_display_width_reg[11:8] <= reg_din[27:24];
        end
        V_DISP_FPEND_TOTAL: begin
          if (reg_be[0]) vert_sync_width_reg[7:0]   <= reg_din[7:0];
          if (reg_be[1]) vert_sync_width_reg[11:8]  <= reg_din[11:8];
          if (reg_be[2]) vert_total_width_reg[7:0]  <= reg_din[23:16];
          if (reg_be[3]) vert_total_width_reg[11:8] <= reg_din[27:24];
        end
        V_DISP_POLARITY_FORMAT: begin
          if (reg_be[0]) polarity_reg[1:0]     <= reg_din[1:0];
          if (reg_be[1]) pixel_depth_reg[7:0]  <= reg_din[15:8];
        end
        DISPLAY_ADDR: begin
          if (reg_be[0]) disp_addr_reg[7:0]    <= reg_din[7:0];
          if (reg_be[1]) disp_addr_reg[15:8]   <= reg_din[15:8];
          if (reg_be[2]) disp_addr_reg[23:16]  <= reg_din[23:16];
          if (reg_be[3]) disp_addr_reg[31:24]  <= reg_din[31:24];
        end
        DISPLAY_PITCH: begin
          if (reg_be[0]) pitch_reg[7:0]        <= reg_din[7:0];
          if (reg_be[1]) pitch_reg[12:8]       <= reg_din[12:8];
        end
        VGA_LOAD_MODE: if (reg_be[0]) load_mode <= ~load_mode;
      endcase // case (reg_addr)
    end // if (reg_we)
  end // always @ (posedge reg_clk)

  logic [11:0] horiz_count;
  logic [11:0] vert_count;
  logic        mc_req;
  logic [7:0]  mc_words;
  logic [31:0] mc_addr;
  logic        fifo_rst;
  logic [31:0] scanline;

  // Timing generation
  initial begin
    horiz_count = '0;
    vert_count  = '0;
    mc_req      = '0;
  end

  logic last_hblank;

  always @(posedge vga_clk) begin
    load_mode_sync <= load_mode_sync << 1 | load_mode;
    if (^load_mode_sync[2:1]) begin
      horiz_display_start <= horiz_display_start_reg;
      horiz_display_width <= horiz_display_width_reg;
      horiz_sync_width    <= horiz_sync_width_reg;
      horiz_total_width   <= horiz_total_width_reg;
      vert_display_start  <= vert_display_start_reg;
      vert_display_width  <= vert_display_width_reg;
      vert_sync_width     <= vert_sync_width_reg;
      vert_total_width    <= vert_total_width_reg;
      disp_addr           <= disp_addr_reg;
      polarity            <= polarity_reg;
      pixel_depth         <= pixel_depth_reg;
      pitch               <= pitch_reg;
    end
    if (horiz_count >= horiz_total_width) begin
      horiz_count <= '0;
      if (vert_count >= vert_total_width) vert_count <= '0;
      else vert_count <= vert_count + 1'b1;
      scanline <= vert_count - vert_display_start + 2;
      mc_addr  <= scanline * pitch;
      mc_words <= pitch[12:4] +|pitch[3:0];
    end else
      horiz_count <= horiz_count + 1'b1;

    if (vga_hblank && ~last_hblank && ~vga_vblank) mc_req   <= ~mc_req;
    last_hblank   <= vga_hblank;

    vga_hblank    <= ~((horiz_count > horiz_display_start) & (horiz_count <= (horiz_display_start + horiz_display_width)));
    vga_hsync     <= polarity[1] ^ ~(horiz_count > (horiz_total_width - horiz_sync_width));

    vga_vblank    <= ~((vert_count > vert_display_start) & (vert_count <= (vert_display_start + vert_display_width)));
    vga_vsync     <= polarity[0] ^ ~(vert_count > (vert_total_width - vert_sync_width));

  end // always @ (posedge vga_clk)

  logic [6:0] pix_count;
  logic        rd_rst_busy;

  enum         bit {SCAN_IDLE, SCAN_OUT} scan_cs;

  initial begin
    scan_cs = SCAN_IDLE;
  end

  always @(posedge vga_clk) begin
    vga_pop <= '0;
    case (scan_cs)
      SCAN_IDLE: begin
        if (horiz_count == horiz_display_start) begin
          if (vga_data[0]) vga_rgb <= ~vga_empty;
          else vga_rgb <= '0;
          scan_cs   <= SCAN_OUT;
          pix_count <= '0;
        end
      end
      SCAN_OUT: begin
        pix_count <= pix_count + 1'b1;
        // Right now just do single bit per pixel
        if (pix_count == 126) begin
          vga_pop <= ~vga_empty;
        end
        if (vga_data[pix_count]) vga_rgb <= '1;
        else vga_rgb <= '0;
        if (rd_rst_busy) scan_cs <= SCAN_IDLE;
      end
    endcase // case (scan_cs)
  end

  logic wr_rst_busy;

  // Pixel FIFO
  // Sized large enough to hold one scanline at 1920x32bpp (480 bytes)
  xpm_fifo_async
    #
    (
     .FIFO_WRITE_DEPTH       (512),
     .WRITE_DATA_WIDTH       (128),
     .READ_MODE              ("fwft")
     )
  u_xpm_fifo_async
    (
     .sleep                  ('0),
     .rst                    (fifo_rst),

     .wr_clk                 (mem_clk),
     .wr_en                  (mem_rvalid),
     .din                    (mem_rdata),
     .full                   (),
     .prog_full              (),
     .wr_data_count          (),
     .overflow               (),
     .wr_rst_busy            (wr_rst_busy),
     .almost_full            (),
     .wr_ack                 (),

     .rd_clk                 (vga_clk),
     .rd_en                  (vga_pop),
     .dout                   (vga_data),
     .empty                  (vga_empty),
     .prog_empty             (),
     .rd_data_count          (),
     .underflow              (),
     .rd_rst_busy            (rd_rst_busy),
     .almost_empty           (),
     .data_valid             (),

     .injectsbiterr          ('0),
     .injectdbiterr          ('0),
     .sbiterr                (),
     .dbiterr                ()
     );

  logic mem_wait;
  typedef enum bit [2:0]
               {
                MEM_IDLE,
                MEM_W4RSTH,
                MEM_W4RSTL,
                MEM_W4RDY[2],
                MEM_REQ} mem_cs_t;

  mem_cs_t mem_cs;

  logic [31:0] next_addr;
  logic [7:0]  len_diff;

  initial begin
    mem_wait    = '0;
    mem_arvalid = '0;
    mem_arid    = '0;
    mem_araddr  = '0;
    mem_arlen   = '0;
    mem_arsize  = 3'b100; // 16 bytes
    mem_arburst = 2'b01; // incrementing
    mem_arlock  = '0;
    mem_arvalid = '0;
    mem_rready  = '1;
    fifo_rst    = '0;
    mem_cs      = MEM_IDLE;
  end

  // memory controller state machine
  (* async_reg = "TRUE" *) logic [2:0]  mc_req_sync;
  always @(posedge mem_clk) begin
    mc_req_sync <= mc_req_sync << 1 | mc_req;
    case (mem_cs)
      MEM_IDLE: begin
        mem_arvalid <= '0;
        if (^mc_req_sync[2:1]) begin
          fifo_rst <= '1;
          mem_cs   <= MEM_W4RSTH;
        end
      end
      MEM_W4RSTH: begin
        next_addr <= mc_addr + {mc_words, 4'b0}; // Look to see if we need to break req
        len_diff  <= 2047 - mc_addr[10:0];
        if (wr_rst_busy) begin
          fifo_rst <= '0;
          mem_cs   <= MEM_W4RSTL;
        end
      end
      MEM_W4RSTL: begin
        if (~wr_rst_busy) begin
          mem_arid    <= '0;
          mem_araddr  <= mc_addr;
          mem_arsize  <= 3'b100; // 16 bytes
          mem_arburst <= 2'b01; // incrementing
          mem_arlock  <= '0;
          mem_arvalid <= '1;
          next_addr   <= mc_addr  + len_diff + 1'b1;
          len_diff    <= mc_words - len_diff;
          if (next_addr[31:11] != mc_addr[31:11]) begin
            // look if we are going to cross 2K boundary
            mem_arlen <= len_diff;
            if (mem_arready)
              mem_cs <= MEM_REQ;
            else
              mem_cs <= MEM_W4RDY1;
          end else begin
            mem_arlen   <= mc_words - 1;
            if (mem_arready)
              mem_cs <= MEM_IDLE;
            else
              mem_cs <= MEM_W4RDY0;
          end // else: !if(next_addr[12])
        end
      end // case: MEM_W4RSTH
      MEM_W4RDY0: begin
        if (mem_arready) begin
          mem_cs      <= MEM_IDLE;
          mem_arvalid <= '0;
        end else
          mem_cs <= MEM_W4RDY0;
      end
      MEM_W4RDY1: begin
        if (mem_arready) begin
          mem_cs      <= MEM_REQ;
          mem_arvalid <= '0;
        end else
          mem_cs <= MEM_W4RDY1;
      end
      MEM_REQ: begin
        if (~wr_rst_busy) begin
          mem_arid    <= '0;
          mem_araddr  <= next_addr;
          mem_arsize  <= 3'b100; // 16 bytes
          mem_arburst <= 2'b01; // incrementing
          mem_arlock  <= '0;
          mem_arvalid <= '1;
          mem_arlen   <= len_diff;
          if (mem_arready)
            mem_cs <= MEM_IDLE;
          else
            mem_cs <= MEM_W4RDY0;
        end
      end // case: MEM_W4RSTH
    endcase
  end
endmodule // vga
