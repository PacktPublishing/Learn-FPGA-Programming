`timescale 1ns/10ps
module simple_ff
  (
   input wire 	CK,
   input wire 	D,
   output logic Q
   );
  
  always_ff @(posedge CK) Q <= D;
  
endmodule
