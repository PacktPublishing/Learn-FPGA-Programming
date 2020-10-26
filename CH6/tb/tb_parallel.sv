`timescale 1ns/10ps
module tb_parallel;
  localparam CLK_PER = 10;

  logic clk;
  logic [255:0][31:0] in_data;
  logic               in_valid;

  logic [63:0]        out_data;
  logic               out_valid;

  initial clk = '0;
  always begin
    clk = #(CLK_PER/2) ~clk;
  end

  parallel u_parallel
    (
     .*
     );

endmodule
