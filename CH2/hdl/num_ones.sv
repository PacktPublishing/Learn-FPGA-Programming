`timescale 1ns/10ps
module num_ones
  #
  (
   parameter BITS      = 16
   )
  (
   input wire [BITS-1:0]         SW,
   output logic [$clog2(BITS):0] LED
   );

  always_comb begin
    LED = '0;
    for (int i = $low(SW); i <= $high(SW); i++) begin
      LED += SW[i];
    end
  end
endmodule
