`define CYCLE_1MS 17'd124999 //49 for testbench

module Rainbow_Breathing_LED (
    input clk, rst,
    output led_r, led_g, led_b//, led_0
);

reg [7:0] phase_counter;
reg [7:0] bright_threshold;
reg [16:0] timer_8ns;
reg [9:0] timer_1ms;
reg [2:0] color_idx; // 用來輪流切換七個顏色

//reg [9:0] counter_0;

wire passed_1ms = (timer_8ns == `CYCLE_1MS);
wire passed_10ms = passed_1ms && (timer_1ms % 10 == 9); // 每 10ms 進行一次更新
wire acc_999ms = (timer_1ms == 10'd999);
    
// 顏色對應的亮度比例（最高亮度為 100）
reg [7:0] target_r, target_g, target_b;
always @(*) begin
    case (color_idx)
        3'd0: begin target_r=100; target_g=0;   target_b=0;   end // Red
        3'd1: begin target_r=100; target_g=40;  target_b=0;   end // Orange
        3'd2: begin target_r=100; target_g=100; target_b=0;   end // Yellow
        3'd3: begin target_r=0;   target_g=100; target_b=0;   end // Green
        3'd4: begin target_r=0;   target_g=0;   target_b=100; end // Blue
        3'd5: begin target_r=100; target_g=0;   target_b=100; end // Purple
        3'd6: begin target_r=100; target_g=100; target_b=100; end // White
        default: begin target_r=0; target_g=0; target_b=0; end
    endcase
end
    
// 基本 1ms 計時器
always @(posedge clk or posedge rst) begin
    if (rst) timer_8ns <= 0;
    else if (passed_1ms) timer_8ns <= 0;
    else timer_8ns <= timer_8ns + 1;
end

// 1ms 單位的 timer
always @(posedge clk or posedge rst) begin
    if (rst) timer_1ms <= 0;
    else if (passed_1ms) timer_1ms <= acc_999ms ? 0 : timer_1ms + 1;
end

// 呼吸亮度變化：0 ~ 100 再回來
always @(posedge clk or posedge rst) begin
    if (rst) bright_threshold <= 0;
    else if (passed_10ms) begin
        if (timer_1ms <= 499) bright_threshold <= bright_threshold + 1;
        else bright_threshold <= bright_threshold - 1;
    end
end
    
// 顏色輪替：每秒切換一次顏色
always @(posedge clk or posedge rst) begin
    if (rst) color_idx <= 0;
    else if (acc_999ms) color_idx <= (color_idx == 6) ? 0 : color_idx + 1;
end

// 呼吸PWM控制
always @(posedge clk or posedge rst) begin
    if (rst) phase_counter <= 0;
    else if (phase_counter == 199) phase_counter <= 0;
    else phase_counter <= phase_counter + 1;
end

/*always @(posedge clk or posedge rst) begin
    if (rst) counter_0 <= 0;
    else counter_0 <= counter_0 + 1;
end*/

assign led_r = (phase_counter < (bright_threshold * target_r) / 100);
assign led_g = (phase_counter < (bright_threshold * target_g) / 100);
assign led_b = (phase_counter < (bright_threshold * target_b) / 100);

//assign led_0 = counter_0 == 100;
endmodule
