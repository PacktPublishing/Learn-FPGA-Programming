`timescale 1ns/10ps
module project_2
  #
  (
   parameter SELECTOR,
   parameter BITS      = 16
   )
  (
   input wire [BITS-1:0]          SW,
   input wire                     BTNC,
   input wire                     BTNU,
   input wire                     BTNL,
   input wire                     BTNR,
   input wire                     BTND,

   output logic signed [BITS-1:0] LED
   );

  logic [$clog2(BITS):0] LO_LED;
  logic [$clog2(BITS):0] NO_LED;
  logic [BITS-1:0]       AD_LED;
  logic [BITS-1:0]       SB_LED;
  logic [BITS-1:0]       MULT_LED;

  leading_ones #(.SELECTOR(SELECTOR), .BITS(BITS)) u_lo (.*, .LED(LO_LED));
  add_sub      #(.SELECTOR("ADD"),    .BITS(BITS)) u_ad (.*, .LED(AD_LED));
  add_sub      #(.SELECTOR("SUB"),    .BITS(BITS)) u_sb (.*, .LED(SB_LED));
  num_ones     #(                     .BITS(BITS)) u_no (.*, .LED(NO_LED));
  mult         #(                     .BITS(BITS)) u_mt (.*, .LED(MULT_LED));

  //always_latch begin
  always_comb begin
    LED = '0;
    case (1'b1)
      BTNC: LED  = MULT_LED;
      BTNU: LED  = LO_LED;
      BTND: LED  = NO_LED;
      BTNL: LED  = AD_LED;
      BTNR: LED  = SB_LED;
    endcase
  end
endmodule
