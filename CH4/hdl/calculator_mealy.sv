`timescale 1ns/10ps
module calculator_mealy
  #
  (
   parameter BITS = 32
   )
  (
   input wire               clk,
   input wire               start,
   input wire [4:0]         buttons,
   input wire signed [15:0] switch,

   output logic             done,
   output logic [BITS-1:0]  accum
   );

  import calculator_pkg::*;

  localparam BC     = $clog2(BITS);

  (* mark_debug = "true" *) logic [4:0]       last_op;
  (* mark_debug = "true" *) logic [BITS-1:0]  accumulator;

  typedef enum bit
               {
                IDLE,
                WAIT4BUTTON
                } state_t;

  (* mark_debug = "true" *) state_t state;
  initial begin
    state = IDLE;
  end

  always @(posedge clk) begin
    done <= '0;
    case (state)
      IDLE: begin
        // Wait for data to be operated on to be entered. Then the user presses
        // The operation, add, sub, multiply, clear or equal
        accumulator <= '0;
        last_op     <= buttons; // operation to perform
        accumulator <= switch;
        if (start) state <= buttons[DOWN] ? IDLE : WAIT4BUTTON;
      end
      WAIT4BUTTON: begin
        // wait for second data to be entered, then user presses next operation.
        // In this case, if we get an =, we perform the operation and we're
        // done. The user can also put in another operation to perform with
        // a new value on the accumulator.
        if (start) begin
          last_op <= buttons; // Store our last operation
          case (1'b1)
            last_op[UP]:    accumulator <= accumulator * switch;
            last_op[DOWN]:  state       <= IDLE;
            last_op[LEFT]:  accumulator <= accumulator + switch;
            last_op[RIGHT]: accumulator <= accumulator - switch;
            default:        state       <= WAIT4BUTTON;
          endcase // case (1'b1)
        end else state <= WAIT4BUTTON;
      end
    endcase // case (state)
  end

  assign accum = accumulator;

endmodule
