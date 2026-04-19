/**
 * Copyright (C) 2025  AGH University of Science and Technology
 */

`timescale 1ns/1ps

module uart_bfm #(
    BAUD_RATE = 115200
) (
    input logic  clk,

    output logic sout,
    input logic  sin
);

localparam real BIT_PERIOD = 1_000_000_000 / BAUD_RATE;

logic [7:0] received_bytes[$];

initial begin
    sout = 1'b1;
end

initial begin
    for (int i = 0; i < 2; ++i)
        @(negedge clk);

    forever begin
        logic [7:0] rdata;

        while (sin)
            @(negedge clk);
        #(BIT_PERIOD / 2);

        for (int i = 0; i < 8; ++i) begin
            #(BIT_PERIOD);
            rdata[i] = sin;
        end

        #(BIT_PERIOD);
        received_bytes.push_back(rdata);
    end
end

task read_byte(output logic [7:0] rdata, input int timeout_cycles = 20 * BIT_PERIOD);
    for (int i = 0; i < timeout_cycles; ++i) begin
        @(negedge clk);

        if (received_bytes.size()) begin
            rdata = received_bytes.pop_front();
            return;
        end else if (i == timeout_cycles - 1) begin
            $error("timeout");
            rdata = 8'hff;
            return;
        end
    end
endtask

task write_byte(input logic [7:0] wdata);
    @(negedge clk);
    sout = 1'b0;
    #(BIT_PERIOD);

    for (int i = 0; i < 8; ++i) begin
        sout = wdata[i];
        #(BIT_PERIOD);
    end

    sout = 1'b1;
    #(BIT_PERIOD);
endtask

task read_message(output string rdata, input int timeout_cycles = 20 * BIT_PERIOD);
    logic [7:0] rbyte;

    rdata = "";

    do begin
        read_byte(rbyte, timeout_cycles);
        rdata = {rdata, rbyte};
    end while (rbyte != 8'h0a);     /* '\n' */

    rdata = rdata.substr(0, rdata.len() - 2);
endtask

task write_message(input string wdata);
    foreach (wdata[i]) begin
        write_byte(wdata[i]);
        #1us;
    end
    write_byte("\n");
endtask

endmodule
