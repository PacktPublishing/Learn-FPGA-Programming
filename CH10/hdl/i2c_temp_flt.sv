`timescale 1ns/10ps
module i2c_temp_flt
  #
  (
   parameter  SMOOTHING    = 16,
   parameter  INTERVAL     = 1000000000,
   parameter  NUM_SEGMENTS = 8,
   parameter  CLK_PER      = 10
   )
  (
   input wire                           clk, // 100Mhz clock

   // Temperature Sensor Interface
   inout wire                           TMP_SCL,
   inout wire                           TMP_SDA,
   inout wire                           TMP_INT,
   inout wire                           TMP_CT,

   // Switch interface - Fahrenheit or celsius
   input wire                           SW,

   // Data to be displayed
   output logic                         temp_valid,
   output logic [NUM_SEGMENTS-1:0][3:0] encoded
   );

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
  logic [NUM_SEGMENTS-1:0][3:0]    encoded_int;
  logic [NUM_SEGMENTS-1:0][3:0]    encoded_frac;
  logic [NUM_SEGMENTS-1:0]         digit_point;
  logic                            sda_en;
  logic                            scl_en;
  logic [I2CBITS-1:0]              i2c_data;
  logic [I2CBITS-1:0]              i2c_en;
  logic [I2CBITS-1:0]              i2c_capt;
  logic [$clog2(TIME_1SEC)-1:0]    counter;
  logic                            counter_reset;
  logic [$clog2(I2CBITS)-1:0]      bit_count;
  logic [15:0]                     temp_data;
  logic                            capture_en;
  logic                            convert;

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

  spi_t spi_state;

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

  logic [15:0] smooth_data;
  logic        smooth_convert;
  logic [4:0]  sample_count;

  generate
    if (SMOOTHING == 0) begin : g_NO_SMOOTH
      assign smooth_data = temp_data >> 3;
      assign smooth_convert = convert;
    end else begin : g_SMOOTH
      localparam                  NINE_FIFTHS = 17'b1_11001100_11001100;
      typedef struct packed
                    {
                      bit sign;
                      bit [7:0] exponent;
                      bit [22:0] mantissa;
                    } float_t;
      typedef union packed
                    {
                      float_t      fp;
                      logic [31:0] raw;
                    } float_u;

      logic [$clog2(SMOOTHING):0] smooth_count;
      logic [31:0]                dout;
      logic                       rden;
      float_u                     accumulator; // 0.0 FP
      float_u                     result_data;
      logic                       result_valid;
      float_u                     temperature;
      logic                       temperature_valid;
      logic [2:0]                 convert_pipe;
      logic [31:0]                divide[17];
      const bit [31:0]            nine_fifths = 32'h3fe66666; // 9/5 in FP
      const bit [31:0]            thirty_two = 32'h42000000; // Floating point
      logic [31:0]                mult_in[2];
      logic                       mult_in_valid;
      logic [31:0]                fused_data;
      logic                       fused_valid;

      initial begin
        rden         = '0;
        smooth_count = '0;
        accumulator  = '0;
        sample_count = '0;
        divide[0]    = 32'h3F800000; // 1
        divide[1]    = 32'h3F000000; // 1/2
        divide[2]    = 32'h3eaaaaab; // 1/3
        divide[3]    = 32'h3e800000; // 1/4
        divide[4]    = 32'h3e4ccccd; // 1/5
        divide[5]    = 32'h3e2aaaab; // 1/6
        divide[6]    = 32'h3e124924; // 1/7
        divide[7]    = 32'h3e000000; // 1/8
        divide[8]    = 32'h3de38e39; // 1/9
        divide[9]    = 32'h3dcccccd; // 1/10
        divide[10]   = 32'h3dba2e8c; // 1/11
        divide[11]   = 32'h3daaaaab; // 1/12
        divide[12]   = 32'h3d9d89d9; // 1/13
        divide[13]   = 32'h3d924925; // 1/14
        divide[14]   = 32'h3d888888; // 1/15
        divide[15]   = 32'h3d800000; // 1/16
        divide[16]   = 32'h3d800000; // 1/16
      end

      logic s_axis_a_tready;
      logic temp_float_valid;
      logic [31:0] temp_float;
      logic [7:0]  fp_add_op;
      logic        accum_valid;
      logic [31:0] addsub_in[2];
      logic [31:0] addsub_data;
      logic        addsub_valid;

      // Stage 1
      fix_to_float u_fx_flt
        (
         .aclk                   (clk),
         .s_axis_a_tvalid        (convert),
         .s_axis_a_tdata         ({3'b0, temp_data[15:3]}),
         .m_axis_result_tvalid   (temp_float_valid),
         .m_axis_result_tdata    (temp_float)
         );

      fp_addsub u_fp_addsub
        (
         .aclk                   (clk),
         .s_axis_a_tvalid        (convert_pipe[0]),
         .s_axis_a_tdata         (addsub_in[0]),
         .s_axis_b_tvalid        (convert_pipe[0]),
         .s_axis_b_tdata         (addsub_in[1]),
         .s_axis_operation_tvalid(convert_pipe[0]),
         .s_axis_operation_tdata (fp_add_op),
         .m_axis_result_tvalid   (addsub_valid),
         .m_axis_result_tdata    (addsub_data)
         );

      fp_mult u_fp_mult
        (
         .aclk                   (clk),
         .s_axis_a_tvalid        (mult_in_valid),
         .s_axis_a_tdata         (mult_in[0]),
         .s_axis_b_tvalid        (mult_in_valid),
         .s_axis_b_tdata         (mult_in[1]),
         .m_axis_result_tvalid   (result_valid),
         .m_axis_result_tdata    (result_data.raw)
         );

      flt_to_fix u_flt_to_fix
        (
         .aclk                   (clk),
         .s_axis_a_tvalid        (temperature_valid),
         .s_axis_a_tdata         (temperature.raw),
         .m_axis_result_tvalid   (smooth_convert),
         .m_axis_result_tdata    (smooth_data)
         );

      fp_fused_mult_add u_fp_fused_mult_add
        (
         .aclk                   (clk),
         .s_axis_a_tvalid        (result_valid),
         .s_axis_a_tdata         (result_data.raw),
         .s_axis_b_tvalid        (result_valid),
         .s_axis_b_tdata         (nine_fifths),
         .s_axis_c_tvalid        (result_valid),
         .s_axis_c_tdata         (thirty_two),
         .m_axis_result_tvalid   (fused_valid),
         .m_axis_result_tdata    (fused_data)
         );

      always @(posedge clk) begin
        rden              <= '0;
        convert_pipe      <= '0;
        temperature_valid <= '0;
        mult_in_valid     <= '0;

        if (temp_float_valid) begin
          // First stage, temperature data converted to float, add to accumulator
          fp_add_op       <= '0; // add
          convert_pipe[0] <= '1;
          addsub_in[0]    <= accumulator.raw;
          addsub_in[1]    <= temp_float;
        end
        if (addsub_valid) begin
          accumulator.raw <= addsub_data;
          if (~|fp_add_op) begin
            convert_pipe[1] <= '1;
            rden            <= '1;
          end else begin
            convert_pipe[2] <= '1;
          end
        end
        if (convert_pipe[1]) begin
          // We just performed an add, so now perform a subtract
          fp_add_op       <= 8'b1; // subtract
          convert_pipe[0] <= '1;
          addsub_in[0]    <= accumulator.raw;
          addsub_in[1]    <= (smooth_count == 16) ? dout : '0;
        end
        if (convert_pipe[2]) begin
          // Drive data into multiplier
          if (~sample_count[4]) sample_count <= sample_count + 1'b1;
          if (smooth_count != 16) smooth_count  <= smooth_count + 1'b1;
          mult_in[0]    <= accumulator.raw;
          mult_in[1]    <= divide[sample_count];
          mult_in_valid <= '1;
        end
        if (result_valid) begin
          temperature.fp          <= result_data.fp;
          //temperature.fp.exponent <= result_data.fp.exponent - 4;
          temperature_valid       <= ~SW;
        end
        // Fahrenheit conversion
        if (SW && fused_valid) begin
          temperature.raw      <= fused_data;
          temperature_valid    <= '1;
        end
      end

      xpm_fifo_sync
        #
        (
         .FIFO_WRITE_DEPTH       (SMOOTHING*2),
         .WRITE_DATA_WIDTH       ($bits(temp_float))
         )
      u_xpm_fifo_sync
        (
         .sleep                  ('0),
         .rst                    ('0),

         .wr_clk                 (clk),
         .wr_en                  (temp_float_valid),
         .din                    (temp_float),
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
    temp_valid <= '0;
    if (smooth_convert) begin
      encoded_int  <= bin_to_bcd(smooth_data[12:4]); // Decimal portion
      fraction     <= bin_to_bcd(fraction_table[smooth_data[3:0]]);
      digit_point  <= 8'b00010000;
      temp_valid   <= '1;
    end
  end // always @ (posedge clk)

  assign encoded = {encoded_int[3:0], fraction[3:0]};

endmodule // spi_temp
