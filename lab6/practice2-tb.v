`timescale 1ns / 1ns

module Adjustable_Rainbow_Breathing_LED_tb;

    // 宣告測試模組的訊號
    reg clk;
    reg rst;
    reg [1:0] btn;
    wire led_r;
    wire led_g;
    wire led_b;
    wire [3:0] led_mode;

    // 實例化待測試的模組
    Adjustable_Rainbow_Breathing_LED dut (
        .clk(clk),
        .rst(rst),
        .btn(btn),
        .led_mode(led_mode),
        .led_r(led_r),
        .led_g(led_g),
        .led_b(led_b)
    );

    // 設定時脈週期
    parameter CLK_PERIOD = 8; // 對應 125MHz 時脈

    initial begin
        // 初始化訊號
        clk = 0;
        rst = 1;
        btn = 2'b00; // 初始按鈕狀態

        // 產生時脈訊號
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    initial begin
        // 施加重置訊號
        #10 rst = 0;

        // 觀察初始狀態
        $display("Time=%0t: Reset done. Speed Mode LEDs: %b", $time, led_mode);

        // 等待一段時間觀察初始呼吸效果
        #500;
        $display("Time=%0t: Observing initial breathing (0.5s mode)...", $time);
        #2000;

        // 測試增加速度按鈕 (btn[0])
        $display("Time=%0t: Pressing 'Speed Up' button (btn[0])...", $time);
        btn = 2'b01;
        #10;
        btn = 2'b00;
        $display("Time=%0t: Speed Mode LEDs: %b (should be 0100 -> 1000)", $time, led_mode);
        #2000;

        // 再次增加速度
        $display("Time=%0t: Pressing 'Speed Up' button (btn[0]) again...", $time);
        btn = 2'b01;
        #10;
        btn = 2'b00;
        $display("Time=%0t: Speed Mode LEDs: %b (should be 1000 -> 0010)", $time, led_mode);
        #2000;

        // 測試減少速度按鈕 (btn[1])
        $display("Time=%0t: Pressing 'Slow Down' button (btn[1])...", $time);
        btn = 2'b10;
        #10;
        btn = 2'b00;
        $display("Time=%0t: Speed Mode LEDs: %b (should be 0010 -> 0100)", $time, led_mode);
        #2000;

        // 再次減少速度
        $display("Time=%0t: Pressing 'Slow Down' button (btn[1]) again...", $time);
        btn = 2'b10;
        #10;
        btn = 2'b00;
        $display("Time=%0t: Speed Mode LEDs: %b (should be 0100 -> 0001)", $time, led_mode);
        #2000;

        // 測試邊界情況 (繼續增加和減少)
        $display("Time=%0t: Pressing 'Speed Up' at fastest speed...", $time);
        btn = 2'b01;
        #10;
        btn = 2'b00;
        $display("Time=%0t: Speed Mode LEDs: %b (should remain 0010)", $time, led_mode);
        #1000;

        $display("Time=%0t: Pressing 'Slow Down' at slowest speed...", $time);
        btn = 2'b10;
        #10;
        btn = 2'b00;
        $display("Time=%0t: Speed Mode LEDs: %b (should remain 0001)", $time, led_mode);
        #1000;

        // 同時按下兩個按鈕 (預期行為是沒有速度變化)
        $display("Time=%0t: Pressing both 'Speed Up' and 'Slow Down'...", $time);
        btn = 2'b11;
        #10;
        btn = 2'b00;
        $display("Time=%0t: Speed Mode LEDs: %b (should remain at current speed)", $time, led_mode);
        #1000;

        // 觀察一段時間的顏色變化和呼吸效果
        $display("Time=%0t: Observing color change and breathing across different speeds...", $time);
        #10000;

        // 結束測試
        $finish;
    end

    // 監控 RGB LED 的變化 (可以添加更詳細的監控)
    always @(posedge clk) begin
        $display("Time=%0t: LED R=%b G=%b B=%b, Speed=%b", $time, led_r, led_g, led_b, led_mode);
    end

endmodule
