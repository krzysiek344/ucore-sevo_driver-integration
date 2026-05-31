module tb_servo_wrapper;


/* Adress offsets */

const logic [11:0] CR_OFFSET          = 12'h000,
                   SR_OFFSET          = 12'h004,
                   TARGET_POS_OFFSET  = 12'h008,
                   CURRENT_POS_OFFSET = 12'h00c,
                   SCALE_OFFSET       = 12'h010;


/* Local variables and signals */

logic       clk, rst_n;
logic [3:0] stepper_phases;
logic       sensor_raw;

dbus servo_dbus ();


/* Submodules placement */

clk_gen #(
    .FREQUENCY_MHZ(50)
) u_clk_gen (
    .clk
);

rst_n_gen u_rst_n_gen (
    .rst_n,
    .clk
);

servo dut (
    .clk,
    .rst_n,

    .dbus(servo_dbus),

    .stepper_phases,
    .sensor_raw
);


/* Tasks and functions definitions */

task dbus_write(input logic [11:0] offset, input logic [31:0] wdata);
    @(negedge clk);
    servo_dbus.addr = {20'b0, offset};
    servo_dbus.be = 4'hf;
    servo_dbus.wdata = wdata;
    servo_dbus.wreq = 1'b1;
    servo_dbus.rreq = 1'b0;

    @(negedge clk);
    servo_dbus.wreq = 1'b0;
    servo_dbus.wdata = 32'b0;
endtask

task dbus_read(input logic [11:0] offset, output logic [31:0] rdata);
    @(negedge clk);
    servo_dbus.addr = {20'b0, offset};
    servo_dbus.be = 4'hf;
    servo_dbus.wreq = 1'b0;
    servo_dbus.rreq = 1'b1;

    @(negedge clk);
    servo_dbus.rreq = 1'b0;
    rdata = servo_dbus.rdata;
endtask

task test_reset_values();
    logic [31:0] rdata;

    dbus_read(CR_OFFSET, rdata);
    assert (rdata == 32'b0) else
        $error("CR: exp: 0x%x, rcv: 0x%x", 32'b0, rdata);

    dbus_read(SR_OFFSET, rdata);
    assert (rdata == 32'b0) else
        $error("SR: exp: 0x%x, rcv: 0x%x", 32'b0, rdata);

    dbus_read(TARGET_POS_OFFSET, rdata);
    assert (rdata == 32'b0) else
        $error("TARGET_POS: exp: 0x%x, rcv: 0x%x", 32'b0, rdata);

    dbus_read(CURRENT_POS_OFFSET, rdata);
    assert (rdata == 32'b0) else
        $error("CURRENT_POS: exp: 0x%x, rcv: 0x%x", 32'b0, rdata);

    dbus_read(SCALE_OFFSET, rdata);
    assert (rdata == 32'd1) else
        $error("SCALE: exp: 0x%x, rcv: 0x%x", 32'd1, rdata);
endtask

task test_register_write_read();
    logic [31:0] rdata, wdata;

    for(int i = 0; i < 50; i++) begin

        wdata = $random();

        dbus_write(SCALE_OFFSET, wdata);
        dbus_read(SCALE_OFFSET, rdata);
        assert (rdata == wdata) else
            $error("SCALE: exp: 0x%x, rcv: 0x%x", wdata, rdata);

        wdata = $random();

        dbus_write(TARGET_POS_OFFSET, wdata);
        dbus_read(TARGET_POS_OFFSET, rdata);
        assert (rdata == wdata) else
            $error("SCALE: exp: 0x%x, rcv: 0x%x", wdata, rdata);

        wdata = {$random()} & 32'h0000_0009;          // nie chemy odpalac goto oraz callib gdy enable moze =1

        dbus_write(CR_OFFSET, wdata);
        dbus_read(CR_OFFSET, rdata);
        assert (rdata == wdata) else
            $error("CR: exp: 0x%x, rcv: 0x%x", wdata, rdata);
    end
endtask

task test_reset_after_random_writes();
    logic [31:0] wdata;

    for (int i = 0; i < 10; ++i) begin
        wdata = $random();
        dbus_write(SCALE_OFFSET, wdata);

        wdata = $random();
        dbus_write(TARGET_POS_OFFSET, wdata);

        wdata = $random() & 32'h0000_0009;
        dbus_write(CR_OFFSET, wdata);

        u_rst_n_gen.reset();
        test_reset_values();
    end
endtask


/* Test */

initial begin
    u_rst_n_gen.reset();

    test_reset_after_random_write();
    test_register_write_read();

    $finish;
end

endmodule