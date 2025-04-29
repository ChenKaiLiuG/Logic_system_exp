`timescale 1ns / 1ps

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
        btn = 2'b00;

        // 產生時脈訊號
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    task press_button;
        input [1:0] button_mask;
        begin
            btn = button_mask;
            #10;
            btn = 2'b00;
            #20; // 給一些時間讓狀態更新
            $display("Time=%0t: Buttons=%b, Speed Mode=%b", $time, button_mask, led_mode);
        end
    endtask

    initial begin
        // 施加重置訊號
        #10 rst = 0;
        $display("Time=%0t: Reset done. Speed Mode=%b (should be 0100)", $time, led_mode);
        #100; // 觀察初始狀態

        // 測試速度增加和減少
        $display("--- Testing Speed Change ---");
        press_button(2'b01); // 加速 (0100 -> 1000)
        press_button(2'b01); // 加速 (1000 -> 0010)
        press_button(2'b10); // 減速 (0010 -> 0100)
        press_button(2'b10); // 減速 (0100 -> 0001)

        // 測試邊界情況
        $display("--- Testing Boundaries ---");
        press_button(2'b01); // 加速 (0001 -> 0010 - 假設循環)
        press_button(2'b10); // 減速 (0010 -> 0001)

        // 測試同時按下
        $display("--- Testing Simultaneous Press ---");
        press_button(2'b11); // 同時按下 (預期無變化)

        // 觀察一段時間的呼吸和顏色變化
        $display("--- Observing Breathing and Color Change ---");
        #5000;

        $finish;
    end

    // 監控 RGB LED 和速度 (可選)
    always @(posedge clk) begin
        $display("Time=%0t: LED R=%b G=%b B=%b, Speed=%b", $time, led_r, led_g, led_b, led_mode);
    end

endmodule
