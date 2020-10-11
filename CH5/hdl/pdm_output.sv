`timescale 1ns/10ps
module pdm_output
  (
   input wire        clk, // 100Mhz clock

   // Microphone interface
   input logic [6:0] data_in,
   output logic      data_out
   );

  logic [6:0]        error;

  initial begin
    error     = '0;
    data_out  = '0;
  end

  always @(posedge clk) begin
    if (data_in >= error) begin
      data_out <= '1;
      error    <= error + 127 - data_in;
    end else begin
      data_out <= '0;
      error    <= error - data_in;
    end
  end // always @ (posedge clk)

endmodule // pdm_input
