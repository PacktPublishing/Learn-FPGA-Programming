module tb_debounce;

  parameter     CYCLES  = 16;
  parameter     CLK_PER = 10;

  logic   clk;

  logic   sig_in;
  logic   sig_out;

  initial clk = '0;
  always begin
    clk = #(CLK_PER/2) ~clk;
  end

  debounce
    #
    (
     .CYCLES    (CYCLES)
     )
  u_debounce
    (
     .clk,

     .sig_in,
     .sig_out
     );

  initial begin
    sig_in     = '0;

    // Test that we don't switch states too soon
    for (int i = 0; i < CYCLES; i++) begin
      sig_in     = '1;
      repeat (i) @(posedge clk);
      sig_in     = '0;
      repeat (CYCLES-i) @(posedge clk);
    end
    sig_in     = '1;
    repeat (100)  @(posedge clk);
    for (int i = 0; i < CYCLES; i++) begin
      sig_in     = '0;
      repeat (i) @(posedge clk);
      sig_in     = '1;
      repeat (CYCLES-i) @(posedge clk);
    end
    sig_in     = '0;
    repeat (100)  @(posedge clk);
    $display("Test Finished!");
    $finish;
  end // initial begin
endmodule // tb_debounce
