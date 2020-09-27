`timescale 1ns/10ps
module traffic_light
  #
  (
   parameter  CLK_PER = 10
   )
  (
   input wire                        clk,
   input wire [1:0]                  SW,

   output logic [1:0]                R,
   output logic [1:0]                G,
   output logic [1:0]                B
   );

  localparam COUNT_1S  = int'(100000000 / CLK_PER);
  localparam COUNT_10S = 10 * int'(100000000 / CLK_PER);

  bit [$clog2(COUNT_10S)-1:0]        counter;

  typedef enum bit [1:0]
               {
                RED,
                YELLOW,
                GREEN
                }light_t;

  light_t up_down;
  light_t left_right;

  typedef enum bit [2:0]
               {
                INIT_UD_GREEN,
                UD_GREEN_LR_RED,
                UD_YELLOW_LR_RED,
                INIT_UD_RED_LR_GREEN,
                UD_RED_LR_GREEN,
                UD_RED_LR_YELLOW
                } state_t;

  state_t state;

  logic [2:0]  lr_reg;
  logic [2:0]  ud_reg;
  logic        enable_count;
  logic        light_count;

  initial begin
    up_down    = RED;
    left_right = GREEN;
    state      = INIT_UD_GREEN;
    counter    = '0;
  end

  always @(posedge clk) begin
    lr_reg         <= lr_reg << 1 | SW[0];
    ud_reg         <= ud_reg << 1 | SW[1];
    enable_count   <= '0;

    if (enable_count) begin
      counter <= counter + 1'b1;
    end else begin
      counter <= '0;
    end

    case (state)
      INIT_UD_GREEN: begin
        up_down      <= GREEN;
        left_right   <= RED;
        enable_count <= '1;
        if (counter == COUNT_10S) state <= UD_GREEN_LR_RED;
      end
      UD_GREEN_LR_RED: begin
        up_down      <= GREEN;
        left_right   <= RED;
        if (lr_reg[2]) state <= UD_YELLOW_LR_RED;
      end
      UD_YELLOW_LR_RED: begin
        up_down      <= YELLOW;
        left_right   <= RED;
        enable_count <= '1;
        if (counter == COUNT_10S) state <= INIT_UD_RED_LR_GREEN;
      end
      INIT_UD_RED_LR_GREEN: begin
        up_down      <= RED;
        left_right   <= GREEN;
        enable_count <= '1;
        if (counter == COUNT_10S) state <= UD_RED_LR_GREEN;
      end
      UD_RED_LR_GREEN: begin
        up_down      <= RED;
        left_right   <= GREEN;
        if (ud_reg[2]) state <= UD_RED_LR_YELLOW;
      end
      UD_RED_LR_YELLOW: begin
        up_down      <= RED;
        left_right   <= YELLOW;
        enable_count <= '1;
        if (counter == COUNT_10S) state <= INIT_UD_GREEN;
      end
    endcase // case INIT_UD_GREEN
  end // always @ (posedge CLK)

  initial begin
    light_count = '0;
  end

  always @(posedge clk) begin
    light_count <= ~light_count;
    R           <= '0;
    G           <= '0;
    B           <= '0;

    if (light_count) begin
      case (left_right)
        GREEN: begin
          G[0] <= '1;
        end
        YELLOW: begin
          R[0] <= '1;
          G[0] <= '1;
        end
        RED: begin
          R[0] <= '1;
        end
      endcase // case (left_right)
      case (up_down)
        GREEN: begin
          G[1] <= '1;
        end
        YELLOW: begin
          R[1] <= '1;
          G[1] <= '1;
        end
        RED: begin
          R[1] <= '1;
        end
      endcase // case (left_right)
    end
  end
endmodule // calculator_top
