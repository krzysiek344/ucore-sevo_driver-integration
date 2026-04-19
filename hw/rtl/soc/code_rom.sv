/* Copyright (C) 2025  AGH University of Krakow */

module code_rom (
    input logic clk,
    input logic rst_n,

    ibus.slave  ibus,
    dbus.slave  dbus
);


/* Local variables and signals */

(* ram_style = "block" *) logic [31:0] mem [4096];
logic [31:0] address, readdata;
logic read, ibus_readdatavalid_nxt, dbus_readdatavalid_nxt;


/* Signals assignments */

assign ibus.rdata = readdata;
assign dbus.rdata = readdata;


/* Module internal logic */

`ifdef FPGA
initial begin
    $readmemh("app.mem", mem);
end
`endif

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        ibus.rvalid <= 1'b0;
        dbus.rvalid <= 1'b0;
    end else begin
        ibus.rvalid <= ibus_readdatavalid_nxt;
        dbus.rvalid <= dbus_readdatavalid_nxt;
    end
end

always_comb begin
    ibus_readdatavalid_nxt = 1'b0;
    dbus_readdatavalid_nxt = 1'b0;

    address = 32'b0;
    read = 1'b0;

    if (dbus.rreq) begin
        dbus.stall = 1'b0;
        dbus_readdatavalid_nxt = dbus.rreq;

        address = dbus.addr;
        read = 1'b1;
    end else if (ibus.rreq) begin
        dbus.stall = 1'b1;
        ibus_readdatavalid_nxt = 1'b1;

        address = ibus.addr;
        read = 1'b1;
    end else begin
        dbus.stall = 1'b1;
    end
end

always_ff @(posedge clk) begin
    if (read)
        readdata <= mem[address[13:2]];
end

endmodule
