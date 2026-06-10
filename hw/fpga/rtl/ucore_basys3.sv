/* Copyright (C) 2025  AGH University of Krakow */

module ucore_basys3 (
    input logic        refclk,

    input logic        btnC,

    output logic       RsTx,
    input logic        RsRx,

    output logic [8:0] led,
    input logic [3:0]  sw,

    output logic [3:0] stepper_phases
);


/* Local variables and signals */

logic        clk, rst_n, io_rst_n, pll_clk, pll_locked;

logic [31:0] gpio_dout;


/* Signals assignments */

assign clk = pll_clk;

assign io_rst_n = ~btnC;

assign led[3:0] = stepper_phases;
assign led[4] = sw[2];
assign led[8:5] = sw[3:0];


/* Submodules placement */

pll u_pll (
    .refclk,
    .io_rst_n,

    .clk(pll_clk),
    .locked(pll_locked)
);

reset_synchronizer u_reset_synchronizer (
    .refclk,
    .io_rst_n,

    .pll_clk,
    .pll_locked,

    .rst_n
);

soc u_soc (
    .clk,
    .rst_n,

    .uart_sout(RsTx),
    .uart_sin(RsRx),

    .gpio_dout,
    .gpio_din({28'b0, sw}),

    .stepper_phases,
    .servo_sensor_raw(sw[2])
);

endmodule
