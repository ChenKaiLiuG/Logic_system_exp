`define CYCLE_1MS 17'd124999 // @125MHz

module Rainbow_Breathing_LED_V2 (
    input clk,
    input rst,             // sw[0]
    input [1:0] btn,       // btn[0]=加速, btn[1]=減速
    output reg [3:0] led_mode, // 顯示目前速度模式
    output led_r, led_g, led_b
);

reg [1:0] mode;  // 00:2s, 01:1s, 10:0.5s, 11:0.25s
reg [15:0] speed_ms; // 呼吸週期長度

// 記錄按鍵前一拍狀態（做邊緣觸發）
reg [1:0] btn_prev;
wire [1:0] btn_rise = btn & ~btn_prev;

// 呼吸節奏控制
reg [7:0] phase_counter;
reg [7:0] bright_threshold;
reg [16:0] timer_8ns;
reg [9:0] timer_1ms;
reg [9:0] max_time; // 根據 mode 設定最大時間 (如 999, 499, 249, 124)

reg [2:0] color_idx;

// 計算是否經過 1ms / 10ms
wire passed_1ms = (timer_8ns == `CYCLE_1MS);
wire passed_10ms = passed_1ms && (timer_1ms % 10 == 9);
wire acc_finish = (timer_1ms == max_time);

// 每個 mode 對應時間長度
always @(*) begin
    case (mode)
        2'b00: begin speed_ms = 2000; max_time = 999; led_mode = 4'b0001; end
        2'b01: begin speed_ms = 1000; max_time = 499; led_mode = 4'b0010; end
        2'b10: begin speed_ms = 500;  max_time = 249; led_mode = 4'b0100; end
        2'b11: begin speed_ms = 250;  max_time = 124; led_mode = 4'b1000; end
    endcase
end

// 非同步 Reset or 模式切換
always @(posedge clk or posedge rst) begin
    if (rst)
        mode <= 2'b00; // 回復到 2s 模式
    else begin
        // 邊緣偵測按鍵，按一次變一次模式
        if (btn_rise[0] && mode != 2'b11) mode <= mode + 1;
        else if (btn_rise[1] && mode != 2'b00) mode <= mode - 1;
    end
end

// 更新 btn_prev
always @(posedge clk) btn_prev <= btn;

// PWM 計時
always @(posedge clk or posedge rst) begin
    if (rst) timer_8ns <= 0;
    else if (passed_1ms) timer_8ns <= 0;
    else timer_8ns <= timer_8ns + 1;
end

// 1ms 計時器
always @(posedge clk or posedge rst) begin
    if (rst) timer_1ms <= 0;
    else if (passed_1ms) timer_1ms <= acc_finish ? 0 : timer_1ms + 1;
end

// 亮度變化：漸亮 + 漸暗
always @(posedge clk or posedge rst) begin
    if (rst) bright_threshold <= 0;
    else if (passed_10ms) begin
        if (timer_1ms <= max_time) bright_threshold <= bright_threshold + 1;
        else bright_threshold <= bright_threshold - 1;
    end
end

// 顏色切換
always @(posedge clk or posedge rst) begin
    if (rst) color_idx <= 0;
    else if (acc_finish) color_idx <= (color_idx == 6) ? 0 : color_idx + 1;
end

// PWM 模組
always @(posedge clk or posedge rst) begin
    if (rst) phase_counter <= 0;
    else if (phase_counter == 199) phase_counter <= 0;
    else phase_counter <= phase_counter + 1;
end

// 顏色目標值設定
reg [7:0] target_r, target_g, target_b;
always @(*) begin
    case (color_idx)
        3'd0: begin target_r=100; target_g=0;   target_b=0;   end
        3'd1: begin target_r=100; target_g=40;  target_b=0;   end
        3'd2: begin target_r=100; target_g=100; target_b=0;   end
        3'd3: begin target_r=0;   target_g=100; target_b=0;   end
        3'd4: begin target_r=0;   target_g=0;   target_b=100; end
        3'd5: begin target_r=100; target_g=0;   target_b=100; end
        3'd6: begin target_r=100; target_g=100; target_b=100; end
        default: begin target_r=0; target_g=0; target_b=0; end
    endcase
end

assign led_r = (phase_counter < (bright_threshold * target_r) / 100);
assign led_g = (phase_counter < (bright_threshold * target_g) / 100);
assign led_b = (phase_counter < (bright_threshold * target_b) / 100);

endmodule
