module servo (
    input logic        clk,
    input logic        rst_n,

    dbus.slave         dbus,

    output logic [3:0] stepper_phases,
    input logic        sensor_raw
);


/* Constants */

const logic [11:0] CR_OFFSET          = 12'h000,
                   SR_OFFSET          = 12'h004,
                   TARGET_POS_OFFSET  = 12'h008,
                   CURRENT_POS_OFFSET = 12'h00c,
                   SCALE_OFFSET       = 12'h010;


/* Local variables and signals */

logic [31:0] cr, cr_nxt;
logic [31:0] sr, sr_nxt;
logic [31:0] target_pos, target_pos_nxt;
logic [31:0] scale_val, scale_val_nxt;
logic [31:0] current_pos;
logic [31:0] dbus_rdata_nxt;

logic        callib_done;


/* Submodules placement */

top_servo_drv u_top_servo_drv (
    .clk,
    .rst_n,

    .stepper_phases,
    .callib_done,
    .current_pos,

    .enable(cr[0]),
    .callib(cr[1]),
    .go_to(cr[2]),
    .target_pos,
    .scale_val,
    .inversion(cr[3]),
    .sensor_raw
);


/* Module internal logic */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cr         <= 32'b0;
        sr         <= 32'b0;
        target_pos <= 32'b0;
        scale_val  <= 32'd1;
    end else begin
        cr         <= cr_nxt;
        sr         <= sr_nxt;
        target_pos <= target_pos_nxt;
        scale_val  <= scale_val_nxt;
    end
end

always_comb begin
    cr_nxt         = cr;
    sr_nxt         = sr;
    target_pos_nxt = target_pos;
    scale_val_nxt  = scale_val;

    if (dbus.wreq) begin
        case (dbus.addr[11:0])
        CR_OFFSET: begin
            cr_nxt = dbus.wdata;

            if (dbus.wdata[1])
                sr_nxt[0] = 1'b0;

            if (dbus.wdata[2])
                sr_nxt[1] = 1'b0;
        end
        TARGET_POS_OFFSET: begin
            target_pos_nxt = dbus.wdata;
        end
        SCALE_OFFSET: begin
            scale_val_nxt = dbus.wdata;
        end
        endcase
    end

    if (callib_done && cr[1]) begin
        cr_nxt[1] = 1'b0;
        sr_nxt[0] = 1'b1;
    end

    if ((current_pos == target_pos) && cr[2]) begin
        cr_nxt[2] = 1'b0;
        sr_nxt[1] = 1'b1;
    end

    sr_nxt[2] = cr_nxt[1] | cr_nxt[2];
    sr_nxt[3] = sensor_raw;
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
        CR_OFFSET:          dbus_rdata_nxt = cr;
        SR_OFFSET:          dbus_rdata_nxt = sr;
        TARGET_POS_OFFSET:  dbus_rdata_nxt = target_pos;
        CURRENT_POS_OFFSET: dbus_rdata_nxt = current_pos;
        SCALE_OFFSET:       dbus_rdata_nxt = scale_val;
        endcase
    end
end

endmodule
