/* Copyright (C) 2025  AGH University of Krakow */

module uart (
    input logic  clk,
    input logic  rst_n,

    dbus.slave   dbus,

    output logic sout,
    input logic  sin
);


/* Constants */

const logic [11:0] CR_OFFSET = 12'h000,
                   SR_OFFSET = 12'h004,
                   CCR_OFFSET = 12'h008,
                   WDR_OFFSET = 12'h00c,
                   RDR_OFFSET = 12'h010;


/* Local variables and signals */

logic [31:0] cr, cr_nxt, sr, sr_nxt, ccr, ccr_nxt, wdr, wdr_nxt, rdr, rdr_nxt, dbus_rdata_nxt;
logic [7:0]  rx_data;
logic        tx_data_valid, tx_busy, rx_data_valid, sck_rising_edge;


/* Submodules placement */

uart_clock_generator u_uart_clock_generator (
    .clk,
    .rst_n,

    .en(cr[0]),
    .divider(ccr[7:0]),

    .sck(),
    .sck_rising_edge,
    .sck_falling_edge()
);

uart_transmitter u_uart_transmitter (
    .clk,
    .rst_n,

    .sck_rising_edge,
    .edges_per_bit(ccr[15:8]),

    .busy(tx_busy),
    .tx_data_valid,
    .tx_data(wdr[7:0]),

    .sout
);

uart_receiver u_uart_receiver (
    .clk,
    .rst_n,

    .sck_rising_edge,
    .edges_per_bit(ccr[15:8]),

    .busy(),
    .error(),
    .rx_data_valid,
    .rx_data,

    .sin
);


/* Module internal logic */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cr <= 32'b0;
        sr <= 32'b0;
        ccr <= 32'b0;
        wdr <= 32'b0;
        rdr <= 32'b0;
    end else begin
        cr <= cr_nxt;
        sr <= sr_nxt;
        ccr <= ccr_nxt;
        wdr <= wdr_nxt;
        rdr <= rdr_nxt;
    end
end

always_comb begin
    cr_nxt = cr;
    sr_nxt = sr;
    ccr_nxt = ccr;
    wdr_nxt = wdr;
    rdr_nxt = rdr;

    if (dbus.wreq) begin
        case (dbus.addr[11:0])
        CR_OFFSET:  cr_nxt = dbus.wdata;
        SR_OFFSET:  sr_nxt = dbus.wdata;
        CCR_OFFSET: ccr_nxt = dbus.wdata;
        WDR_OFFSET: wdr_nxt = dbus.wdata;
        RDR_OFFSET: rdr_nxt = dbus.wdata;
        endcase
    end

    sr_nxt[1] = tx_busy;

    if (dbus.rreq && (dbus.addr[11:0] == RDR_OFFSET))
        sr_nxt[0] = 1'b0;

    if (rx_data_valid) begin
        sr_nxt[0] = 1'b1;
        rdr_nxt[7:0] = rx_data;
    end
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
        CCR_OFFSET: dbus_rdata_nxt = ccr;
        WDR_OFFSET: dbus_rdata_nxt = wdr;
        RDR_OFFSET: dbus_rdata_nxt = rdr;
        endcase
    end
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        tx_data_valid <= 1'b0;
    else
        tx_data_valid <= dbus.wreq && (dbus.addr[11:0] == WDR_OFFSET);
end

endmodule
