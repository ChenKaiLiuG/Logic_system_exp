`timescale 1ns/1ns

module Marquee_tb;

    reg clk;
    reg rst;
    wire [3:0] led;
    wire led4_g;
    wire led5_g;

    Marquee uut (
        .clk(clk),
        .rst(rst),
        .led(led),
        .led4_g(led4_g),
        .led5_g(led5_g)
    );

    parameter CLK_PERIOD = 8; // 125MHz (1 / 125,000,000 = 8ns)
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    initial begin
        rst = 1;
        #10; // rst 10 ns
        rst = 0;
        #100000000; 
        $finish;
    end

    initial begin
        $monitor("Time=%t, rst=%b, led=%b, led4_g=%b, led5_g=%b", $time, rst, led, led4_g, led5_g);
    end

endmodule
