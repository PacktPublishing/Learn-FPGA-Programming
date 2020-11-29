`timescale 1ns/ 10ps
module tb_ps2;

  parameter     CYCLES  = 16;
  parameter     CLK_PER = 10;

  logic       clk;

  tri1        ps2_clk;
  tri1        ps2_data;
  logic       ps2_clk0;
  logic       ps2_data0;

  // Transmit data to the keyboard from the FPGA
  logic       tx_valid;
  logic [7:0] tx_data;
  logic       tx_ready;

  // Data from the device to the FPGA
  logic [7:0] rx_data;
  logic       rx_user; // Error indicator
  logic       rx_valid;
  logic       rx_ready;

  initial clk = '0;
  always begin
    clk = #(CLK_PER/2) ~clk;
  end

  assign ps2_clk  = ps2_clk0  ? '0 : 'z;
  assign ps2_data = ps2_data0 ? '0 : 'z;

  ps2_host
    #
    (
     .CLK_PER (CLK_PER)
     )
  u_ps2_host
    (
     .clk       (clk),

     .ps2_clk   (ps2_clk),
     .ps2_data  (ps2_data),

     .tx_valid  (tx_valid),
     .tx_data   (tx_data),
     .tx_ready  (tx_ready),

     .rx_data   (rx_data),
     .rx_user   (rx_user), // Error indicator
     .rx_valid  (rx_valid),
     .rx_ready  (rx_ready)
     );

  initial begin
    rx_ready  = '1;
    ps2_clk0  = '0;
    ps2_data0 = '0;
    repeat (100) @(posedge clk);
    send_key(8'h55, 1'b0);
    repeat (100) @(posedge clk);
    send_key(8'hAA, 1'b0);
    repeat (100) @(posedge clk);
    send_key(8'h55, 1'b1);
    repeat (100) @(posedge clk);
    send_key(8'hAA, 1'b1);
    repeat (100) @(posedge clk);
    $stop;
  end // initial begin

  task send_key;
    input [7:0] keycode;
    input       error;
    begin
      ps2_clk0  = '0;
      ps2_data0 = '0;
      repeat (5000/CLK_PER) @(posedge clk);
      // Drive data low
      $display("Start bit");
      ps2_data0 = '1;
      repeat (10000/CLK_PER) @(posedge clk);
      // first falling edge of the clock
      ps2_clk0 = '1;
      $display($stime, "clock low");
      repeat (20000/CLK_PER) @(posedge clk);
      for (int i = 0; i < 8; i++) begin
        if (keycode[i]) ps2_data0 = '0;
        else            ps2_data0 = '1;
        repeat (20000/CLK_PER) @(posedge clk);
        ps2_clk0   = '0;
        $display($stime, "clock high");
        repeat (40000/CLK_PER) @(posedge clk);
        ps2_clk0   = '1;
        $display($stime, "clock low");
        repeat (20000/CLK_PER) @(posedge clk);
      end
      // parity
      if (^{keycode, error}) ps2_data0 = '0;
      else                   ps2_data0 = '1;
      repeat (20000/CLK_PER) @(posedge clk);
      ps2_clk0   = '0;
      repeat (40000/CLK_PER) @(posedge clk);
      ps2_clk0   = '1;
      repeat (20000/CLK_PER) @(posedge clk);
      // stop bit
      //repeat (20000/CLK_PER) @(posedge clk);
      ps2_data0 = '0;
      repeat (20000/CLK_PER) @(posedge clk);
      ps2_clk0   = '0;
      repeat (40000/CLK_PER) @(posedge clk);
      ps2_clk0   = '1;
      repeat (40000/CLK_PER) @(posedge clk);
      ps2_clk0   = '0;
      repeat (100000/CLK_PER) @(posedge clk);
    end
  endtask // send_key

endmodule // tb_debounce
