/* Copyright (C) 2025  AGH University of Krakow */

module reset_synchronizer (
    input logic  refclk,
    input logic  io_rst_n,

    input logic  pll_clk,
    input logic  pll_locked,

    output logic rst_n
);


/* Local variables and signals */

logic [2:0] internal_rst_n;
logic       synchronizer_rst_n;


/* Signals assignments */

assign rst_n = internal_rst_n[2];
assign synchronizer_rst_n = io_rst_n & pll_locked;


/* Module internal logic */

always_ff @(posedge pll_clk or negedge synchronizer_rst_n) begin
    if (!synchronizer_rst_n)
        internal_rst_n <= 3'b0;
    else
        internal_rst_n <= {internal_rst_n[1:0], 1'b1};
end

endmodule
