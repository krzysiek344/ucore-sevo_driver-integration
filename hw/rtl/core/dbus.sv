/* Copyright (C) 2025  AGH University of Krakow */

interface dbus;

logic [31:0] addr, rdata, wdata;
logic [3:0]  be;
logic        rreq, rvalid, wreq, stall;

modport master (
    output addr,
    output be,
    output rreq,
    output wreq,
    output wdata,
    input stall,
    input rvalid,
    input rdata
);

modport slave (
    output stall,
    output rvalid,
    output rdata,
    input addr,
    input be,
    input rreq,
    input wreq,
    input wdata
);

endinterface
