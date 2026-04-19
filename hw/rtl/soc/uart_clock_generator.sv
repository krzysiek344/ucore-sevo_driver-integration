/* Copyright (C) 2025  AGH University of Krakow */

module uart_clock_generator (
    input logic       clk,
    input logic       rst_n,

    input logic       en,
    input logic [7:0] divider,

    output logic      sck,
    output logic      sck_rising_edge,
    output logic      sck_falling_edge
);


/* Local variables and signals */

logic [7:0] counter, counter_nxt;
logic       sck_nxt, sck_rising_edge_nxt, sck_falling_edge_nxt;


/* Module internal logic */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        counter <= 8'b0;
        sck <= 1'b0;
        sck_rising_edge <= 1'b0;
        sck_falling_edge <= 1'b0;
    end else begin
        counter <= counter_nxt;
        sck <= sck_nxt;
        sck_rising_edge <= sck_rising_edge_nxt;
        sck_falling_edge <= sck_falling_edge_nxt;
    end
end

always_comb begin
    counter_nxt = 8'b0;
    sck_nxt = 1'b0;
    sck_rising_edge_nxt = 1'b0;
    sck_falling_edge_nxt = 1'b0;

    if (en && divider > 0) begin
        if (counter == divider - 1) begin
            counter_nxt = 8'b0;
            sck_nxt = ~sck;
            sck_rising_edge_nxt = ~sck;
            sck_falling_edge_nxt = sck;
        end else begin
            counter_nxt = counter + 1;
        end
    end
end

endmodule
