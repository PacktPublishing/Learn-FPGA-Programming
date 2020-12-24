module i2c_wrapper
  #
  (
   parameter                CLK_PER = 10
   )
  (
   input wire               clk, // 100Mhz clock

   // Temperature Sensor Interface
   inout wire               TMP_SCL,
   inout wire               TMP_SDA,
   inout wire               TMP_INT,
   inout wire               TMP_CT,

   // Switch interface - Fahrenheit or celsius
   input wire               ftemp,

   output logic             update_temp,
   output logic [15:0][7:0] capt_temp
   );

  logic [7:0][3:0] encoded;
  logic            temp_valid;

  // i2C temperature sensor
  i2c_temp_flt
    #
    (
     .CLK_PER        (CLK_PER)
     )
  u_i2c_temp_flt
    (
     .clk            (clk),

     // Temperature Sensor Interface
     .TMP_SCL        (TMP_SCL),
     .TMP_SDA        (TMP_SDA),
     .TMP_INT        (TMP_INT),
     .TMP_CT         (TMP_CT),

     // Switch interface - Fahrenheit or celsius
     .SW             (ftemp),

     // Data to be displayed
     .temp_valid     (temp_valid),
     .encoded        (encoded)
     );

  always @(posedge clk) begin
    if (temp_valid) begin
      update_temp             <= ~update_temp;
      capt_temp               <= "     F 0000.0000";
      capt_temp[9]            <= 8'h0C; // Degree symbol
      if (ftemp) capt_temp[10] <= "F";
      else       capt_temp[10] <= "C";
      for (int i = 7; i >= 0; i--) begin
        if (i > 3) begin
          capt_temp[7-i] <= 8'h30+encoded[i];
        end else begin
          capt_temp[8-i] <= 8'h30+encoded[i];
        end
      end
    end
  end // always @ (posedge clk)

endmodule
