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

task check_read(input logic [11:0] offset, input logic [31:0] exp_data);
    logic [31:0] rdata;

    dbus_read(offset, rdata);
    assert (rdata == exp_data) else
        $error("offset: 0x%x; exp: 0x%x, rcv: 0x%x", offset, exp_data, rdata);
endtask

task wait_until_current_pos(input logic [31:0] exp_pos);
    int timeout;
    logic [31:0] rdata;

    timeout = 0;
    dbus_read(CURRENT_POS_OFFSET, rdata);

    while (rdata != exp_pos && timeout < 100) begin
        dbus_read(CURRENT_POS_OFFSET, rdata);
        timeout++;
    end

    assert (rdata == exp_pos) else
        $error("CURRENT_POS timeout: exp: 0x%x, rcv: 0x%x", exp_pos, rdata);
endtask

task test_reset_values();
    logic [31:0] rdata;

    dbus_read(CR_OFFSET, rdata);
    assert (rdata == 32'b0) else                          
        $error("CR: exp: 0x%x, rcv: 0x%x", 32'b0, rdata);

    dbus_read(SR_OFFSET, rdata);
    assert (rdata[2:0] == 3'b0 && rdata[31:4] == 28'b0) else                                // nie chcemy patrzec na 'sensor raw'
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
            $error("TARGET_POS: exp: 0x%x, rcv: 0x%x", wdata, rdata);

        wdata = {$random()} & 32'h0000_0009;          // nie chemy odpalac goto oraz callib gdy enable moze =1

        dbus_write(CR_OFFSET, wdata);
        dbus_read(CR_OFFSET, rdata);
        assert (rdata == wdata) else
            $error("CR: exp: 0x%x, rcv: 0x%x", wdata, rdata);
    end
endtask

task test_read_only_registers();
    u_rst_n_gen.reset();

    sensor_raw = 1'b1;

    dbus_write(SR_OFFSET, 32'hffff_ffff);
    check_read(SR_OFFSET, 32'b0);

    dbus_write(CURRENT_POS_OFFSET, 32'h1234_5678);
    check_read(CURRENT_POS_OFFSET, 32'b0);
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

task test_sensor_status();
    logic [31:0] rdata;

    sensor_raw = 1'b0;

    @(negedge clk);
    dbus_read(SR_OFFSET, rdata);
    assert (rdata[3] == 1'b0) else
        $error("SR[3]: exp: 0x%x, rcv: 0x%x", 1'b0, rdata[3]);

    sensor_raw = 1'b1;

    @(negedge clk);
    dbus_read(SR_OFFSET, rdata);
    assert (rdata[3] == 1'b1) else
        $error("SR[3]: exp: 0x%x, rcv: 0x%x", 1'b1, rdata[3]);
endtask

task test_callib_busy();
    logic [31:0] rdata;

    u_rst_n_gen.reset();

    sensor_raw = 1'b1;

    dbus_write(CR_OFFSET, 32'h0000_0003); // enable + callib

    dbus_read(SR_OFFSET, rdata);
    assert (rdata[2] == 1'b1) else
        $error("SR[2]: exp: 0x%x, rcv: 0x%x", 1'b1, rdata[2]);

    u_rst_n_gen.reset();
endtask

task test_callib_busy_without_enable();
    logic [31:0] rdata;

    u_rst_n_gen.reset();

    dbus_write(CR_OFFSET, 32'h0000_0002); // callib, enable = 0

    dbus_read(SR_OFFSET, rdata);
    assert (rdata[2] == 1'b1) else
        $error("SR[2]: exp: 0x%x, rcv: 0x%x", 1'b1, rdata[2]);
endtask

task test_callib_done();
    logic [31:0] rdata;

    u_rst_n_gen.reset();

    sensor_raw = 1'b1;

    dbus_write(CR_OFFSET, 32'h0000_0003); // enable + callib

    dbus_read(SR_OFFSET, rdata);
    assert (rdata[2] == 1'b1) else
        $error("SR[2]: exp: 0x%x, rcv: 0x%x", 1'b1, rdata[2]);

    sensor_raw = 1'b0;

    for (int i = 0; i < 1_000_020; ++i)
        @(negedge clk);

    dbus_read(CR_OFFSET, rdata);
    assert (rdata[1] == 1'b0) else
        $error("CR[1]: exp: 0x%x, rcv: 0x%x", 1'b0, rdata[1]);

    dbus_read(SR_OFFSET, rdata);
    assert (rdata[0] == 1'b1) else
        $error("SR[0]: exp: 0x%x, rcv: 0x%x", 1'b1, rdata[0]);

    assert (rdata[2] == 1'b0) else
        $error("SR[2]: exp: 0x%x, rcv: 0x%x", 1'b0, rdata[2]);

    sensor_raw = 1'b1;
endtask

task test_go_to_busy();
    logic [31:0] rdata;

    u_rst_n_gen.reset();

    dbus_write(SCALE_OFFSET, 32'd1);
    dbus_write(TARGET_POS_OFFSET, 32'd3);
    dbus_write(CR_OFFSET, 32'h0000_0005); // enable + go_to

    dbus_read(SR_OFFSET, rdata);
    assert (rdata[2] == 1'b1) else
        $error("SR[2]: exp: 0x%x, rcv: 0x%x", 1'b1, rdata[2]);
endtask

task test_go_to_done();
    logic [31:0] rdata;

    u_rst_n_gen.reset();

    dbus_write(SCALE_OFFSET, 32'd2);
    dbus_write(TARGET_POS_OFFSET, 32'd3);
    dbus_write(CR_OFFSET, 32'h0000_0005); // enable + go_to

    wait_until_current_pos(32'd3);

    dbus_read(SR_OFFSET, rdata);
    assert (rdata == 32'h0000_0002) else
        $error("SR: exp: 0x%x, rcv: 0x%x", 32'h0000_0002, rdata);

    dbus_read(CR_OFFSET, rdata);
    assert (rdata == 32'h0000_0001) else
        $error("CR: exp: 0x%x, rcv: 0x%x", 32'h0000_0001, rdata);

    dbus_write(CURRENT_POS_OFFSET, 32'h1234_5678);
    check_read(CURRENT_POS_OFFSET, 32'd3);

    dbus_write(SR_OFFSET, 32'b0);
    check_read(SR_OFFSET, 32'h0000_0002);
endtask

task test_go_to_busy_without_enable();
    logic [31:0] rdata;

    u_rst_n_gen.reset();

    dbus_write(TARGET_POS_OFFSET, 32'd3);
    dbus_write(CR_OFFSET, 32'h0000_0004); // go_to, enable = 0

    dbus_read(SR_OFFSET, rdata);
    assert (rdata[2] == 1'b1) else
        $error("SR[2]: exp: 0x%x, rcv: 0x%x", 1'b1, rdata[2]);
endtask



/* Test */

initial begin
    sensor_raw = 1'b1;

    u_rst_n_gen.reset();

    test_reset_after_random_writes();
    test_register_write_read();
    test_read_only_registers();
    test_sensor_status();
    test_callib_busy();
    test_callib_done();
    test_callib_busy_without_enable();
    test_go_to_busy();
    test_go_to_done();
    test_go_to_busy_without_enable();

    $finish;
end

endmodule
