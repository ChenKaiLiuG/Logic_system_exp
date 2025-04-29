`define CLK_FREQ 125000000 // FPGA 時脈頻率 125MHz
`define MAX_BRIGHTNESS 100
`define COLOR_CHANGE_COUNT (`CLK_FREQ / 1) // 1 秒切換顏色
`define SPEED_2S_COUNT   (`CLK_FREQ * 2 / 200)   // 2 秒週期 (除以 200 以匹配 practice1.txt 的 PWM 週期)
`define SPEED_1S_COUNT   (`CLK_FREQ * 1 / 200)   // 1 秒週期
`define SPEED_0_5S_COUNT (`CLK_FREQ * 0.5 / 200) // 0.5 秒週期
`define SPEED_0_25S_COUNT (`CLK_FREQ * 0.25 / 200) // 0.25 秒週期

module Adjustable_Rainbow_Breathing_LED (
    input clk,
    input rst,          // sw[0]
    input [1:0] btn,      // btn[0]=加速, btn[1]=減速
    output [3:0] led_mode, // 顯示目前速度模式
    output led_r, led_g, led_b
);

    // --- 內部訊號宣告 ---
    reg [1:0] speed_mode_reg;       // 儲存目前速度模式
    reg [31:0] breath_counter;      // 用於呼吸計時
    reg [7:0] brightness;
    reg [2:0] color_idx;
    reg [7:0] pwm_counter;
    reg [7:0] target_r, target_g, target_b;
    reg passed_1ms;
    reg passed_10ms;
    reg acc_999ms;
    reg [16:0] timer_8ns;
    reg [9:0] timer_1ms;

    // --- 重置時設定為 2 秒模式和紅色 LED ---
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            speed_mode_reg <= 2'b00; // 2 秒模式
            led_mode <= 4'b0001;
            color_idx <= 3'd0; // 紅色
            breath_counter <= 0;
            brightness <= 0;
            timer_8ns <= 0;
            timer_1ms <= 0;
            pwm_counter <= 0;
        end else begin
            // 速度模式控制
            if (btn[0] && !btn[1]) begin // 加速
                case (speed_mode_reg)
                    2'b00: speed_mode_reg <= 2'b01;
                    2'b01: speed_mode_reg <= 2'b10;
                    2'b10: speed_mode_reg <= 2'b11;
                    default: speed_mode_reg <= 2'b11;
                endcase
            end else if (!btn[0] && btn[1]) begin // 減速
                case (speed_mode_reg)
                    2'b11: speed_mode_reg <= 2'b10;
                    2'b10: speed_mode_reg <= 2'b01;
                    2'b01: speed_mode_reg <= 2'b00;
                    default: speed_mode_reg <= 2'b00;
                endcase
            end

            // 速度模式輸出
            case (speed_mode_reg)
                2'b00: led_mode <= 4'b0001; // 2 秒
                2'b01: led_mode <= 4'b0010; // 1 秒
                2'b10: led_mode <= 4'b0100; // 0.5 秒
                2'b11: led_mode <= 4'b1000; // 0.25 秒
                default: led_mode <= 4'b0001;
            endcase

            // 呼吸計數器
            reg [31:0] breath_period;
            case (speed_mode_reg)
                2'b00: breath_period <= SPEED_2S_COUNT;
                2'b01: breath_period <= SPEED_1S_COUNT;
                2'b10: breath_period <= SPEED_0_5S_COUNT;
                2'b11: breath_period <= SPEED_0_25S_COUNT;
                default: breath_period <= SPEED_2S_COUNT;
            endcase

            if (breath_counter < breath_period - 1) begin
                breath_counter <= breath_counter + 1;
            end else begin
                breath_counter <= 0;
            end

            // 亮度變化
            if (breath_counter < breath_period / 2) begin
                brightness <= (breath_counter * MAX_BRIGHTNESS) / (breath_period / 2);
            end else begin
                brightness <= MAX_BRIGHTNESS - ((breath_counter - breath_period / 2) * MAX_BRIGHTNESS) / (breath_period / 2);
            end
        end
    end

    // --- 1ms 計時器 ---
    always @(posedge clk or posedge rst) begin
        if (rst) timer_8ns <= 0;
        else if (passed_1ms) timer_8ns <= 0;
        else timer_8ns <= timer_8ns + 1;
    end

    assign passed_1ms = (timer_8ns == (`CLK_FREQ / 1000) - 1); // 1ms

    // --- 10ms 計時器 ---
    always @(posedge clk or posedge rst) begin
        if (rst) timer_1ms <= 0;
        else if (passed_1ms) timer_1ms <= (timer_1ms == 999) ? 0 : timer_1ms + 1;
    end

    assign passed_10ms = passed_1ms && (timer_1ms % 10 == 9);

    // --- 1 秒計時器 ---
    assign acc_999ms = (timer_1ms == 999);

    // --- 顏色輪替 ---
    always @(posedge clk or posedge rst) begin
        if (rst) color_idx <= 0;
        else if (acc_999ms) color_idx <= (color_idx == 6) ? 0 : color_idx + 1;
    end

    // --- 顏色設定 ---
    always @(*) begin
        case (color_idx)
            3'd0: begin target_r = 100; target_g = 0;   target_b = 0;   end // Red
            3'd1: begin target_r = 100; target_g = 40;  target_b = 0;   end // Orange
            3'd2: begin target_r = 100; target_g = 100; target_b = 0;   end // Yellow
            3'd3: begin target_r = 0;   target_g = 100; target_b = 0;   end // Green
            3'd4: begin target_r = 0;   target_g = 0;   target_b = 100; end // Blue
            3'd5: begin target_r = 100; target_g = 0;   target_b = 100; end // Purple
            3'd6: begin target_r = 100; target_g = 100; target_b = 100; end // White
            default: begin target_r = 0; target_g = 0; target_b = 0;   end
        endcase
    end

    // --- PWM 控制 ---
    always @(posedge clk or posedge rst) begin
        if (rst) pwm_counter <= 0;
        else if (pwm_counter == 199) pwm_counter <= 0; // 匹配 practice1.txt 的 PWM 週期
        else pwm_counter <= pwm_counter + 1;
    end

    assign led_r = (pwm_counter < (brightness * target_r) / 100);
    assign led_g = (pwm_counter < (brightness * target_g) / 100);
    assign led_b = (pwm_counter < (brightness * target_b) / 100);

endmodule
