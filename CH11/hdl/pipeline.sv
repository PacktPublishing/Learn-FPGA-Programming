module pipeline
  #
  (
   parameter           PIPELINE = 0
   )
  (
   input wire          clk,
   input wire [15:0]   SW,
   input wire          button_u,
   input wire          button_d,
   input wire          button_l,
   input wire          button_c,

   output logic [15:0] LED
   );

  logic [31:0]             mult_a;
  logic [63:0]             mult_b;
  logic [PIPELINE:0][95:0] result;
  logic [95:0]             result_rotate;
  logic [2:0]              out_count;

  initial begin
    mult_a = '0;
    mult_b = '0;
    result = '0;
  end

  always @(posedge clk) begin
    if (button_u) begin
      {mult_a, mult_b} <= {mult_a, mult_b} << 16 | SW;
    end
  end

  always @(posedge clk) begin
    for (int i = 0; i <= PIPELINE; i++) begin
      if (i == 0) result[0] <= mult_a * mult_b;
      else        result[i] <= result[i-1];
    end
    if (button_l) result_rotate <= result[PIPELINE];
    else result_rotate <= {result_rotate[79:0], result_rotate[95:80]};
  end

  assign LED = result_rotate[15:0];

endmodule // pipeline
