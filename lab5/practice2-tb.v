`timescale 1ns/1ns

module Marquee_tb;

    reg clk;
    reg rst;
    wire [3:0] led;
    wire led4_g;
    wire led5_g;

    // 實例化待測試的 Marquee 模組
    Marquee uut (
        .clk(clk),
        .rst(rst),
        .led(led),
        .led4_g(led4_g),
        .led5_g(led5_g)
    );

    // 時脈產生
    parameter CLK_PERIOD = 8 ns; // 對應 125MHz 時脈 (1 / 125e6 = 8ns)
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    // 重置訊號產生
    initial begin
        rst = 1;
        #10; // 保持重置 10 ns
        rst = 0;
        #1000000; // 模擬一段時間 (1 ms)
        $finish;
    end

    // 監測輸出訊號
    initial begin
        $monitor("Time=%t, rst=%b, led=%b, led4_g=%b, led5_g=%b", $time, rst, led, led4_g, led5_g);
    end

endmodule
