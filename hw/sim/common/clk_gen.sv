/**
 * Copyright (C) 2025  AGH University of Science and Technology
 */

`timescale 1ps/1ps

module clk_gen #(
    FREQUENCY_MHZ = 50
) (
    output logic clk
);

localparam real PERIOD = 1_000_000_000_000.0 / (FREQUENCY_MHZ * 1_000_000);

initial begin
    assert (FREQUENCY_MHZ <= 1000) else
        $fatal("Frequency cannot be greater than 1000 MHz");

    clk = 1'b0;
end

always begin
    #(PERIOD / 2);
    clk = ~clk;
end

endmodule
