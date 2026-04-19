/* Copyright (C) 2025  AGH University of Krakow */

module ifu #(
    BOOT_ADDRESS = 32'h0
) (
    input logic         clk,
    input logic         rst_n,

    ibus.master         ibus,

    input logic         stall,
    input logic         branch,
    input logic         relative_jump,
    input logic         absolute_jump,

    output logic [31:0] pc,
    output logic        ibus_rvalid,
    output logic [31:0] ibus_rdata,
    input logic [31:0]  rf_rdata,
    input logic [31:0]  imm
);


/* User defined types */

typedef enum logic [1:0] {
    INITIALIZATION,
    LINEAR_FETCHING,
    NON_LINEAR_FETCHING
} state_t;


/* Local variables and signals */

state_t      state, state_nxt;
logic [31:0] pc_nxt, ibus_address, ibus_address_prv, ibus_rdata_nxt;
logic        ibus_rvalid_nxt;


/* Signals assignments */

assign ibus.addr = ibus_address;
assign ibus.rreq = 1'b1;


/* Module internal logic */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        state <= INITIALIZATION;
    else
        state <= state_nxt;
end

always_comb begin
    state_nxt = state;

    case (state)
    INITIALIZATION: begin
        state_nxt = LINEAR_FETCHING;
    end
    LINEAR_FETCHING: begin
        if (branch || relative_jump || absolute_jump)
            state_nxt = NON_LINEAR_FETCHING;
    end
    NON_LINEAR_FETCHING: begin
        if (ibus.rvalid)
            state_nxt = LINEAR_FETCHING;
    end
    endcase
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        ibus_address_prv <= 32'b0;
        pc <= 32'b0;
        ibus_rvalid <= 1'b0;
        ibus_rdata <= 32'b0;
    end else begin
        ibus_address_prv <= ibus_address;
        pc <= pc_nxt;
        ibus_rvalid <= ibus_rvalid_nxt;
        ibus_rdata <= ibus_rdata_nxt;
    end
end

always_comb begin
    ibus_address = ibus_address_prv;
    pc_nxt = pc;
    ibus_rvalid_nxt = 1'b0;
    ibus_rdata_nxt = ibus_rdata;

    case (state)
    INITIALIZATION: begin
        ibus_address = BOOT_ADDRESS;
    end
    LINEAR_FETCHING: begin
        if (stall) begin
            ibus_address = ibus_address_prv;
            pc_nxt = pc;
            ibus_rvalid_nxt = 1'b0;
            ibus_rdata_nxt = ibus_rdata;
        end else if (branch) begin
            ibus_address = pc + imm;
            pc_nxt = pc;
            ibus_rvalid_nxt = 1'b0;
            ibus_rdata_nxt = ibus_rdata;
        end else if (relative_jump) begin
            ibus_address = pc + imm;
            pc_nxt = pc;
            ibus_rvalid_nxt = 1'b0;
            ibus_rdata_nxt = ibus_rdata;
        end else if (absolute_jump) begin
            ibus_address = (rf_rdata + imm) & 32'hffff_fffe;
            pc_nxt = pc;
            ibus_rvalid_nxt = 1'b0;
            ibus_rdata_nxt = ibus_rdata;
        end else begin
            if (ibus.rvalid) begin
                ibus_address = ibus_address_prv + 4;
                pc_nxt = ibus_address_prv;
                ibus_rvalid_nxt = 1'b1;
                ibus_rdata_nxt = ibus.rdata;
            end
        end
    end
    NON_LINEAR_FETCHING: begin
        if (ibus.rvalid) begin
            ibus_address = ibus_address_prv + 4;
            pc_nxt = ibus_address_prv;
            ibus_rvalid_nxt = 1'b1;
            ibus_rdata_nxt = ibus.rdata;
        end
    end
    endcase
end

endmodule
