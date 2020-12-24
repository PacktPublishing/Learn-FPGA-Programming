`timescale 1ns/ 10ps
module tb_ps2;

  parameter     CYCLES  = 16;
  parameter     CLK_PER = 10;

  logic       clk;
  logic       reset;

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
     .reset     (reset),

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

  logic done;
  int   valid_count;
  logic [7:0] exp_data;
  logic       exp_user;
  logic [3:0] edge_count;
  logic [10:0] data_capt;

  initial begin
    reset       = '0;
    rx_ready    = '1;
    ps2_clk0    = '0;
    ps2_data0   = '0;
    valid_count = '0;
    done        = '0;
    fork
      begin
        // 0: send self test passed
        repeat (100) @(posedge clk);
        send_key(8'hAA, 1'b0);
        // Wait for response
        rx_key(8'hED);

        // 1: send 00
        repeat (100) @(posedge clk);
        send_key(8'hFA, 1'b0);
        // Wait for response
        rx_key(8'h00);

        // 2: send f2
        repeat (100) @(posedge clk);
        send_key(8'hFA, 1'b0);
        // Wait for response
        rx_key(8'hF2);

        // 3: send fA, AB
        repeat (100) @(posedge clk);
        send_key(8'hFA, 1'b0);
        send_key(8'hAB, 1'b0);
        // Wait for response
        rx_key(8'hED);

        // 4: send fA
        repeat (100) @(posedge clk);
        send_key(8'hFA, 1'b0);
        // Wait for response
        rx_key(8'h02);

        // 5: send fA
        repeat (100) @(posedge clk);
        send_key(8'hFA, 1'b0);
        // Wait for response
        rx_key(8'hF3);

        // 6: send fA
        repeat (100) @(posedge clk);
        send_key(8'hFA, 1'b0);
        // Wait for response
        rx_key(8'h20);

        // 7: send fA
        repeat (100) @(posedge clk);
        send_key(8'hFA, 1'b0);
        // Wait for response
        rx_key(8'hF4);

        // 8: send fA
        repeat (100) @(posedge clk);
        send_key(8'hFA, 1'b0);
        // Wait for response
        rx_key(8'hF3);

        // 9: send fA
        repeat (100) @(posedge clk);
        send_key(8'hFA, 1'b0);
        // Wait for response
        rx_key(8'h00);

        repeat (100) @(posedge clk);
        send_key(8'h55, 1'b0);
        repeat (100) @(posedge clk);
        send_key(8'hAA, 1'b0);
        repeat (100) @(posedge clk);
        send_key(8'h55, 1'b1);
        repeat (100) @(posedge clk);
        send_key(8'hAA, 1'b1);
        repeat (100) @(posedge clk);
        while (!done) @(posedge clk);
      end // fork begin
      begin
        while (~done) begin
          while (!rx_valid) @(posedge clk);
          case (valid_count)
            11: begin
              exp_data = 8'h55;
              exp_user = '0;
            end
            12: begin
              exp_data = 8'hAA;
              exp_user = '0;
            end
            13: begin
              exp_data = 8'h55;
              exp_user = '1;
            end
            14: begin
              exp_data = 8'hAA;
              exp_user = '1;
              done = '1;
            end
          endcase // case (valid_count)
          if ((exp_data != rx_data) ||
              (exp_user != rx_user)) begin
            $display("mismatch on output %d", valid_count);
            $stop;
          end else begin
            $display("output matched %d", valid_count);
          end
          valid_count++;
          @(posedge clk);
        end
      end
    join
    $stop;
  end // initial begin

  task rx_key;
    input [7:0] exp_data;
    begin
        // Wait for ED
        edge_count = '0;
        // Wait for firtst falling edge, then rising edge
        @(negedge ps2_clk);
        @(posedge ps2_clk);
        while (edge_count < 10) begin
          repeat (100) @(posedge clk);
          ps2_clk0 = '1;
          repeat (100) @(posedge clk);
          if (edge_count == 10) ps2_data0 = '1;
          data_capt[edge_count++] <= ps2_data;
          ps2_clk0 = '0;
        end
        repeat (100) @(posedge clk);
        ps2_data0 = '1;
        repeat (100) @(posedge clk);
        ps2_clk0 = '1;
        repeat (100) @(posedge clk);
        ps2_data0 = '0;
        ps2_clk0 = '0;

        repeat (100) @(posedge clk);
        $display("Captured data: %h", data_capt[8:1]);
        if (data_capt[8:1] != exp_data) begin
          $error("Data miscompared! Expected %h != Received %h",
                 exp_data, data_capt[8:1]);
        end 
    end
  endtask // rx_key

  task send_key;
    input [7:0] keycode;
    input       error;
    begin
      ps2_clk0  = '0;
      ps2_data0 = '0;
      repeat (5000/CLK_PER) @(posedge clk);
      // Drive data low
      ps2_data0 = '1;
      repeat (10000/CLK_PER) @(posedge clk);
      // first falling edge of the clock
      ps2_clk0 = '1;
      repeat (20000/CLK_PER) @(posedge clk);
      for (int i = 0; i < 8; i++) begin
        if (keycode[i]) ps2_data0 = '0;
        else            ps2_data0 = '1;
        repeat (20000/CLK_PER) @(posedge clk);
        ps2_clk0   = '0;
        repeat (40000/CLK_PER) @(posedge clk);
        ps2_clk0   = '1;
        repeat (20000/CLK_PER) @(posedge clk);
      end
      // parity
      if (^{keycode, error}) ps2_data0 = '1;
      else                   ps2_data0 = '0;
      repeat (20000/CLK_PER) @(posedge clk);
      ps2_clk0   = '0;
      repeat (40000/CLK_PER) @(posedge clk);
      ps2_clk0   = '1;
      repeat (20000/CLK_PER) @(posedge clk);
      // stop bit
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
