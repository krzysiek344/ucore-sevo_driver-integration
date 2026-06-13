module tb_servo_top_driver;


/* Constants */

localparam int TIMEOUT_CYCLES = 100;


/* Local variables and signals */

logic       clk, rst_n;
logic [3:0] stepper_phases;
logic       callib_done;
logic [7:0] current_pos;
logic       enable;
logic       callib;
logic       go_to;
logic [7:0] target_pos;
logic [7:0] scale_val;
logic       inversion;
logic       sensor_raw;


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

top_servo_drv #(
    .POS_RANGE(8),
    .SCALE_WIDTH(8),
    .DELAY_CYCLES(4),
    .COILS_NUM(4)
) dut (
    .clk,
    .rst_n,

    .stepper_phases,
    .callib_done,
    .current_pos,

    .enable,
    .callib,
    .go_to,
    .target_pos,
    .scale_val,
    .inversion,
    .sensor_raw
);


/* Tasks and functions definitions */

task clear_inputs();
    enable = 1'b0;
    callib = 1'b0;
    go_to = 1'b0;
    target_pos = 8'b0;
    scale_val = 8'd2;
    inversion = 1'b0;
    sensor_raw = 1'b1;
endtask

task wait_cycle();
    @(negedge clk);
    #1;
endtask

task check_pos(input logic [7:0] exp_pos);
    assert (current_pos == exp_pos) else
        $error("current_pos: exp: 0x%x, rcv: 0x%x", exp_pos, current_pos);
endtask

task check_phases(input logic [3:0] exp_phases);
    assert (stepper_phases == exp_phases) else
        $error("stepper_phases: exp: %b, rcv: %b", exp_phases, stepper_phases);
endtask

task check_callib_done(input logic exp_callib_done);
    assert (callib_done == exp_callib_done) else
        $error("callib_done: exp: %b, rcv: %b", exp_callib_done, callib_done);
endtask

task wait_until_pos(input logic [7:0] exp_pos);
    int timeout;

    timeout = 0;

    while (current_pos != exp_pos && timeout < TIMEOUT_CYCLES) begin
        wait_cycle();
        timeout++;
    end

    assert (current_pos == exp_pos) else
        $error("current_pos timeout: exp: 0x%x, rcv: 0x%x", exp_pos, current_pos);
endtask

task wait_until_callib_done();
    int timeout;

    timeout = 0;

    while (!callib_done && timeout < TIMEOUT_CYCLES) begin
        wait_cycle();
        timeout++;
    end

    assert (callib_done) else
        $error("callib_done timeout");
endtask

task start_go_to(input logic [7:0] position);
    target_pos = position;
    go_to = 1'b1;
endtask

task stop_go_to();
    go_to = 1'b0;
    wait_cycle();
    wait_cycle();
endtask

task test_reset();
    enable = 1'b1;
    callib = 1'b1;
    go_to = 1'b1;
    target_pos = 8'd3;
    scale_val = 8'd2;
    inversion = 1'b1;
    sensor_raw = 1'b0;

    u_rst_n_gen.reset();

    #1;
    check_pos(8'b0);
    check_phases(4'b1110);
    check_callib_done(1'b0);
endtask

task test_go_to_forward();
    clear_inputs();
    u_rst_n_gen.reset();

    enable = 1'b1;
    start_go_to(8'd3);

    wait_until_pos(8'd3);

    check_phases(4'b1000);
    stop_go_to();
    check_pos(8'd3);
endtask

task test_go_to_backward();
    clear_inputs();
    u_rst_n_gen.reset();

    enable = 1'b1;
    start_go_to(8'd4);
    wait_until_pos(8'd4);
    stop_go_to();
    check_phases(4'b0001);

    start_go_to(8'd1);
    wait_until_pos(8'd1);

    check_phases(4'b0010);
    stop_go_to();
    check_pos(8'd1);
endtask

task test_callib_sets_zero();
    clear_inputs();
    u_rst_n_gen.reset();

    enable = 1'b1;
    start_go_to(8'd3);
    wait_until_pos(8'd3);
    stop_go_to();
    check_pos(8'd3);

    sensor_raw = 1'b1;
    callib = 1'b1;

    repeat (4)
        wait_cycle();

    sensor_raw = 1'b0;

    wait_until_callib_done();
    wait_cycle();
    check_pos(8'b0);

    callib = 1'b0;
    wait_cycle();
    check_callib_done(1'b0);
endtask

task test_inversion();
    clear_inputs();
    u_rst_n_gen.reset();

    check_phases(4'b0001);

    inversion = 1'b1;
    #1;
    check_phases(4'b1110);

    enable = 1'b1;
    start_go_to(8'd1);
    wait_until_pos(8'd1);

    check_phases(4'b1101);
endtask


/* Test */

initial begin
    clear_inputs();

    u_rst_n_gen.reset();

    test_reset();
    test_go_to_forward();
    test_go_to_backward();
    test_callib_sets_zero();
    test_inversion();

    $finish;
end

endmodule
