`define CLK_FREQ 125000000 // FPGA 時脈頻率 125MHz
`define MAX_BRIGHTNESS 100

module Adjustable_Rainbow_Breathing_LED (
    input clk,
    input rst,          // sw[0]
    input [1:0] btn,      // btn[0]=加速, btn[1]=減速
    output reg [3:0] led_mode, // 顯示目前速度模式
    output led_r, led_g, led_b
);

    // --- 參數定義 ---
    parameter SPEED_2S_COUNT   = `CLK_FREQ * 2 / `MAX_BRIGHTNESS;   // 2 秒週期對應的計數值
    parameter SPEED_1S_COUNT   = `CLK_FREQ * 1 / `MAX_BRIGHTNESS;   // 1 秒週期
    parameter SPEED_0_5S_COUNT = `CLK_FREQ * 0.5 / `MAX_BRIGHTNESS; // 0.5 秒週期
    parameter SPEED_0_25S_COUNT = `CLK_FREQ * 0.25 / `MAX_BRIGHTNESS; // 0.25 秒週期

    // --- 內部訊號宣告 ---
    reg [1:0] speed_mode;       // 00: 2s, 01: 1s, 10: 0.5s, 11: 0.25s
    reg [31:0] breath_counter; // 用於呼吸計時 (足夠的位元寬度)
    reg [7:0] brightness;
    reg [2:0] color_idx;
    reg [7:0] pwm_counter;
    reg target_r_reg, target_g_reg, target_b_reg; // 儲存目標顏色 PWM 比較值
    reg [31:0] breath_period; // 將 breath_period 宣告為 reg

    // --- 速度模式控制 ---
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            speed_mode <= 2'b10; // 初始設定為 0.5 秒模式
            led_mode <= 4'b0100; // 輸出對應的 LED 模式
        end else if (btn[0] && !btn[1]) begin // btn[0] = 加速
            case (speed_mode)
                2'b00: begin speed_mode <= 2'b01; led_mode <= 4'b0010; end
                2'b01: begin speed_mode <= 2'b10; led_mode <= 4'b0100; end
                2'b10: begin speed_mode <= 2'b11; led_mode <= 4'b1000; end
                default: begin speed_mode <= 2'b11; led_mode <= 4'b1000; end
            endcase
        end else if (!btn[0] && btn[1]) begin // btn[1] = 減速
            case (speed_mode)
                2'b11: begin speed_mode <= 2'b10; led_mode <= 4'b0100; end
                2'b10: begin speed_mode <= 2'b01; led_mode <= 4'b0010; end
                2'b01: begin speed_mode <= 2'b00; led_mode <= 4'b0001; end
                default: begin speed_mode <= 2'b00; led_mode <= 4'b0001; end
            endcase
        end
    end

    // --- 呼吸計時器和亮度變化 ---
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            breath_counter <= 0;
            brightness <= 0;
        end else begin
            case (speed_mode)
                2'b00: breath_period = SPEED_2S_COUNT;
                2'b01: breath_period = SPEED_1S_COUNT;
                2'b10: breath_period = SPEED_0_5S_COUNT;
                2'b11: breath_period = SPEED_0_25S_COUNT;
                default: breath_period = SPEED_0_5S_COUNT;
            endcase

            if (breath_counter < breath_period - 1) begin
                breath_counter <= breath_counter + 1;
            end else begin
                breath_counter <= 0;
            end

            // 線性調整亮度 (呼吸效果)
            if (breath_counter < breath_period / 2) begin
                brightness <= (breath_counter * `MAX_BRIGHTNESS) / (breath_period / 2);
            end else begin
                brightness <= `MAX_BRIGHTNESS - ((breath_counter - breath_period / 2) * `MAX_BRIGHTNESS) / (breath_period / 2);
            end
        end
    end

    // --- 顏色輪替 (約每秒切換一次) ---
    reg [31:0] color_timer;
    parameter COLOR_CHANGE_COUNT = `CLK_FREQ / 1; // 1 秒切換一次

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            color_timer <= 0;
            color_idx <= 0;
        end else if (color_timer < COLOR_CHANGE_COUNT - 1) begin
            color_timer <= color_timer + 1;
        end else begin
            color_timer <= 0;
            color_idx <= (color_idx == 6) ? 0 : color_idx + 1;
        end
    end

    // --- 目標顏色設定 ---
    reg [7:0] target_r_val, target_g_val, target_b_val;
    always @(color_idx) begin
        case (color_idx)
            3'd0: begin target_r_val = `MAX_BRIGHTNESS; target_g_val = 0;             target_b_val = 0;             end // Red
            3'd1: begin target_r_val = `MAX_BRIGHTNESS; target_g_val = 40;            target_b_val = 0;             end // Orange
            3'd2: begin target_r_val = `MAX_BRIGHTNESS; target_g_val = `MAX_BRIGHTNESS; target_b_val = 0;             end // Yellow
            3'd3: begin target_r_val = 0;             target_g_val = `MAX_BRIGHTNESS; target_b_val = 0;             end // Green
            3'd4: begin target_r_val = 0;             target_g_val = 0;             target_b_val = `MAX_BRIGHTNESS; end // Blue
            3'd5: begin target_r_val = `MAX_BRIGHTNESS; target_g_val = 0;             target_b_val = `MAX_BRIGHTNESS; end // Purple
            3'd6: begin target_r_val = `MAX_BRIGHTNESS; target_g_val = `MAX_BRIGHTNESS; target_b_val = `MAX_BRIGHTNESS; end // White
            default: begin target_r_val = 0;             target_g_val = 0;             target_b_val = 0;             end
        endcase
    end

    // --- PWM 控制 ---
    always @(posedge clk or posedge rst) begin
        if (rst) pwm_counter <= 0;
        else if (pwm_counter == `MAX_BRIGHTNESS - 1) pwm_counter <= 0;
        else pwm_counter <= pwm_counter + 1;
    end

    assign led_r = (pwm_counter < (brightness * target_r_val) / `MAX_BRIGHTNESS);
    assign led_g = (pwm_counter < (brightness * target_g_val) / `MAX_BRIGHTNESS);
    assign led_b = (pwm_counter < (brightness * target_b_val) / `MAX_BRIGHTNESS);

endmodule
