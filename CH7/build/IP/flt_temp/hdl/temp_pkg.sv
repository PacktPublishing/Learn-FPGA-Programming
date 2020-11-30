`ifndef _TEMP_PKG
`define _TEMP_PKG
package temp_pkg;

  localparam NUM_SEGMENTS = 8;

  function bit [NUM_SEGMENTS-1:0][3:0] bin_to_bcd;
    // we want to support either 4 or 8 segments
    input [31:0] bin_in;
    bit [NUM_SEGMENTS*4-1:0] shifted;
    shifted    = {30'b0, bin_in[31:30]};
    for (int i = 29; i >= 1; i--) begin
      shifted = shifted << 1 | bin_in[i];
      for (int j = 0; j < 8; j++) begin
        if (shifted[j*4+:4] > 4) shifted[j*4+:4] += 3;
      end
    end
    shifted = shifted << 1 | bin_in[0];
    for (int i = 0; i < NUM_SEGMENTS; i++) begin
      bin_to_bcd[i] = shifted[4*i+:4];
    end
  endfunction // bin_to_bcd

endpackage // temp_pkg

`endif
