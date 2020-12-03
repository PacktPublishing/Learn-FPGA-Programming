`timescale 1ns/10ps
module adt7420_i2c_mod
  #
  (
   parameter  INTERVAL     = 1000000000,
   parameter  CLK_PER      = 10
   )
  (
   input wire          clk, // 100Mhz clock

   // Temperature Sensor Interface
   inout wire          TMP_SCL,
   inout wire          TMP_SDA,
   inout wire          TMP_INT,
   inout wire          TMP_CT,

   output logic        fix_temp_tvalid,
   output logic [15:0] fix_temp_tdata
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

  assign fix_temp_tvalid = convert;
  assign fix_temp_tdata = temp_data >> 3; // lop off lower three unused bits

endmodule // spi_temp
