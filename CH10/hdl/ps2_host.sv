module ps2_host
  #
  (
   parameter           CLK_PER = 10,
   parameter           CYCLES  = 16
   )
  (
   input wire          clk,
   input wire          reset,

   inout               ps2_clk,
   inout               ps2_data,

   // Transmit data to the keyboard from the FPGA
   input wire          tx_valid,
   input wire [7:0]    tx_data,
   output logic        tx_ready,

   // Data from the device to the FPGA
   output logic [7:0]  rx_data,
   output logic        rx_user, // Error indicator
   output logic        rx_valid,
   input wire          rx_ready
   );

  (* mark_debug = "TRUE" *) logic ps2_clk_clean,  ps2_clk_clean_last;
  (* mark_debug = "TRUE" *) logic                ps2_data_clean;
  logic                ps2_clk_en;
  logic                ps2_data_en;
  logic [10:0]         data_capture;
  logic [3:0]          data_counter;
  logic                done;
  logic                err;
  logic                tx_xmit;

  // Clean up the signals coming in
  debounce
    #
    (
     .CYCLES   (CYCLES)
     )
  u_debounce[2]
    (
     .clk      (clk),
     .reset    (reset),

     .sig_in   ({ps2_clk,       ps2_data}),
     .sig_out  ({ps2_clk_clean, ps2_data_clean})
     );

  /*
  logic                last_clk;
  (* mark_debug = "TRUE" *) logic [3:0]          clk_count;

  initial begin
    clk_count = '0;
    last_clk  = '0;
  end

  always @(posedge clk) begin
    last_clk <= ps2_clk_clean;
    rx_valid <= '0;
    if (ps2_clk_clean && ~last_clk) begin
      case (clk_count)
        2:rx_data[0] <= ps2_data_clean;
        3:rx_data[1] <= ps2_data_clean;
        4:rx_data[2] <= ps2_data_clean;
        5:rx_data[3] <= ps2_data_clean;
        6:rx_data[4] <= ps2_data_clean;
        7:rx_data[5] <= ps2_data_clean;
        8:rx_data[6] <= ps2_data_clean;
        9:rx_data[7] <= ps2_data_clean;
      endcase // case (clk_count)
      if (clk_count == 10) begin
        clk_count <= '0;
        rx_valid  <= '1;
      end else clk_count <= clk_count + 1'b1;
    end
  end // always @ (posedge clk)
*/

  localparam COUNT_100us = int'(100000/CLK_PER);
  localparam COUNT_20us  = int'(20000/CLK_PER);

  logic [$clog2(COUNT_100us):0] counter_100us;
  logic [$clog2(COUNT_20us):0]  counter_20us;

  // Enable drives a 0 out on the clock or data lines
  assign ps2_clk  = ps2_clk_en  ? '0 : 'z;
  assign ps2_data = ps2_data_en ? '0 : 'z;

  logic [7:0]                   tx_data_capt;

  initial begin
    tx_ready = '1;
  end

  always @(posedge clk) begin
    if (tx_valid && tx_ready) begin
      tx_data_capt <= tx_data;
      tx_ready     <= '0;
    end else if (tx_xmit) begin
      tx_ready <= '1;
    end
  end

  typedef enum bit [3:0]
               {
                IDLE,
                CLK_FALL[2],
                CLK_HIGH,
                XMIT[7]
                } state_t;

  (* mark_debug = "TRUE" *) state_t state;

  typedef enum bit [3:0]
               {
                START_IDLE,
                SEND_CMD,
                START[7]
                } start_state_t;

  start_state_t start_state;

  initial begin
    state       = IDLE;
    start_state = START_IDLE;
  end

  logic send_set;
  logic clr_set;
  logic [7:0] send_data;
  logic [7:0] init_data[10];
  logic [7:0] rx_expect[11];
  logic [3:0] start_count;

  initial begin
    init_data[0] = 8'hED;
    init_data[1] = 8'h00;
    init_data[2] = 8'hF2;
    init_data[3] = 8'hED;
    init_data[4] = 8'h02;
    init_data[5] = 8'hF3;
    init_data[6] = 8'h20;
    init_data[7] = 8'hF4;
    init_data[8] = 8'hF3;
    init_data[9] = 8'h00;
    rx_expect[0] = 8'hAA; // Self test
    rx_expect[1] = 8'hFA; // Ack
    rx_expect[2] = 8'hFA; // Ack
    rx_expect[3] = 8'hAB; // Ack + keyboard code
    rx_expect[4] = 8'hFA; // Ack
    rx_expect[5] = 8'hFA; // Ack
    rx_expect[6] = 8'hFA; // Ack
    rx_expect[7] = 8'hFA; // Ack
    rx_expect[8] = 8'hFA; // Ack
    rx_expect[9] = 8'hFA; // Ack
    rx_expect[10]= 8'hFA; // Ack
    start_count  = '0;
  end

  always @(posedge clk) begin
    case (start_state)
      START_IDLE: begin
        if (rx_valid && rx_data == rx_expect[start_count]) begin
          start_state <= SEND_CMD;
        end
      end
      SEND_CMD: begin
        send_set    <= '1;
        send_data   <= init_data[start_count];
        start_count <= start_count + 1'b1;
        start_state <= START0;
      end
      START0: begin
        if (clr_set) begin
          send_set    <= '0;
          start_state <= START1;
        end
      end
      START1: begin
        if (rx_valid && rx_data == rx_expect[start_count]) begin
          start_state <= (start_count == 10) ? START2 : SEND_CMD;
        end
      end
      /*
      START2: begin
        send_set    <= '1;
        send_data   <= 8'hf4;
        start_state <= START3;
      end
      START3: begin
        if (clr_set) begin
          send_set    <= '0;
          start_state <= START6;
        end
      end
      START4: begin
        if (rx_valid && rx_data == 8'hFA) begin
          start_state <= START5;
        end
      end
      START5: begin
        send_set    <= '1;
        send_data   <= 8'hF2;
        start_state <= START6;
      end
      START6: begin
        if (clr_set) begin
          send_set    <= '0;
          start_state <= START6;
        end
      end
       */
    endcase // case (start_state)
    if (reset) start_state <= START_IDLE;
  end

  logic [10:0] tx_data_out;
  logic        xmit_ready;

  always @(posedge clk) begin
    ps2_clk_en         <= '0;
    ps2_data_en        <= '0;
    done               <= '0;
    err                <= '0;
    tx_xmit            <= '0;
    clr_set            <= '0;
    ps2_clk_clean_last <= ps2_clk_clean;

    case (state)
      IDLE: begin
        // Wait for a falling edge of the clock or we received
        // a xmit request
        if (counter_100us != COUNT_100us) begin
          counter_100us <= counter_100us + 1'b1;
          xmit_ready     <= '0;
        end else begin
          xmit_ready     <= '1;
        end
        data_counter  <= '0;
        if (~ps2_clk_clean && ps2_clk_clean_last) begin
          counter_100us <= '0;
          state <= CLK_FALL0;
        end else if (~tx_ready && xmit_ready) begin
          counter_100us <= '0;
          tx_data_out   <= {1'b1, ~^tx_data,tx_data, 1'b0};
          state         <= XMIT0;
        end else if (send_set && xmit_ready) begin
          clr_set       <= '1;
          counter_100us <= '0;
          tx_data_out   <= {1'b1, ~^send_data, send_data, 1'b0};
          state         <= XMIT0;
        end
      end
      CLK_FALL0: begin
        // capture data
        data_capture <= {ps2_data_clean, data_capture[10:1]};
        data_counter <= data_counter + 1'b1;
        state        <= CLK_FALL1;
      end
      CLK_FALL1: begin
        // Clock has gone low, wait for it to go high
        if (ps2_clk_clean) state <= CLK_HIGH;
      end
      CLK_HIGH: begin
        if (data_counter == 11) begin
          counter_100us <= '0;
          done          <= '1;
          err           <= ~^data_capture[9:1];
          state         <= IDLE;
          end else if (~ps2_clk_clean) state <= CLK_FALL0;
      end
      XMIT0: begin
        clr_set           <= '1;
        ps2_clk_en        <= '1; // Drop the clock
        counter_100us     <= counter_100us + 1'b1;
        if (counter_100us == COUNT_100us) begin
          counter_100us   <= '0;
          state           <= XMIT1;
        end
      end
      XMIT1: begin
        ps2_data_en       <= ~tx_data_out[data_counter];
        ps2_clk_en        <= '1; // Drop the clock
        counter_100us     <= counter_100us + 1'b1;
        if (counter_100us == COUNT_20us) begin
          counter_100us   <= '0;
          state           <= XMIT2;
        end
      end
      XMIT2: begin
        ps2_clk_en        <= '0; // Drop the clock
        ps2_data_en       <= ~tx_data_out[data_counter];
        if (~ps2_clk_clean && ps2_clk_clean_last) begin
          data_counter <= data_counter + 1'b1;
          if (data_counter == 9) state <= XMIT3;
        end
      end
      XMIT3: begin
        if (~ps2_clk_clean && ps2_clk_clean_last) begin
          state <= XMIT4;
        end
      end
      XMIT4: begin
        if (~ps2_data_clean) begin
          state <= XMIT5;
        end
      end
      XMIT5: begin
        if (~ps2_clk_clean) begin
          state <= XMIT6;
        end
      end
      XMIT6: begin
        if (ps2_data_clean && ps2_clk_clean) begin
          state <= IDLE;
        end
      end
      /*
      XMIT0: begin
        clr_set           <= '1;
        ps2_data_en       <= ~tx_data_out[data_counter];
        counter_100us     <= counter_100us + 1'b1;
        if (counter_100us == COUNT_20us) begin
          counter_100us   <= '0;
          state           <= XMIT1;
        end
      end
      XMIT1: begin
        ps2_data_en       <= ~tx_data_out[data_counter];
        ps2_clk_en        <= '0; // Drop the clock
        counter_100us     <= counter_100us + 1'b1;
        if (counter_100us == COUNT_20us) begin
          counter_100us   <= '0;
          state           <= XMIT2;
        end
      end
      XMIT2: begin
        ps2_data_en       <= ~tx_data_out[data_counter];
        ps2_clk_en        <= '1; // Drop the clock
        counter_100us     <= counter_100us + 1'b1;
        if (counter_100us == 2*COUNT_20us) begin
          data_counter    <= data_counter + 1'b1;
          counter_100us   <= '0;
          state           <= (data_counter == 10) ? IDLE : XMIT0;
        end
      end
       */
    endcase // case (state)
    if (reset) state <= IDLE;
  end // always @ (posedge clk)

  enum bit {
            OUT_IDLE,
            OUT_WAIT} out_state;
  initial begin
    out_state = OUT_IDLE;
    rx_data   = '0;
    rx_user   = '0;
    rx_valid  = '0;
  end
  always @(posedge clk) begin
    rx_valid <= '0;
    case (out_state)
      OUT_IDLE: begin
        if (done && rx_ready) begin
          rx_data                  <= data_capture[8:1];
          rx_user                  <= err; // Error indicator
          rx_valid                 <= '1;
          if (~rx_ready) out_state <= OUT_WAIT;
        end
      end
      OUT_WAIT: if (rx_ready) out_state <= OUT_IDLE;
    endcase
    if (reset) out_state <= OUT_IDLE;
  end

endmodule // ps2_host
