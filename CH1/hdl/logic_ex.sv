`timescale 1ns/10ps
module logic_ex
  (
   input  wire  [1:0]    SW,
   output logic [3:0]    LED
   );

  assign LED[0]  = !SW[0];
  assign LED[1]  = SW[1] && SW[0];
  //assign LED[1]  = SW[1] & SW[0];
  //assign LED[1]  = (SW[1] == 1'b1) & (SW[0] == 1'b1);
  //assign LED[1]  = (SW[1] === 1'b1) & (SW[0] === 1'b1);
  //assign LED[1]  = &SW[1:0];
  assign LED[2]  = SW[1] || SW[0];
  //assign LED[2]  = SW[1] | SW[0];
  //assign LED[2]  = (SW[1] == 1'b1) | (SW[0] == 1'b1);
  //assign LED[2]  = (SW[1] === 1'b1) | (SW[0] === 1'b1);
  //assign LED[2]  = |SW[1:0];
  assign LED[3]  = SW[1] ^ SW[0];
  //assign LED[3]  = (SW[1] == 1'b1) ^ (SW[0] == 1'b1);
  //assign LED[3]  = (SW[1] === 1'b1) ^ (SW[0] === 1'b1);
  //assign LED[3]  = ^SW[1:0];
endmodule // logic_ex
