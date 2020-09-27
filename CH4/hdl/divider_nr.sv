`timescale 1ns/10ps
module divider_nr
  #
  (
   parameter BITS      = 16
   )
  (
   input wire                       clk,
   input wire                       start,
   input wire unsigned [BITS-1:0]   dividend,
   input wire unsigned [BITS-1:0]   divisor,

   output logic                     done,
   output logic unsigned [BITS-1:0] quotient,
   output logic unsigned [BITS-1:0] remainder
   );

  localparam BC = $clog2(BITS);
  logic [BC:0]                    num_bits_w;
  logic [BC:0]                    num_bits;
  logic signed [BITS:0]           int_remainder; // Sized with additional sign

  enum bit [3:0]
               {
                IDLE,
                INIT,
                LEFT_SHIFT,
                TEST_REMAINDER[2],
                ADJ_REMAINDER[3],
                UPDATE_QUOTIENT,
                TEST_N,
                DIV_DONE
                } state;

  initial begin
    state = IDLE;
  end

  always @(posedge clk) begin
    done <= '0;
    case (state)
      IDLE: begin
        if (start) state <= INIT;
      end
      INIT: begin
        state         <= LEFT_SHIFT;
        quotient      <= dividend << (BITS - num_bits_w);
        int_remainder <= '0;
        num_bits      <= num_bits_w;
      end
      LEFT_SHIFT: begin
        {int_remainder, quotient} <= {int_remainder, quotient} << 1;
        if (int_remainder[$left(int_remainder)])
          state   <= ADJ_REMAINDER0;
        else
          state   <= ADJ_REMAINDER1;
      end
      ADJ_REMAINDER0: begin
        state     <= UPDATE_QUOTIENT;
        int_remainder <= int_remainder + divisor;
      end
      ADJ_REMAINDER1: begin
        state     <= UPDATE_QUOTIENT;
        int_remainder <= int_remainder - divisor;
      end
      UPDATE_QUOTIENT: begin
        state       <= TEST_N;
        quotient[0] <= ~int_remainder[$left(int_remainder)];
        num_bits    <= num_bits - 1'b1;
      end
      TEST_N: begin
        if (|num_bits)
          state <= LEFT_SHIFT;
        else
          state <= TEST_REMAINDER1;
      end
      TEST_REMAINDER1: begin
        if (int_remainder[$left(int_remainder)])
          state   <= ADJ_REMAINDER2;
        else
          state   <= DIV_DONE;
      end
      ADJ_REMAINDER2: begin
        state     <= DIV_DONE;
        int_remainder <= int_remainder + divisor;
      end
      DIV_DONE: begin
        done <= '1;
        state    <= IDLE;
      end
    endcase // case (state)
  end
  assign remainder = int_remainder[BITS-1:0];

  leading_ones
    #
    (
     .SELECTOR  ("DOWN_FOR"),
     .BITS      (BITS)
     )
  u_leading_ones
    (
     .SW        (dividend),
     .LED       (num_bits_w)
     );

endmodule
