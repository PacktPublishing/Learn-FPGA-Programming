`timescale 1ns/10ps
module seven_segment
  #
  (
   parameter NUM_SEGMENTS = 8,
   parameter CLK_PER      = 10,  // Clock period in ns
   parameter REFR_RATE    = 1000 // Refresh rate in Hz
   )
  (
   input wire                         clk,
   input wire                         seven_segment_tvalid,
   input wire [NUM_SEGMENTS*4-1:0]    seven_segment_tdata,
   input wire [NUM_SEGMENTS-1:0]      seven_segment_tuser,
   output logic [NUM_SEGMENTS-1:0]    anode,
   output logic [7:0]                 cathode
   );

  localparam INTERVAL = int'(100000000 / (CLK_PER * REFR_RATE));

  (* mark_debug = "true" *) logic [$clog2(INTERVAL)-1:0]        refresh_count;
  (* mark_debug = "true" *) logic [$clog2(NUM_SEGMENTS)-1:0]    anode_count;
  (* mark_debug = "true" *) logic [NUM_SEGMENTS-1:0][7:0]       segments;
  (* mark_debug = "true" *) logic [NUM_SEGMENTS-1:0][3:0]       encoded;
  (* mark_debug = "true" *) logic [NUM_SEGMENTS-1:0]            digit_point;

  always @(posedge clk) begin
    if (seven_segment_tvalid) begin
      for (int i = 0; i < NUM_SEGMENTS; i++) begin
        encoded[i]     <= seven_segment_tdata[i*4+:4];
        digit_point[i] <= ~seven_segment_tuser[i];
      end
    end
  end

  cathode_top ct[NUM_SEGMENTS]
    (
     .clk         (clk),
     .encoded     (encoded),
     .digit_point (digit_point),
     .cathode     (segments)
     );

  initial begin
    refresh_count = '0;
    anode_count   = '0;
  end

  always @(posedge clk) begin
    if (refresh_count == INTERVAL) begin
      refresh_count <= '0;
      anode_count   <= anode_count + 1'b1;
    end else refresh_count <= refresh_count + 1'b1;
    anode              <= '1;
    anode[anode_count] <= '0;
    cathode            <= segments[anode_count];
  end

endmodule
