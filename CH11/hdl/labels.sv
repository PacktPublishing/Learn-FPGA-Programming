module labels
  (
   input wire         clk,
   input wire         addition,
   input wire         subtraction,
   input wire [7:0]   in0, in1,

   output logic [8:0] dout
   );

  always_ff @(posedge clk) begin
    // mismatched block label
    if (subtraction) begin : l_addition_op
      dout <= in0 - in1;
    end : l_subtraction_op
    // reusing a label
    if (addition) begin : l_addition_op
      dout <= in0 + in1;
    end : l_addition_op
  end
endmodule // labels
