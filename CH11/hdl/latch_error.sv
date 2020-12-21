module latch_error
  (
   input wire         clk,
   input wire [0:0]   SW,
   output logic [0:0] LED
   );

  always_latch
    if (clk) LED[0] = SW[0];
endmodule // latch_error
