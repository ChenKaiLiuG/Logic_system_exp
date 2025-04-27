`timescale 1ns/1ns

module Marquee_tb;

    // 宣告測試模組的訊號
    reg clk;
    reg rst;
    wire [3:0] led;

    // 實例化被測試的 Marquee 模組
    Marquee uut (
        .clk(clk),
        .rst(rst),
        .led(led)
    );

    // 定義時脈週期
    localparam CLK_PERIOD = 8; // 對應 125MHz 時脈，週期為 1/125e6 秒 = 8 ns

    // 產生時脈訊號
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // 產生重置訊號
    initial begin
        rst = 1;
        #10; // 在開始後的 20 ns (幾個時脈週期) 將重置訊號拉低
        rst = 0;
        #100000; // 模擬一段時間 (200 ms) 以觀察跑馬燈效果
        $finish; // 結束模擬
    end

    // 監測 LED 輸出的變化
    initial begin
        $monitor("Time = %t, rst = %b, state = %b, counter = %d, uut.led = %b, uut.led_sel = %b",
        $time, rst, uut.state, uut.counter, uut.led, uut.led_sel);
        $dumpfile("marquee.vcd");
        $dumpvars(0, Marquee_tb);
    end
endmodule
