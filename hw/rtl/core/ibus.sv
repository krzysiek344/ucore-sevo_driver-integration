/* Copyright (C) 2025  AGH University of Krakow */

interface ibus;

logic [31:0] addr, rdata;
logic        rreq, rvalid;

modport master (
    output addr,
    output rreq,
    input rvalid,
    input rdata
);

modport slave (
    output rvalid,
    output rdata,
    input addr,
    input rreq
);

endinterface
