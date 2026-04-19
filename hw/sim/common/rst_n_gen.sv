/**
 * Copyright (C) 2025  AGH University of Science and Technology
 */

`timescale 1ps/1ps

module rst_n_gen (
    output logic rst_n,
    input logic  clk
);

initial begin
    rst_n = 1'b1;
end

task reset();
    @(negedge clk) ;
    rst_n = 1'b0;

    @(negedge clk) ;
    rst_n = 1'b1;
endtask

endmodule
