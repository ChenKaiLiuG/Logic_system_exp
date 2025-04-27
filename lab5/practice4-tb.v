`timescale 1ns/1ns

module ButtonControlledMarquee_tb;

    reg clk;
    reg rst;
    reg [1:0] btn;
    wire [3:0] led;
    wire [3:0] speed_led;

    // 實例化待測試的 ButtonControlledMarquee 模組
    ButtonControlledMarquee uut (
        .clk(clk),
        .rst(rst),
        .btn(btn),
        .led(led),
        .speed_led(speed_led)
    );

    // 時脈產生
    parameter CLK_PERIOD = 8 ns; // 對應 125MHz 時脈
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    // 重置訊號產生
    initial begin
        rst = 1;
        #20;
        rst = 0;
        #20;
    end

    // 按鈕輸入產生
    initial begin
        btn = 2'b11; // 初始未按下

        #5000000; // 模擬一段時間

        // 按下 Speed Up 按鈕 (btn[0])
        btn = 2'b01;
        #50000;
        btn = 2'b11;
        #1000000;

        // 按下 Speed Down 按鈕 (btn[1])
        btn = 2'b10;
        #50000;
        btn = 2'b11;
        #1000000;

        // 再次按下 Speed Up
        btn = 2'b01;
        #50000;
        btn = 2'b11;
        #2000000;

        $finish;
    end

    // 監測輸出訊號
    initial begin
        $monitor("Time=%t, rst=%b, btn=%b, led=%b, speed_led=%b", $time, rst, btn, led, speed_led);
    end

endmodule
