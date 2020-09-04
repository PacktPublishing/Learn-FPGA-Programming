`timescale 1ns/10ps
module leading_ones
  #
  (
   parameter SELECTOR,
   parameter BITS      = 16
   )
  (
   input wire [BITS-1:0]         SW,
   output logic [$clog2(BITS):0] LED
   );

  generate
    if (SELECTOR == "UNIQUE_CASE") begin : g_UNIQUE_CASE
      always_comb begin
        LED           = '0; // Default to an output of 0
        unique case (1'b1)
          SW[15]:  LED  = 16;
          SW[14]:  LED  = 15;
          SW[13]:  LED  = 14;
          SW[12]:  LED  = 13;
          SW[11]:  LED  = 12;
          SW[10]:  LED  = 11;
          SW[9]:   LED  = 10;
          SW[8]:   LED  = 9;
          SW[7]:   LED  = 8;
          SW[6]:   LED  = 7;
          SW[5]:   LED  = 6;
          SW[4]:   LED  = 5;
          SW[3]:   LED  = 4;
          SW[2]:   LED  = 3;
          SW[1]:   LED  = 2;
          SW[0]:   LED  = 1;
          //default: LED  = 0;
        endcase
      end // always_comb
    end else if (SELECTOR == "CASE") begin : g_CASE // block: g_UNIQUE_CASE
      always_comb begin
        LED           = '0; // Default to an output of 0
        case (1'b1)
          SW[15]:  LED  = 16;
          SW[14]:  LED  = 15;
          SW[13]:  LED  = 14;
          SW[12]:  LED  = 13;
          SW[11]:  LED  = 12;
          SW[10]:  LED  = 11;
          SW[9]:   LED  = 10;
          SW[8]:   LED  = 9;
          SW[7]:   LED  = 8;
          SW[6]:   LED  = 7;
          SW[5]:   LED  = 6;
          SW[4]:   LED  = 5;
          SW[3]:   LED  = 4;
          SW[2]:   LED  = 3;
          SW[1]:   LED  = 2;
          SW[0]:   LED  = 1;
          default: LED  = 0;
        endcase
      end // always_comb
    end else if (SELECTOR == "DOWN_FOR") begin : g_UP_IF
      always_comb begin
        LED = '0;
        for (int i = $high(SW); i >= $low(SW); i--) begin
          if (SW[i]) begin
            LED = i + 1;
            break;
          end
        end
      end
    end else if (SELECTOR == "UP_FOR") begin : g_DOWN_IF
      always_comb begin
        LED = '0;
        for (int i = $low(SW); i <= $high(SW); i++) begin
          if (SW[i]) begin
            LED = i + 1;
          end
        end
      end
    end
  endgenerate
endmodule
