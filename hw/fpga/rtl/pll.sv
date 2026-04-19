/* Copyright (C) 2025  AGH University of Krakow */

module pll (
    input logic  refclk,
    input logic  io_rst_n,

    output logic clk,
    output logic locked
);


/* Local variables and signals */

logic refclk_buf, clk_40_buf, clk_40_unbuf, clk_fb_buf, clk_fb_unbuf;


/* Signals assignments */

assign clk = clk_40_buf;


/* Submodules placement */

IBUF refclk_ibuf(
    .I (refclk),
    .O (refclk_buf)
);

PLLE2_ADV #(
    .BANDWIDTH            ("OPTIMIZED"),
    .COMPENSATION         ("ZHOLD"),
    .STARTUP_WAIT         ("FALSE"),
    .DIVCLK_DIVIDE        (5),
    .CLKFBOUT_MULT        (42),
    .CLKFBOUT_PHASE       (0.000),
    .CLKOUT0_DIVIDE       (21),
    .CLKOUT0_PHASE        (0.000),
    .CLKOUT0_DUTY_CYCLE   (0.500)
) u_plle2_adv (
    .CLKFBOUT            (clk_fb_unbuf),
    .CLKOUT0             (clk_40_unbuf),
    .CLKOUT1             (),
    .CLKOUT2             (),
    .CLKOUT3             (),
    .CLKOUT4             (),
    .CLKOUT5             (),
    /* input clock control */
    .CLKFBIN             (clk_fb_buf),
    .CLKIN1              (refclk_buf),
    .CLKIN2              (1'b0),
    /* tied to always select the primary input clock */
    .CLKINSEL            (1'b1),
    /* ports for dynamic reconfiguration */
    .DADDR               (7'h0),
    .DCLK                (1'b0),
    .DEN                 (1'b0),
    .DI                  (16'h0),
    .DO                  (),
    .DRDY                (),
    .DWE                 (1'b0),
    /* other control and status signals */
    .LOCKED              (locked),
    .PWRDWN              (1'b0),
    /* do not reset PLL on external reset, otherwise ILA disconnects at a reset */
    .RST                 (1'b0)
);

BUFG clk_fb_bufg (
    .I(clk_fb_unbuf),
    .O(clk_fb_buf)
);

BUFG clk_40_bufg (
    .I(clk_40_unbuf),
    .O(clk_40_buf)
);

endmodule
