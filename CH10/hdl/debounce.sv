module debounce
  #
  (
  parameter     CYCLES = 16
   )
  (
   input wire   clk,
   input wire   reset,

   input wire   sig_in,
   output logic sig_out
   );

  logic [$clog2(CYCLES):0] cycle_count;
  logic                    current_state;
  (* async_reg = "TRUE" *) logic [1:0] sig_in_sync;

  initial begin
    current_state = '0;
    cycle_count   = '0;
    sig_out       = '0;
    sig_in_sync   = '0;
  end

  always @(posedge clk) begin
    sig_in_sync <= sig_in_sync << 1 | sig_in;
    if (sig_in_sync[1] != current_state) begin
      current_state            <= sig_in_sync;
      cycle_count              <= '0;
    end else if (cycle_count == CYCLES) begin
      cycle_count            <= '0;
      sig_out                <= current_state;
    end else begin
      cycle_count            <= cycle_count + 1'b1;
    end
    if (reset) begin
      current_state <= '0;
      cycle_count   <= '0;
      sig_out       <= '0;
    end
  end
endmodule // debounce
