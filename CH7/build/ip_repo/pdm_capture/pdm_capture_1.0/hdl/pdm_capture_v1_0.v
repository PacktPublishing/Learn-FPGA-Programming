`timescale 1 ns / 1 ps

        module pdm_capture_v1_0 #
        (
                // Users to add parameters here
         parameter CLK_FREQ = 100,

                // User parameters ends
                // Do not modify the parameters beyond this line


                // Parameters of Axi Slave Bus Interface S00_AXI
                parameter integer C_S00_AXI_DATA_WIDTH	= 32,
                parameter integer C_S00_AXI_ADDR_WIDTH	= 4
        )
        (
                // Users to add ports here
                // Microphone interface
                output logic        m_clk,
                output logic        m_lr_sel,
                input wire          m_data,

                // User ports ends
                // Do not modify the ports beyond this line


                // Ports of Axi Slave Bus Interface S00_AXI
                input wire  s00_axi_aclk,
                input wire  s00_axi_aresetn,
                input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
                input wire [2 : 0] s00_axi_awprot,
                input wire  s00_axi_awvalid,
                output wire  s00_axi_awready,
                input wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
                input wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
                input wire  s00_axi_wvalid,
                output wire  s00_axi_wready,
                output wire [1 : 0] s00_axi_bresp,
                output wire  s00_axi_bvalid,
                input wire  s00_axi_bready,
                input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
                input wire [2 : 0] s00_axi_arprot,
                input wire  s00_axi_arvalid,
                output wire  s00_axi_arready,
                output wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
                output wire [1 : 0] s00_axi_rresp,
                output wire  s00_axi_rvalid,
                input wire  s00_axi_rready
        );
  logic [6:0]               amplitude;
  logic                     amplitude_valid;
  logic                     start_capt;

// Instantiation of Axi Bus Interface S00_AXI
        pdm_capture_v1_0_S00_AXI # (
                .C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
                .C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
        ) pdm_capture_v1_0_S00_AXI_inst (
                                         .start_capt (start_capt),
                                         .amplitude (amplitude),
                                         .amplitude_valid (amplitude_valid),
                                         .rdaddr (rdaddr),
                .S_AXI_ACLK(s00_axi_aclk),
                .S_AXI_ARESETN(s00_axi_aresetn),
                .S_AXI_AWADDR(s00_axi_awaddr),
                .S_AXI_AWPROT(s00_axi_awprot),
                .S_AXI_AWVALID(s00_axi_awvalid),
                .S_AXI_AWREADY(s00_axi_awready),
                .S_AXI_WDATA(s00_axi_wdata),
                .S_AXI_WSTRB(s00_axi_wstrb),
                .S_AXI_WVALID(s00_axi_wvalid),
                .S_AXI_WREADY(s00_axi_wready),
                .S_AXI_BRESP(s00_axi_bresp),
                .S_AXI_BVALID(s00_axi_bvalid),
                .S_AXI_BREADY(s00_axi_bready),
                .S_AXI_ARADDR(s00_axi_araddr),
                .S_AXI_ARPROT(s00_axi_arprot),
                .S_AXI_ARVALID(s00_axi_arvalid),
                .S_AXI_ARREADY(s00_axi_arready),
                .S_AXI_RDATA(s00_axi_rdata),
                .S_AXI_RRESP(s00_axi_rresp),
                .S_AXI_RVALID(s00_axi_rvalid),
                .S_AXI_RREADY(s00_axi_rready)
        );

        // Add user logic here
  pdm_inputs u_pdm_inputs
    (
     .clk                 (s00_axi_aclk),     // 2.4Mhz

     // Microphone interface
     .m_clk               (m_clk),
     .m_clk_en            (m_clk_en),
     .m_data              (m_data),

     // Amplitude outputs
     .amplitude           (amplitude),
     .amplitude_valid     (amplitude_valid)
     );

  // Capture RAM
  logic [6:0] amplitude_store[16384];
  logic       start_playback;
  logic [13:0] ram_wraddr;
  logic [13:0] ram_rdaddr;
  logic                        ram_we;
  logic [6:0]                  ram_dout;

  initial begin
    ram_rdaddr     = '0;
    ram_wraddr     = '0;
    ram_we         = '0;
    start_capture  = '0;
    start_playback = '0;
  end

  // Capture the Audio data
  always @(posedge clk) begin
    ram_we       <= '0;

    if (start_capt) begin
      start_capture <= '1;
    end else if (start_capture && amplitude_valid) begin
      ram_we                      <= '1;
      ram_wraddr                  <= ram_wraddr + 1'b1;
      if (&ram_wraddr) begin
        start_capture <= '0;
      end
    end
  end // always @ (posedge clk)

  always @(posedge clk) begin
    if (ram_we) amplitude_store[ram_wraddr] <= amplitude;
    ram_dout <= amplitude_store[ram_rdaddr];
  end


        // User logic ends

        endmodule
