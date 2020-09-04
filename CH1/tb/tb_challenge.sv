`timescale 1ns/ 100ps;

module tb;

  logic [2:0] SW;
  logic [1:0] LED;

  challenge u_challenge (.*);

  // Stimulus
  initial begin
    $printtimescale(tb);
    SW = '0;
    for (int i = 0; i < 8; i++) begin
      $display("Setting switches to %3b", i[2:0]);
      SW  = i[2:0];
      #100;
    end
    $display("PASS: logic_ex test PASSED!");
    $stop;
  end

  logic [2:0] sum;
  assign sum = SW[0] + SW[1] + SW[2];
  // Checking
  always @(SW, LED) begin
    if (sum !== LED) begin
      $display("FAIL: Addition mismatch");
      $stop;
    end
  end 
endmodule // tb
