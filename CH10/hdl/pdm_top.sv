`timescale 1ns/10ps
module pdm_top
  #
  (
   parameter RAM_SIZE = 16384,
   parameter CLK_FREQ = 100
   )
  (
   input wire          clk, // 100Mhz clock

   // Microphone interface
   output logic        m_clk,
   output logic        m_lr_sel,
   input wire          m_data,

   // Tricolor LED
   output logic        R,
   output logic        G,
   output logic        B,

   // Pushbutton interface
   input logic         BTNU,
   input logic         BTNC,

   // LED Array
   output logic [15:0] LED,

   // PDM output
   output wire         AUD_PWM,
   output wire         AUD_SD
   );

  assign AUD_SD = '1;

  (*mark_debug = "true" *)logic [6:0]         amplitude;
  (*mark_debug = "true" *)logic               amplitude_valid;

  logic [2:0]          button_usync;
  logic [2:0]          button_csync;
  logic                start_capture;
  logic                m_clk_en,              m_clk_en_del;

  assign m_lr_sel = '0;

  pdm_inputs u_pdm_inputs
    (
     .clk                 (clk),     // 2.4Mhz

     // Microphone interface
     .m_clk               (m_clk),
     .m_clk_en            (m_clk_en),
     .m_data              (m_data),

     // Amplitude outputs
     .amplitude           (amplitude),
     .amplitude_valid     (amplitude_valid)
     );

  logic [6:0]         light_count;

  initial light_count = '0;

  // Display using tricolor LED
  always @(posedge clk) begin
    if (m_clk_en) light_count <= light_count + 1'b1;
    B           <= ((40 - amplitude) < light_count);
    R           <= '0;
    G           <= '0;
  end

  // Capture RAM
  logic [6:0] amplitude_store[RAM_SIZE];
  logic       start_playback;
  logic [$clog2(RAM_SIZE)-1:0] ram_wraddr;
  logic [$clog2(RAM_SIZE)-1:0] ram_rdaddr;
  logic                        ram_we;
  logic [6:0]                  ram_dout;
  logic [15:0]                 clr_led;

  initial begin
    ram_rdaddr     = '0;
    ram_wraddr     = '0;
    ram_we         = '0;
    start_capture  = '0;
    start_playback = '0;
    LED            = '0;
    clr_led        = '0;
  end

  // Capture the Audio data
  always @(posedge clk) begin
    button_csync <= button_csync << 1 | BTNC;
    ram_we       <= '0;
    for (int i = 0; i < 16; i++)
      if (clr_led[i]) LED[i] <= '0;

    if (button_csync[2:1] == 2'b01) begin
      start_capture <= '1;
      LED           <= '0;
    end else if (start_capture && amplitude_valid) begin
      LED[ram_wraddr[$clog2(RAM_SIZE)-1:$clog2(RAM_SIZE)-4]] <= '1;
      ram_we                      <= '1;
      ram_wraddr                  <= ram_wraddr + 1'b1;
      if (&ram_wraddr) begin
        start_capture <= '0;
        LED[15]       <= '1;
      end
    end
  end // always @ (posedge clk)

  always @(posedge clk) begin
    if (ram_we) amplitude_store[ram_wraddr] <= amplitude;
    ram_dout <= amplitude_store[ram_rdaddr];
  end

  logic [6:0] amp_capture;
  logic       AUD_PWM_en;
  logic [6:0] amp_counter;
  logic [3:0] clr_addr;
  assign clr_addr = ~ram_rdaddr[$clog2(RAM_SIZE)-1:$clog2(RAM_SIZE)-4];

  // Playback the audio
  always @(posedge clk) begin
    button_usync <= button_usync << 1 | BTNU;
    m_clk_en_del <= m_clk_en;
    clr_led      <= '0;

    if (button_usync[2:1] == 2'b01) begin
      start_playback <= '1;
      ram_rdaddr     <= '0;
    end else if (start_playback && m_clk_en_del) begin
      clr_led[clr_addr] <= '1;
      AUD_PWM_en <= '1;
      if (amplitude_valid) begin
        ram_rdaddr <= ram_rdaddr + 1'b1;
        amp_counter <= 7'd1;
        amp_capture <= ram_dout;
        if (ram_dout != 0) AUD_PWM_en <= '0; // Activate pull up
      end else begin
        amp_counter <= amp_counter + 1'b1;
        if (amp_capture < amp_counter) AUD_PWM_en <= '0; // Activate pull up
      end
      if (&ram_rdaddr) start_playback <= '0;
    end
  end

  assign AUD_PWM = AUD_PWM_en ? '0 : 'z;

endmodule // pdm_top
