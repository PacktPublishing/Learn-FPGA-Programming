`timescale 1ns/10ps
module mult
  #
  (
   parameter BITS      = 16
   )
  (
   input  wire  [BITS-1:0]        SW,
   output logic signed [BITS-1:0] LED
   );

  logic signed [BITS/2-1:0]       a_in;
  logic signed [BITS/2-1:0]       b_in;

  always_comb begin
    {a_in, b_in} = SW;
    LED = a_in * b_in;
  end
endmodule
