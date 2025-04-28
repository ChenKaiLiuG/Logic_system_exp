`timescale 1ns/1ns

module Marquee_tb;

    reg clk;
    reg rst;
    wire [3:0] led;

    Marquee uut (
        .clk(clk),
        .rst(rst),
        .led(led)
    );
    
    localparam CLK_PERIOD = 8; // 125MHz ，1/125,000,000 = 8 ns

    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    initial begin
        rst = 1;
        #10; 
        rst = 0;
        #100000; 
        $finish; 
    end

    initial begin
        $monitor("Time = %t, rst = %b, state = %b, counter = %d, uut.led = %b, uut.led_sel = %b",
        $time, rst, uut.state, uut.counter, uut.led, uut.led_sel);
        $dumpfile("marquee.vcd");
        $dumpvars(0, Marquee_tb);
    end
endmodule
