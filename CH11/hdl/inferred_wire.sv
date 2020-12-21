//`default_nettype none
module inferred_wire
  (
   input wire [15:0]  SW,
   output logic [5:0] LED
   );

  //logic [4:0]         add0_out, add1_out;

  adder #(4) u_add0 (.in0(SW[3:0]),  .in1(SW[7:4]),   .out(add0_out));
  adder #(4) u_add1 (.in0(SW[11:8]), .in1(SW[15:12]), .out(add1_out));

  adder #(5) u_add2 (.in0(add0_out), .in1(add1_out),  .out(LED[5:0]));

endmodule // inferred_wire

module adder
  #
  (
   parameter WIDTH = 8
   )
  (
   input wire [WIDTH-1:0] in0, in1,
   output logic [WIDTH:0] out
   );

  assign out = in0 + in1;
endmodule // adder
//`default_nettype wire
