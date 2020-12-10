`timescale 1ns/10ps
module pdm_inputs
  #
  (
   parameter          CLK_FREQ    = 100,    // Mhz
   parameter          SAMPLE_RATE = 2400000 // Hz
   )
  (
   input wire         clk, // 100Mhz

   // Microphone interface
   output logic       m_clk,
   output logic       m_clk_en,
   input wire         m_data,

   // Amplitude outputs
   output logic [6:0] amplitude,
   output logic       amplitude_valid
   );

  localparam CLK_COUNT = int'((CLK_FREQ*1000000)/(SAMPLE_RATE*2));

  logic [6:0]                        counter;
  logic [1:0][7:0]                   sample_counter;
  logic [1:0]                        en_chan;
  logic [$clog2(CLK_COUNT)-1:0]      clk_counter;

  initial begin
    sample_counter = '0;
    counter        = '0;
    en_chan        = 2'b01;
    m_clk          = '0;
    clk_counter    = '0;
  end

  always @(posedge clk) begin
    amplitude_valid <= '0;
    m_clk_en        <= '0;

    if (clk_counter == CLK_COUNT - 1) begin
      clk_counter <= '0;
      m_clk       <= ~m_clk;
      m_clk_en    <= ~m_clk;
    end else
      clk_counter <= clk_counter + 1;

    if (m_clk_en) begin
      counter  <= counter + 1'b1;
      sample_counter[0] <= sample_counter[0] + m_data;
      sample_counter[1] <= sample_counter[1] + m_data;

      if (en_chan[1] && counter == 63) begin
        amplitude_valid   <= '1;
        sample_counter[1] <= '0;
        amplitude         <= sample_counter[1] + m_data;
        en_chan[1]        <= '1;
      end
      if (en_chan[0] && counter == 127) begin
        amplitude_valid   <= '1;
        sample_counter[0] <= '0;
        amplitude         <= sample_counter[0] + m_data;
      end
    end
  end // always @ (posedge clk)

endmodule // pdm_input
