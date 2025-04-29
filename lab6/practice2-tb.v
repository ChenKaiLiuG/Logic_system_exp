`timescale 1ns / 1ns

module Adjustable_Rainbow_Breathing_LED_tb;

    // 宣告測試模組的訊號
    reg clk;
    reg rst;
    reg btn_inc;
    reg btn_dec;
    wire led_r;
    wire led_g;
    wire led_b;
    wire [3:0] led_speed;

    // 實例化待測試的模組
    Adjustable_Rainbow_Breathing_LED dut (
        .clk(clk),
        .rst(rst),
        .btn_inc(btn_inc),
        .btn_dec(btn_dec),
        .led_r(led_r),
        .led_g(led_g),
        .led_b(led_b),
        .led_speed(led_speed)
    );

    // 設定時脈週期
    parameter CLK_PERIOD = 8 ns; // 對應 125MHz 時脈

    initial begin
        // 初始化訊號
        clk = 0;
        rst = 1;
        btn_inc = 0;
        btn_dec = 0;

        // 產生時脈訊號
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    initial begin
        // 施加重置訊號
        #10 rst = 0;

        // 觀察初始狀態
        $display("Time=%0t: Reset done. Speed Mode LEDs: %b", $time, led_speed);

        // 等待一段時間觀察初始呼吸效果
        #5000;
        $display("Time=%0t: Observing initial breathing (0.5s mode)...", $time);
        #20000;

        // 測試增加速度按鈕
        $display("Time=%0t: Pressing 'Speed Up' button...", $time);
        btn_inc = 1;
        #10;
        btn_inc = 0;
        $display("Time=%0t: Speed Mode LEDs: %b (should be 0100 -> 1000)", $time, led_speed);
        #20000;

        // 再次增加速度
        $display("Time=%0t: Pressing 'Speed Up' button again...", $time);
        btn_inc = 1;
        #10;
        btn_inc = 0;
        $display("Time=%0t: Speed Mode LEDs: %b (should be 1000 -> 0010)", $time, led_speed);
        #20000;

        // 測試減少速度按鈕
        $display("Time=%0t: Pressing 'Slow Down' button...", $time);
        btn_dec = 1;
        #10;
        btn_dec = 0;
        $display("Time=%0t: Speed Mode LEDs: %b (should be 0010 -> 0100)", $time, led_speed);
        #20000;

        // 再次減少速度
        $display("Time=%0t: Pressing 'Slow Down' button again...", $time);
        btn_dec = 1;
        #10;
        btn_dec = 0;
        $display("Time=%0t: Speed Mode LEDs: %b (should be 0100 -> 0001)", $time, led_speed);
        #20000;

        // 測試邊界情況 (繼續增加和減少)
        $display("Time=%0t: Pressing 'Speed Up' at fastest speed...", $time);
        btn_inc = 1;
        #10;
        btn_inc = 0;
        $display("Time=%0t: Speed Mode LEDs: %b (should remain 0010)", $time, led_speed);
        #10000;

        $display("Time=%0t: Pressing 'Slow Down' at slowest speed...", $time);
        btn_dec = 1;
        #10;
        btn_dec = 0;
        $display("Time=%0t: Speed Mode LEDs: %b (should remain 0001)", $time, led_speed);
        #10000;



        // 結束測試
        $finish;
    end

    // 監控 RGB LED 的變化 (可以添加更詳細的監控)
    always @(posedge clk) begin
        $display("Time=%0t: LED R=%b G=%b B=%b, Speed=%b", $time, led_r, led_g, led_b, led_speed);
    end

endmodule
