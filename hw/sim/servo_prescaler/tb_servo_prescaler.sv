module tb_servo_prescaler;


/* Local variables and signals */

logic       clk, rst_n;
logic       step_tick;
logic       enable;
logic [7:0] scale_val;


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

prescaler #(
    .SCALE_WIDTH(8)
) dut (
    .clk,
    .rst_n,

    .step_tick,
    .enable,
    .scale_val
);


/* Tasks and functions definitions */

task check_tick(input logic exp_tick);
    assert (step_tick == exp_tick) else
        $error("step_tick: exp: %b, rcv: %b", exp_tick, step_tick);
endtask

task test_reset();
    enable = 1'b1;
    scale_val = 8'd4;

    u_rst_n_gen.reset();

    #1;
    check_tick(1'b0);
endtask

task test_disabled();
    enable = 1'b0;
    scale_val = 8'd3;

    u_rst_n_gen.reset();

    repeat (10) begin
        @(negedge clk);
        #1;
        check_tick(1'b0);
    end
endtask

task test_scale(input logic [7:0] scale);
    logic exp_tick;

    scale_val = scale;
    enable = 1'b0;

    u_rst_n_gen.reset();
    @(negedge clk);
    enable = 1'b1;
    #1;

    for (int i = 0; i < scale * 3; ++i) begin
        exp_tick = ((i % scale) == (scale - 1));

        check_tick(exp_tick);
        @(negedge clk);
        #1;
    end
endtask

task test_disable_clears_counter();
    enable = 1'b0;
    scale_val = 8'd4;

    u_rst_n_gen.reset();
    @(negedge clk);
    enable = 1'b1;
    #1;
    check_tick(1'b0);

    repeat (2)
        @(negedge clk);

    enable = 1'b0;
    #1;
    check_tick(1'b0);

    repeat (3) begin
        @(negedge clk);
        #1;
        check_tick(1'b0);
    end

    enable = 1'b1;
    #1;
    check_tick(1'b0);

    @(negedge clk);
    #1;
    check_tick(1'b0);

    @(negedge clk);
    #1;
    check_tick(1'b0);

    @(negedge clk);
    #1;
    check_tick(1'b1);
endtask


/* Test */

initial begin
    enable = 1'b0;
    scale_val = 8'd1;

    u_rst_n_gen.reset();

    test_reset();
    test_disabled();
    test_scale(8'd1);
    test_scale(8'd2);
    test_scale(8'd4);
    test_disable_clears_counter();

    $finish;
end

endmodule
