`timescale 1ns/1ps

// Testbench for the registered 4-bit array multiplier (mult_array).
// - 10 ns clock, rst_n held low for the first 2 cycles
// - Exhaustively applies all 256 (a, b) combinations
// - Waits for the 2-cycle latency (launch reg -> capture reg) and checks p == a*b
// - Prints every mismatch and a single PASS/FAIL summary line
// - Dumps waveforms to mult.vcd

module tb_mult;

    reg        clk;
    reg        rst_n;
    reg  [3:0] a;
    reg  [3:0] b;
    wire [7:0] p;

    reg  [7:0] expected;
    integer    i, j;
    integer    errors;
    integer    checked;

    // Device under test
    mult_array dut (
        .clk   (clk),
        .rst_n (rst_n),
        .a     (a),
        .b     (b),
        .p     (p)
    );

    // 10 ns clock period
    initial clk = 1'b0;
    always #5 clk = ~clk;

    // Waveform dump
    initial begin
        $dumpfile("mult.vcd");
        $dumpvars(0, tb_mult);
    end

    // Stimulus and checking
    initial begin
        errors  = 0;
        checked = 0;
        a       = 4'd0;
        b       = 4'd0;
        rst_n   = 1'b0;

        // Hold reset low for the first 2 clock cycles
        repeat (2) @(posedge clk);
        @(negedge clk);
        rst_n = 1'b1;

        for (i = 0; i < 16; i = i + 1) begin
            for (j = 0; j < 16; j = j + 1) begin
                // Drive inputs on the falling edge to avoid races with posedge
                @(negedge clk);
                a = i[3:0];
                b = j[3:0];
                expected = i * j;

                // 2-cycle latency: 1st posedge -> input regs, 2nd posedge -> output reg
                @(posedge clk);
                @(posedge clk);
                #1;

                checked = checked + 1;
                if (p !== expected) begin
                    errors = errors + 1;
                    $display("MISMATCH: a=%0d b=%0d expected=%0d got=%0d (time=%0t)",
                             i, j, expected, p, $time);
                end
            end
        end

        if (errors == 0)
            $display("PASS: %0d vectors checked, 0 errors", checked);
        else
            $display("FAIL: %0d vectors checked, %0d errors", checked, errors);

        $finish;
    end

endmodule
