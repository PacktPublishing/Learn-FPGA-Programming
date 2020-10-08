`timescale 1ns/10ps
module tb;
  parameter BLOCK = "TRUE";
  bit CK;
  bit D;
  bit Q;

  blocking #(.BLOCK(BLOCK)) u0 (.*);

  initial begin
    CK = '0;
    forever CK = #100 ~CK;
  end

  initial begin
    D  = '0;
    repeat (5) @(posedge CK);
    D  <= '1;
    @(posedge CK);
    D  <= '0;
    @(posedge CK);
    D  <= '1;
    @(posedge CK);
    D  <= '0;
    @(posedge CK);
    $finish;
  end
endmodule
