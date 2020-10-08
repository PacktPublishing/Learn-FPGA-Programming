`timescale 1ns/10ps
module simple_ff_async
  #
  (
   parameter    ASYNC = "TRUE"
   )
  (
   input wire   CK,
   input wire   CE,
   input wire   SR,
   input wire   D,
   output logic Q
   );

  initial Q = '1;

  generate
    if (ASYNC == "TRUE") begin : g_ASYNC
      always @(posedge CK, posedge SR) begin
        if (SR) Q <= '0;
        else if (CE) Q <= D;
      end
    end else begin : g_SYNC
      always @(posedge CK) begin
        if (SR) Q <= '0;
        else if (CE) Q <= D;
      end
    end
  endgenerate

endmodule
