/* Copyright (C) 2025  AGH University of Krakow */

module timer_counter (
    input logic         clk,
    input logic         rst_n,

    output logic [31:0] value,
    input logic         en
);


/* User defined types */

typedef enum logic {
    IDLE,
    ACTIVE
} state_t;


/* Local variables and signals */

state_t      state, state_nxt;

logic [31:0] value_nxt;


/* Module internal logic */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        state <= IDLE;
    else
        state <= state_nxt;
end

always_comb begin
    state_nxt = state;

    case (state)
    IDLE: begin
        if (en)
            state_nxt = ACTIVE;
    end
    ACTIVE: begin
        if (!en)
            state_nxt = IDLE;
    end
    endcase
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        value <= 32'b0;
    else
        value <= value_nxt;
end

always_comb begin
    value_nxt = value;

    case (state)
    IDLE: begin
        if (en)
            value_nxt = 32'b0;
    end
    ACTIVE: begin
        value_nxt = value + 1;
    end
    endcase
end

endmodule
