`timescale 1ns/1ns

module tb_Rainbow_Breathing_LED_V2();

reg clk = 0;
reg rst = 0;
reg [1:0] btn = 2'b00;
wire [3:0] led_mode;
wire led_r, led_g, led_b;

// DUT
Rainbow_Breathing_LED_V2 dut (
    .clk(clk),
    .rst(rst),
    .btn(btn),
    .led_mode(led_mode),
    .led_r(led_r),
    .led_g(led_g),
    .led_b(led_b)
);

// 100MHz clock (10ns period)
always #5 clk = ~clk;

// 測試流程
initial begin
    $display("Start Simulation");
    
    // Reset
    rst = 1; #10;
    rst = 0;
    $display("[%0t] Reset released", $time);

    #20000000;

    // 模擬 btn[0] 按下（加速）
    btn = 2'b01; 
    #20;
    btn = 2'b00; 
    #20000000;
    $display("[%0t] Speed Up", $time);

    // 模擬再加速
    btn = 2'b01; 
    #20;
    btn = 2'b00; 
    #20000000;
    $display("[%0t] Speed Up Again", $time);

    // 模擬再加速
    btn = 2'b01; 
    #20;
    btn = 2'b00; 
    #20000000;
    $display("[%0t] Speed Up Again", $time);

    // 模擬減速
    btn = 2'b10; 
    #20;
    btn = 2'b00; 
    #20000000;
    $display("[%0t] Slow Down", $time);

    // 測試 Reset 回復到最慢速度
    rst = 1; 
    #100;
    rst = 0;
    $display("[%0t] Reset again", $time);

    #20000000;

    $finish;
end

// 顯示目前 LED 狀態
always @(posedge clk) begin
    $display("Time: %0t | Mode: %b | LED RGB: %b%b%b", $time, led_mode, led_r, led_g, led_b);
end

endmodule
