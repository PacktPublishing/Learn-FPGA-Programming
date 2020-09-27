`timescale 1ns/10ps
module calculator_moore
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

  (* mark_debug = "true" *) logic [4:0]       op_store;
  (* mark_debug = "true" *) logic [4:0]       last_op;
  (* mark_debug = "true" *) logic [BITS-1:0]  accumulator;

  typedef enum bit [2:0]
               {
                IDLE,
                WAIT4BUTTON,
                ADD,
                SUB,
                MULT
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
        op_store    <= buttons;
        if (start) begin
          case (1'b1)
            last_op[UP]:     state <= MULT;
            last_op[DOWN]:   state <= IDLE;
            last_op[LEFT]:   state <= ADD;
            last_op[RIGHT]:  state <= SUB;
            default:         state <= WAIT4BUTTON;
          endcase // case (1'b1)
        end else state <= WAIT4BUTTON;
      end
      MULT: begin
        last_op     <= op_store; // Store our last operation
        accumulator <= accumulator * switch;
        state       <= WAIT4BUTTON;
      end
      ADD: begin
        last_op     <= op_store; // Store our last operation
        accumulator <= accumulator + switch;
        state       <= WAIT4BUTTON;
      end
      SUB: begin
        last_op     <= op_store; // Store our last operation
        accumulator <= accumulator - switch;
        state       <= WAIT4BUTTON;
      end
    endcase // case (state)
  end

  assign accum = accumulator;

endmodule
