`timescale 1ns/10ps
module adt7420_i2c_bd
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

   output wire         fix_temp_tvalid,
   output wire [15:0]  fix_temp_tdata
   );

  adt7420_i2c_mod
  #
  (
   .INTERVAL     (INTERVAL),
   .CLK_PER      (CLK_PER)
   )
  (
   .clk          (clk), // 100Mhz clock

   // Temperature Sensor Interface
   .TMP_SCL      (TMP_SCL),
   .TMP_SDA      (TMP_SDA),
   .TMP_INT      (TMP_INT),
   .TMP_CT       (TMP_CT),

   .fix_temp_tvalid (fix_temp_tvalid),
   .fix_temp_tdata  (fix_temp_tdata)
   );

endmodule // spi_temp
