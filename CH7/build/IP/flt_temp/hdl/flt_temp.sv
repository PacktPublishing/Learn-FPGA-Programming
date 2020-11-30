`timescale 1ns/10ps
module flt_temp
  #
  (
   parameter  SMOOTHING    = 16,
   parameter  NUM_SEGMENTS = 8
   )
  (
   input wire                        clk, // 100Mhz clock

   // Switch interface
   input wire                        SW,

   // LED interface
   output logic                      LED,

   // data from fix to float
   input wire                        fix_temp_tvalid,
   input wire [31:0]                 fix_temp_tdata,

   // Addsub interface
   output logic                      addsub_a_tvalid,
   output logic [31:0]               addsub_a_tdata,
   output logic                      addsub_b_tvalid,
   output logic [31:0]               addsub_b_tdata,
   output logic                      addsub_op_tvalid,
   output logic [7:0]                addsub_op_tdata,
   input wire                        addsub_tvalid,
   input wire [31:0]                 addsub_tdata,

   // Multiplier interface
   output logic                      mult_a_tvalid,
   output logic [31:0]               mult_a_tdata,
   output logic                      mult_b_tvalid,
   output logic [31:0]               mult_b_tdata,
   input wire                        mult_tvalid,
   input wire [31:0]                 mult_tdata,

   // Fused Multiplier-Add interface
   output logic                      fused_a_tvalid,
   output logic [31:0]               fused_a_tdata,
   output logic                      fused_b_tvalid,
   output logic [31:0]               fused_b_tdata,
   output logic                      fused_c_tvalid,
   output logic [31:0]               fused_c_tdata,
   input wire                        fused_tvalid,
   input wire [31:0]                 fused_tdata,

   // Float to fixed
   output logic                      fp_temp_tvalid,
   output logic [31:0]               fp_temp_tdata,
   input wire                        fx_temp_tvalid,
   input wire [15:0]                 fx_temp_tdata,

   // Float to fixed
   output logic                      seven_segment_tvalid,
   output logic [NUM_SEGMENTS*4-1:0] seven_segment_tdata,
   output logic [NUM_SEGMENTS-1:0]   seven_segment_tuser
   );

  assign LED = SW;

  import temp_pkg::*;

  logic [NUM_SEGMENTS-1:0][3:0]    encoded;
  logic [NUM_SEGMENTS-1:0][3:0]    encoded_int;
  logic [NUM_SEGMENTS-1:0][3:0]    encoded_frac;
  logic [NUM_SEGMENTS-1:0]         digit_point;
  (* mark_debug = "true" *) logic [15:0]                     temp_data;
  (* mark_debug = "true" *) logic                            capture_en;
  (* mark_debug = "true" *) logic                            convert;

  logic [15:0] smooth_data;
  logic        smooth_convert;
  logic [4:0]  sample_count;

  generate
    if (SMOOTHING == 0) begin : g_NO_SMOOTH
      assign smooth_data = temp_data;
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
      logic        accum_valid;
      logic [31:0] addsub_in[2];

      assign addsub_a_tvalid = convert_pipe[0];
      assign addsub_a_tdata  = addsub_in[0];
      assign addsub_b_tvalid = convert_pipe[0];
      assign addsub_b_tdata  = addsub_in[1];
      assign addsub_op_tvalid= convert_pipe[0];

      assign mult_a_tvalid   = mult_in_valid;
      assign mult_a_tdata    = mult_in[0];
      assign mult_b_tvalid   = mult_in_valid;
      assign mult_b_tdata    = mult_in[1];
      assign result_valid    = mult_tvalid;
      assign result_data.raw = mult_tdata;

      assign fp_temp_tvalid = temperature_valid;
      assign fp_temp_tdata  = temperature.raw;
      assign smooth_convert = fx_temp_tvalid;
      assign smooth_data    = fx_temp_tdata;

      assign fused_a_tvalid = result_valid;
      assign fused_a_tdata  = result_data.raw;
      assign fused_b_tvalid = result_valid;
      assign fused_b_tdata  = nine_fifths;
      assign fused_c_tvalid = result_valid;
      assign fused_c_tdata  = thirty_two;

      always @(posedge clk) begin
        rden              <= '0;
        convert_pipe      <= '0;
        temperature_valid <= '0;
        mult_in_valid     <= '0;

        if (fix_temp_tvalid) begin
          // First stage, temperature data converted to float, add to accumulator
          addsub_op_tdata  <= '0; // add
          convert_pipe[0]  <= '1;
          addsub_in[0]     <= accumulator.raw;
          addsub_in[1]     <= fix_temp_tdata;
        end
        if (addsub_tvalid) begin
          accumulator.raw <= addsub_tdata;
          if (~|addsub_op_tdata) begin
            convert_pipe[1] <= '1;
            rden            <= '1;
          end else begin
            convert_pipe[2] <= '1;
          end
        end
        if (convert_pipe[1]) begin
          // We just performed an add, so now perform a subtract
          addsub_op_tdata  <= 8'b1; // subtract
          convert_pipe[0]  <= '1;
          addsub_in[0]     <= accumulator.raw;
          addsub_in[1]     <= (smooth_count == 16) ? dout : '0;
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
        if (SW && fused_tvalid) begin
          temperature.raw      <= fused_tdata;
          temperature_valid    <= '1;
        end
      end

      xpm_fifo_sync
        #
        (
         .FIFO_WRITE_DEPTH       (SMOOTHING*2),
         .WRITE_DATA_WIDTH       ($bits(fix_temp_tdata))
         )
      u_xpm_fifo_sync
        (
         .sleep                  ('0),
         .rst                    ('0),

         .wr_clk                 (clk),
         .wr_en                  (fix_temp_tvalid),
         .din                    (fix_temp_tdata),
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
    seven_segment_tvalid <= '0;
    if (smooth_convert) begin
      seven_segment_tvalid <= '1;
      encoded_int  <= bin_to_bcd(smooth_data[12:4]); // Decimal portion
      fraction     <= bin_to_bcd(fraction_table[smooth_data[3:0]]);
      digit_point  <= 8'b00010000;
    end
  end // always @ (posedge clk)

  assign encoded = {encoded_int[3:0], fraction[3:0]};

  // 7 segment display
  assign seven_segment_tdata = encoded;
  assign seven_segment_tuser = digit_point;
endmodule // spi_temp
