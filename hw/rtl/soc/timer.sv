/* Copyright (C) 2025  AGH University of Krakow */

module timer (
    input logic clk,
    input logic rst_n,

    dbus.slave  dbus
);


/* Constants */

const logic [11:0] CR_OFFSET = 12'h000,
                   SR_OFFSET = 12'h004;


/* Local variables and signals */

logic [31:0] cr, cr_nxt, sr, sr_nxt, counter_value, dbus_rdata_nxt;


/* Submodules placement */

timer_counter u_timer_counter (
    .clk,
    .rst_n,

    .value(counter_value),
    .en(cr[0])
);


/* Module internal logic */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cr <= 32'b0;
        sr <= 32'b0;
    end else begin
        cr <= cr_nxt;
        sr <= sr_nxt;
    end
end

always_comb begin
    cr_nxt = cr;
    sr_nxt = sr;

    if (dbus.wreq) begin
        case (dbus.addr[11:0])
        CR_OFFSET:  cr_nxt = dbus.wdata;
        endcase
    end

    sr_nxt = counter_value;
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        dbus.rdata <= 32'b0;
    else
        dbus.rdata <= dbus_rdata_nxt;
end

always_comb begin
    dbus_rdata_nxt = dbus.rdata;

    if (dbus.rreq) begin
        case (dbus.addr[11:0])
        CR_OFFSET:  dbus_rdata_nxt = cr;
        SR_OFFSET:  dbus_rdata_nxt = sr;
        endcase
    end
end

endmodule
