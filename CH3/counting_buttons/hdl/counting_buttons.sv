`timescale 1ns/10ps
module counting_buttons
  #
  (
   parameter MODE         = "DEC", // or "DEC"
   parameter NUM_SEGMENTS = 8,
   parameter CLK_PER      = 10,   // Clock period in ns
   parameter REFR_RATE    = 1000, // Refresh rate in Hz
   parameter ASYNC_BUTTON = "SAFE" // "CLOCK", "NOCLOCK", "SAFE", "DEBOUNCE"
   )
  (
   input wire                      clk,
   input wire                      BTNC,
   input wire                      CPU_RESETN,
   output logic [NUM_SEGMENTS-1:0] anode,
   output logic [7:0]              cathode
   );

  logic [NUM_SEGMENTS-1:0][3:0]       encoded;
  logic [NUM_SEGMENTS-1:0]            digit_point;

  seven_segment
    #
    (
     .NUM_SEGMENTS (NUM_SEGMENTS),
     .CLK_PER      (CLK_PER),   // Clock period in ns
     .REFR_RATE    (REFR_RATE)  // Refresh rate in Hz
     )
  u_7seg
    (
     .clk          (clk),
     .encoded      (encoded),
     .digit_point  (digit_point),
     .anode        (anode),
     .cathode      (cathode)
     );

  // Capture the rising edge of button press
  logic                               last_button;
  logic                               button;
  (* mark_debug = "true" *) logic                               button_down;

  initial begin
    last_button = '0;
    button      = '0;
    button_down = '0;
  end

  generate
    if (ASYNC_BUTTON == "SAFE") begin : g_CLOCK
      (* ASYNC_REG = "TRUE", mark_debug = "true" *) logic [2:0] button_sync;
      always @(posedge clk) begin
        button_down <= '0;
        button_sync <= button_sync << 1 | BTNC;
        if (button_sync[2:1] == 2'b01) button_down <= '1;
        else button_down <= '0;
      end
    end else if (ASYNC_BUTTON == "DEBOUNCE") begin : g_CLOCK
      (* ASYNC_REG = "TRUE", mark_debug = "true" *) logic [2:0] button_sync;
      (* mark_debug = "true" *) logic       counter_en;
      (* mark_debug = "true" *) logic [7:0] counter;

      always @(posedge clk) begin
        button_down <= '0;
        button_sync <= button_sync << 1 | BTNC;
        if (button_sync[2:1] == 2'b01) counter_en <= '1;
        else if (~button_sync[1])      counter_en <= '0;

        if (counter_en) begin
          counter <= counter + 1'b1;
          if (&counter) begin
            counter_en <= '0;
            counter    <= '0;
            button_down <= '1;
          end
        end
      end
    end else begin : g_NOCLOCK
      always @(posedge clk) begin
        last_button                             <= button;
        button                                  <= BTNC;
        if (BTNC & ~button) button_down <= '1;
        else button_down <= '0;
      end
    end
  endgenerate

  initial begin
    encoded     = '0;
    digit_point = '1;
  end

  always @(posedge clk) begin
    if (button_down) encoded <= (MODE == "HEX") ? encoded + 1'b1 : dec_inc(encoded);
    if (~CPU_RESETN) begin
      encoded     <= '0;
      digit_point <= '1;
    end
  end

  // Decimal increment function
  function [NUM_SEGMENTS-1:0][3:0] dec_inc;
    input [NUM_SEGMENTS-1:0][3:0] din;
    bit [3:0]                     next_val;
    bit                           carry_in;
    carry_in = '1;
    for (int i = 0; i < NUM_SEGMENTS; i++) begin
      next_val = din[i] + carry_in;
      if (next_val > 9) begin
        dec_inc[i] = '0;
        carry_in   = '1;
      end else begin
        dec_inc[i] = next_val;
        carry_in   = '0;
      end
    end // for (int i = 0; i < NUM_SEGMENTS; i++)
  endfunction // dec_inc

endmodule // counting_buttons
