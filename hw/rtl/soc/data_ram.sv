/* Copyright (C) 2025  AGH University of Krakow */

 module data_ram (
    input logic clk,
    input logic rst_n,

    dbus.slave  dbus
);


/* Local variables and signals */

(* ram_style = "block" *) logic [31:0] mem [4096];


/* Signals assignments */

assign dbus.stall = 1'b0;


/* Module internal logic */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        dbus.rvalid <= 1'b0;
    else
        dbus.rvalid <= dbus.rreq;
end

always_ff @(posedge clk) begin
    if (dbus.rreq || dbus.wreq) begin
        if (dbus.wreq) begin
            if (dbus.be[3])
                mem[dbus.addr[13:2]][31:24] <= dbus.wdata[31:24];
            if (dbus.be[2])
                mem[dbus.addr[13:2]][23:16] <= dbus.wdata[23:16];
            if (dbus.be[1])
                mem[dbus.addr[13:2]][15:8] <= dbus.wdata[15:8];
            if (dbus.be[0])
                mem[dbus.addr[13:2]][7:0] <= dbus.wdata[7:0];
        end

        dbus.rdata <= mem[dbus.addr[13:2]];
    end
end

endmodule
