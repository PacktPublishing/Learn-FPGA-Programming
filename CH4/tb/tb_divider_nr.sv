`timescale 1ns/10ps
module tb;
  parameter BITS = 16;
  bit             clk;
  bit             start;
  bit [BITS-1:0]  dividend;
  bit [BITS-1:0]  divisor;

  bit             done;
  bit unsigned [BITS-1:0] quotient;
  bit unsigned [BITS-1:0] remainder;

  initial clk = '0;
  always begin
    clk = #5 ~clk;
  end

  divider_nr
  #
  (
   .BITS (BITS)
   )
  u_divider_nr
  (
   .*
   );

  initial begin
    start    = '0;
    dividend = '0;
    divisor  = '0;
    repeat (5) @(posedge clk);
    dividend <= 16'd11;
    divisor  <= 16'd3;
    start    <= '1;
    @(posedge clk);
    start    <= '0;
    while (!done) @(posedge clk);
    repeat (5) @(posedge clk);
    for (int i = 0; i < 100; i++) begin
      dividend <= $random;
      divisor  <= $random;
      start    <= '1;
      @(posedge clk);
      start    <= '0;
      while (!done) @(posedge clk);
      repeat (5) @(posedge clk);
    end
    // test divide by 0
    dividend = '0;
    divisor  = '0;
    start    <= '1;
    @(posedge clk);
    start    <= '0;
    while (!done) @(posedge clk);
    repeat (5) @(posedge clk);

    repeat (5) @(posedge clk);
    $finish;
  end // initial begin

  always @(posedge clk) begin
    if (done &&
        (quotient != dividend/divisor) &&
        (remainder != dividend%divisor)) begin
      $display("failure!");
      $display("quotient:   %d", quotient);
      $display("remainder:  %d", remainder);
      $display("expected Q: %d", dividend/divisor);
      $display("expected R: %d", dividend%divisor);
      $stop;
    end
  end
endmodule // tb
