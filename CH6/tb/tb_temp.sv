`timescale 1ns/10ps
module tb_temp;

  parameter  INTERVAL     = 10000;
  parameter  NUM_SEGMENTS = 8;
  parameter  CLK_PER      = 20;

  logic clk;

  // Temperature Sensor Interface
  tri1 TMP_SCL;
  tri1 TMP_SDA;
  tri1 TMP_INT;
  tri1 TMP_CT;

  // 7 segment display
  logic [NUM_SEGMENTS-1:0] anode;
  logic [7:0]              cathode;

  initial clk = '0;
  always begin
    clk = #(CLK_PER/2) ~clk;
  end

  i2c_temp
    #
    (
     .INTERVAL     (INTERVAL),
     .NUM_SEGMENTS (NUM_SEGMENTS),
     .CLK_PER      (CLK_PER)
     )
  u_i2c_temp
    (
     .clk          (clk), // 100Mhz clock

     // Temperature Sensor Interface
     .TMP_SCL      (TMP_SCL),
     .TMP_SDA      (TMP_SDA),
     .TMP_INT      (TMP_INT),
     .TMP_CT       (TMP_CT),

     // 7 segment display
     .anode        (anode),
     .cathode      (cathode)
     );

endmodule
