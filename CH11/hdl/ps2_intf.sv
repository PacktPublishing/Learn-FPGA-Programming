interface ps2_intf;
  // Interfaces can contain parameter lists like a module
  // Interfaces can contain IO like a module
  logic          tx_valid;
  logic [7:0]    tx_data;
  logic          tx_ready;

  logic [7:0]    rx_data;
  logic          rx_user;
  logic          rx_valid;
  logic          rx_ready;

  modport master
    (
     output tx_valid,
     output tx_data,
     input  tx_ready,

     input  rx_data,
     input  rx_user,
     input  rx_valid,
     output rx_ready
     );

  modport slave
    (
     input  tx_valid,
     input  tx_data,
     output tx_ready,

     output rx_data,
     output rx_user,
     output rx_valid,
     input  rx_ready,
     import parity_gen,
     import parity_check
     );

  function parity_gen(input [7:0] din);
    begin
      return ~^din;
    end
  endfunction // parity_gen

  function parity_check(input [8:0] din);
    begin
      return ~^din;
    end
  endfunction // parity_check

endinterface
