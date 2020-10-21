`timescale 1ns/10ps
module i2c_temp
  #
  (
   parameter  SMOOTHING    = 16,
   parameter  INTERVAL     = 1000000000,
   parameter  NUM_SEGMENTS = 8,
   parameter  CLK_PER      = 10
   )
  (
   input wire                      clk, // 100Mhz clock

   // Temperature Sensor Interface
   inout wire                      TMP_SCL,
   inout wire                      TMP_SDA,
   inout wire                      TMP_INT,
   inout wire                      TMP_CT,

   // Switch interface
   input wire                      SW,

   // LED interface
   output logic                    LED,

   // 7 segment display
   output logic [NUM_SEGMENTS-1:0] anode,
   output logic [7:0]              cathode
   );

  assign LED = SW;

  import temp_pkg::*;

  localparam TIME_1SEC   = int'(INTERVAL/CLK_PER); // Clock ticks in 1 sec
  localparam TIME_THDSTA = int'(600/CLK_PER);
  localparam TIME_TSUSTA = int'(600/CLK_PER);
  localparam TIME_THIGH  = int'(600/CLK_PER);
  localparam TIME_TLOW   = int'(1300/CLK_PER);
  localparam TIME_TSUDAT = int'(20/CLK_PER);
  localparam TIME_TSUSTO = int'(600/CLK_PER);
  localparam TIME_THDDAT = int'(30/CLK_PER);
  localparam I2C_ADDR = 7'b1001011; // 0x4B
  localparam I2CBITS = 1 + // start
                       7 + // 7 bits for address
                       1 + // 1 bit for read
                       1 + // 1 bit for ack back
                       8 + // 8 bits upper data
                       1 + // 1 bit for ack
                       8 + // 8 bits lower data
                       1 + // 1 bit for ack
                       1 + 1;  // 1 bit for stop
  logic [NUM_SEGMENTS-1:0][3:0]    encoded;
  logic [NUM_SEGMENTS-1:0][3:0]    encoded_int;
  logic [NUM_SEGMENTS-1:0][3:0]    encoded_frac;
  logic [NUM_SEGMENTS-1:0]         decimal;
  (* mark_debug = "true" *) logic                            sda_en;
  (* mark_debug = "true" *) logic                            scl_en;
  logic [I2CBITS-1:0]              i2c_data;
  logic [I2CBITS-1:0]              i2c_en;
  logic [I2CBITS-1:0]              i2c_capt;
  (* mark_debug = "true" *) logic [$clog2(TIME_1SEC)-1:0]    counter;
  logic                            counter_reset;
  (* mark_debug = "true" *) logic [$clog2(I2CBITS)-1:0]      bit_count;
  (* mark_debug = "true" *) logic [15:0]                     temp_data;
  (* mark_debug = "true" *) logic                            capture_en;
  (* mark_debug = "true" *) logic                            convert;

  seven_segment
    #
    (
     .NUM_SEGMENTS (NUM_SEGMENTS),
     .CLK_PER      (CLK_PER)
     )
  u_seven_segment
    (
     .clk          (clk),
     .encoded      (encoded),
     .decimal      (~decimal),
     .anode        (anode),
     .cathode      (cathode)
     );

  assign TMP_SCL = scl_en ? 'z : '0;
  assign TMP_SDA = sda_en ? 'z : '0;

  typedef enum bit [2:0]
               {
                IDLE,
                START,
                TLOW,
                TSU,
                THIGH,
                THD,
                TSTO
                } spi_t;

  (* mark_debug = "true" *) spi_t spi_state;

  assign capture_en = i2c_capt[I2CBITS - bit_count - 1];

  initial begin
    scl_en          = '0;
    sda_en          = '0;
    counter_reset   = '0;
    counter         = '0;
    bit_count       = '0;
  end

  always @(posedge clk) begin
    scl_en                     <= '1;
    sda_en                     <= ~i2c_en[I2CBITS - bit_count - 1] |
                                  i2c_data[I2CBITS - bit_count - 1];
    if (counter_reset) counter <= '0;
    else counter <= counter + 1'b1;
    counter_reset <= '0;
    convert       <= '0;

    case (spi_state)
      IDLE: begin
        i2c_data  <= {1'b0, I2C_ADDR, 1'b1, 1'b0, 8'b00, 1'b0, 8'b00, 1'b1, 1'b0, 1'b1};
        i2c_en    <= {1'b1, 7'h7F,    1'b1, 1'b0, 8'b00, 1'b1, 8'b00, 1'b1, 1'b1, 1'b1};
        i2c_capt  <= {1'b0, 7'h00,    1'b0, 1'b0, 8'hFF, 1'b0, 8'hFF, 1'b0, 1'b0, 1'b0};
        bit_count <= '0;
        sda_en    <= '1; // Force to 1 in the beginning.

        if (counter == TIME_1SEC) begin
          temp_data     <= '0;
          spi_state     <= START;
          counter_reset <= '1;
          sda_en        <= '0; // Drop the data
        end
      end
      START: begin
        sda_en <= '0; // Drop the data
        // Hold clock low for thd:sta
        if (counter == TIME_THDSTA) begin
          counter_reset   <= '1;
          scl_en          <= '0; // Drop the clock
          spi_state       <= TLOW;
        end
      end
      TLOW: begin
        scl_en            <= '0; // Drop the clock
        if (counter == TIME_TLOW) begin
          bit_count     <= bit_count + 1'b1;
          counter_reset <= '1;
          spi_state     <= TSU;
        end
      end
      TSU: begin
        scl_en            <= '0; // Drop the clock
        if (counter == TIME_TSUSTA) begin
          counter_reset <= '1;
          spi_state     <= THIGH;
        end
      end
      THIGH: begin
        scl_en          <= '1; // Raise the clock
        if (counter == TIME_THIGH) begin
          if (capture_en) temp_data <= temp_data << 1 | TMP_SDA;
          counter_reset <= '1;
          spi_state     <= THD;
        end
      end
      THD: begin
        scl_en            <= '0; // Drop the clock
        if (counter == TIME_THDDAT) begin
          counter_reset <= '1;
          spi_state     <= (bit_count == I2CBITS) ? TSTO : TLOW;
        end
      end
      TSTO: begin
        if (counter == TIME_TSUSTO) begin
          convert       <= '1;
          counter_reset <= '1;
          spi_state     <= IDLE;
        end
      end
    endcase
  end

  logic [28:0] smooth_data;
  logic        smooth_convert;
  logic [4:0]  sample_count;

  generate
    if (SMOOTHING == 0) begin : g_NO_SMOOTH
      assign smooth_data = temp_data >> 3;
      assign smooth_convert = convert;
    end else begin : g_SMOOTH
      localparam                  NINE_FIFTHS = 17'b1_11001100_11001100;
      logic [$clog2(SMOOTHING):0] smooth_count;
      logic [12:0]                dout;
      logic                       rden;
      logic [17:0]                accumulator;
      logic [4:0]                 convert_pipe;
      logic [16:0]                divide[17];

      initial begin
        rden         = '0;
        smooth_count = '0;
        accumulator  = '0;
        sample_count = '0;
        divide[0]    = 17'b1_00000000_00000000; // 1
        divide[1]    = 17'b0_10000000_00000000; // 1/2
        divide[2]    = 17'b0_01010101_01010101; // 1/3
        divide[3]    = 17'b0_01000000_00000000; // 1/4
        divide[4]    = 17'b0_00110011_00110011; // 1/5
        divide[5]    = 17'b0_00101010_10101010; // 1/6
        divide[6]    = 17'b0_00100100_10010010; // 1/7
        divide[7]    = 17'b0_00100000_00000000; // 1/8
        divide[8]    = 17'b0_00011100_01110001; // 1/9
        divide[9]    = 17'b0_00011001_10011001; // 1/10
        divide[10]   = 17'b0_00010111_01000101; // 1/11
        divide[11]   = 17'b0_00010101_01010101; // 1/12
        divide[12]   = 17'b0_00010011_10110001; // 1/13
        divide[13]   = 17'b0_00010010_01001001; // 1/14
        divide[14]   = 17'b0_00010001_00010001; // 1/15
        divide[15]   = 17'b0_00010000_00000000; // 1/16
        divide[16]   = 17'b0_00010000_00000000; // 1/16
      end

      always @(posedge clk) begin
        rden           <= '0;
        smooth_convert <= '0;
        convert_pipe   <= convert_pipe << 1;
        if (convert) begin
          convert_pipe[0]           <= '1;
          smooth_count              <= smooth_count + 1'b1;
          accumulator               <= accumulator + temp_data[15:3];
        end else if (smooth_count == 16) begin
          rden                    <= '1;
          smooth_count            <= smooth_count - 1'b1;
        end else if (rden) begin
          accumulator             <= accumulator - dout;
        end else if (convert_pipe[2]) begin
          if (~sample_count[4]) sample_count <= sample_count + 1'b1;

          smooth_data             <= accumulator * divide[sample_count];
        end else if (convert_pipe[3]) begin
          smooth_data    <= smooth_data >> 16;
          smooth_convert <= ~SW;
        end else if (convert_pipe[4]) begin
          smooth_convert          <= SW;
          smooth_data             <= ((smooth_data * NINE_FIFTHS) >> 16) + (32 << 4);
        end
      end

      xpm_fifo_sync
        #
        (
         .FIFO_WRITE_DEPTH       (SMOOTHING),
         .WRITE_DATA_WIDTH       (16)
         )
      u_xpm_fifo_sync
        (
         .sleep                  ('0),
         .rst                    ('0),

         .wr_clk                 (clk),
         .wr_en                  (convert),
         .din                    (temp_data[15:3]),
         .full                   (),
         .prog_full              (),
         .wr_data_count          (),
         .overflow               (),
         .wr_rst_busy            (),
         .almost_full            (),
         .wr_ack                 (),

         .rd_en                  (rden),
         .dout                   (dout),
         .empty                  (),
         .prog_empty             (),
         .rd_data_count          (),
         .underflow              (),
         .rd_rst_busy            (),
         .almost_empty           (),
         .data_valid             (),

         .injectsbiterr          ('0),
         .injectdbiterr          ('0),
         .sbiterr                (),
         .dbiterr                ()
         );

    end
  endgenerate

  logic [3:0][3:0] fraction;
  logic [15:0]     fraction_table[16];

  initial begin
    for (int i = 0; i < 16; i++) fraction_table[i] = i*625;
  end

  // convert temperature from
  always @(posedge clk) begin
    if (smooth_convert) begin
      encoded_int  <= bin_to_bcd(smooth_data[12:4]); // Decimal portion
      fraction     <= bin_to_bcd(fraction_table[smooth_data[3:0]]);
      decimal      <= 8'b00010000;
    end
  end // always @ (posedge clk)

  assign encoded = {encoded_int[3:0], fraction[3:0]};

endmodule // spi_temp
