module ps2_host
  #
  (
   parameter           CLK_PER = 10,
   parameter           CYCLES  = 16
   )
  (
   input wire          clk,

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

  logic                ps2_clk_clean,  ps2_clk_clean_last;
  logic                ps2_data_clean;
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

     .sig_in   ({ps2_clk,       ps2_data}),
     .sig_out  ({ps2_clk_clean, ps2_data_clean})
     );

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

  typedef enum bit [2:0]
               {
                IDLE,
                CLK_FALL[2],
                CLK_HIGH,
                XMIT_START
                } state_t;

  state_t state;

  initial begin
    state = IDLE;
  end

  always @(posedge clk) begin
    ps2_clk_en         <= '0;
    ps2_data_en        <= '0;
    done               <= '0;
    err                <= '0;
    tx_xmit            <= '0;
    ps2_clk_clean_last <= ps2_clk_clean;

    case (state)
      IDLE: begin
        // Wait for a falling edge of the clock or we received
        // a xmit request
        data_counter <= '0;
        if (~ps2_clk_clean && ps2_clk_clean_last) state <= CLK_FALL0;
        else if (~tx_ready) state <= XMIT_START;
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
          done  <= '1;
          err   <= ~^data_capture[9:1];
          state <= IDLE;
          end else if (~ps2_clk_clean) state <= CLK_FALL0;
      end
    endcase // case (state)
  end // always @ (posedge clk)

  enum bit {
            OUT_IDLE,
            OUT_WAIT} out_state;
  initial begin
    out_state = OUT_IDLE;
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
  end
endmodule // ps2_host
