module Adjustable_Rainbow_Breathing_LED (
    input clk,
    input rst,
    input [1:0] btn,       // btn[0]=加速, btn[1]=減速
    output [3:0] led_mode, // 顯示目前速度模式
    output led_r, led_g, led_b
);

// System Clock Frequency dependent parameter (Assuming 125MHz for 8ns period)
// Adjust this value if your clock frequency is different.
parameter CLK_FREQ = 125_000_000; // Example: 125 MHz
parameter CYCLE_1MS_COUNT = CLK_FREQ / 1000; // Counts for 1ms

// Button Debouncing Parameters
parameter DEBOUNCE_TIME_MS = 20; // Debounce time in ms
parameter DEBOUNCE_CLOCKS = CYCLE_1MS_COUNT * DEBOUNCE_TIME_MS;

// Speed Modes (Breathing cycle duration in ms)
parameter SPEED_MODE_0_INTERVAL_MS = 10; // ~2s cycle (100 steps up * 10ms + 100 steps down * 10ms)
parameter SPEED_MODE_1_INTERVAL_MS = 5;  // ~1s cycle (100 * 5ms + 100 * 5ms)
parameter SPEED_MODE_2_INTERVAL_MS = 2;  // ~0.4s cycle (100 * 2ms + 100 * 2ms) - Approx 0.5s
parameter SPEED_MODE_3_INTERVAL_MS = 1;  // ~0.2s cycle (100 * 1ms + 100 * 1ms) - Approx 0.25s

// Timers and Counters
reg [$clog2(CYCLE_1MS_COUNT)-1:0] timer_clk_count; // Counts clock cycles up to 1ms
reg [9:0] timer_1ms; // Counts ms up to 1023ms
reg [7:0] phase_counter; // PWM phase counter (0-199 for smoother PWM)
reg [6:0] bright_threshold; // Brightness level (0-100)
reg breathing_up; // Direction of brightness change
reg [2:0] color_idx; // Current color index (0-6)

// Speed Control State
reg [1:0] speed_mode; // 0: 2s, 1: 1s, 2: 0.5s(approx), 3: 0.25s(approx)
reg [SPEED_MODE_0_INTERVAL_MS-1:0] breath_interval_timer_ms; // Timer for breath update interval

// Button Debouncing Registers
reg [$clog2(DEBOUNCE_CLOCKS)-1:0] btn0_debounce_cnt, btn1_debounce_cnt;
reg btn0_stable, btn1_stable;
reg btn0_prev, btn1_prev;
reg btn0_pressed, btn1_pressed; // Single-cycle pulse for button press

// Timing Signals
wire passed_1ms = (timer_clk_count == CYCLE_1MS_COUNT - 1);
wire acc_999ms = passed_1ms && (timer_1ms == 10'd999); // Signal for 1 second passing

// Breathing Update Tick
wire breath_update_tick;

// Target Color Values (based on original code)
reg [6:0] target_r, target_g, target_b; // Use 7 bits for 0-100 range

//--------------------------------------------------------------------------
// Button Debouncing Logic
//--------------------------------------------------------------------------
always @(posedge clk or posedge rst) begin
    if (rst) begin
        btn0_debounce_cnt <= 0;
        btn1_debounce_cnt <= 0;
        btn0_stable <= 1'b0; // Initialize stable state (assuming buttons released at reset)
        btn1_stable <= 1'b0;
        btn0_prev <= 1'b0;
        btn1_prev <= 1'b0;
        btn0_pressed <= 1'b0;
        btn1_pressed <= 1'b0;
    end else begin
        // Debouncer for btn[0] (Speed Up)
        if (btn[0] != btn0_stable) begin
            btn0_debounce_cnt <= btn0_debounce_cnt + 1;
            if (btn0_debounce_cnt == DEBOUNCE_CLOCKS - 1) begin
                btn0_stable <= btn[0];
                btn0_debounce_cnt <= 0; // Reset counter
            end
        end else begin
            btn0_debounce_cnt <= 0; // Reset if stable or input changes back
        end

        // Debouncer for btn[1] (Slow Down)
        if (btn[1] != btn1_stable) begin
            btn1_debounce_cnt <= btn1_debounce_cnt + 1;
            if (btn1_debounce_cnt == DEBOUNCE_CLOCKS - 1) begin
                btn1_stable <= btn[1];
                btn1_debounce_cnt <= 0; // Reset counter
            end
        end else begin
            btn1_debounce_cnt <= 0; // Reset if stable or input changes back
        end

        // Edge Detection (Generate single cycle pulse on press: 0 -> 1 transition)
        btn0_prev <= btn0_stable;
        btn1_prev <= btn1_stable;
        btn0_pressed <= btn0_stable & ~btn0_prev; // Pressed edge
        btn1_pressed <= btn1_stable & ~btn1_prev; // Pressed edge
    end
end

//--------------------------------------------------------------------------
// Speed Mode Control
//--------------------------------------------------------------------------
always @(posedge clk or posedge rst) begin
    if (rst) begin
        speed_mode <= 2'd1; // Default to 1s cycle mode (matches original code's behavior)
    end else begin
        if (btn0_pressed) begin // Speed Up Button
            if (speed_mode == 2'd3) begin
                speed_mode <= 2'd3; // Already fastest
            end else begin
                speed_mode <= speed_mode + 1;
            end
        end else if (btn1_pressed) begin // Slow Down Button
             if (speed_mode == 2'd0) begin
                speed_mode <= 2'd0; // Already slowest
            end else begin
                speed_mode <= speed_mode - 1;
            end
        end
    end
end

//--------------------------------------------------------------------------
// Timers
//--------------------------------------------------------------------------
// Base timer for 1ms tick
always @(posedge clk or posedge rst) begin
    if (rst) begin
        timer_clk_count <= 0;
    end else if (passed_1ms) begin
        timer_clk_count <= 0;
    end else begin
        timer_clk_count <= timer_clk_count + 1;
    end
end

// 1ms counter (up to 1000ms for color change timing)
always @(posedge clk or posedge rst) begin
    if (rst) begin
        timer_1ms <= 0;
    end else if (passed_1ms) begin
        timer_1ms <= acc_999ms ? 0 : timer_1ms + 1;
    end
end

// Timer for variable breathing update interval
always @(posedge clk or posedge rst) begin
     if (rst) begin
         breath_interval_timer_ms <= 0;
     end else if (passed_1ms) begin
         if (breath_update_tick) begin // Reset when interval reached
             breath_interval_timer_ms <= 0;
         end else begin
             breath_interval_timer_ms <= breath_interval_timer_ms + 1;
         end
     end
 end

// Determine breath update tick based on speed mode
assign breath_update_tick = passed_1ms &&
    ( (speed_mode == 2'd0 && breath_interval_timer_ms == SPEED_MODE_0_INTERVAL_MS - 1) ||
      (speed_mode == 2'd1 && breath_interval_timer_ms == SPEED_MODE_1_INTERVAL_MS - 1) ||
      (speed_mode == 2'd2 && breath_interval_timer_ms == SPEED_MODE_2_INTERVAL_MS - 1) ||
      (speed_mode == 2'd3 && breath_interval_timer_ms == SPEED_MODE_3_INTERVAL_MS - 1) );


//--------------------------------------------------------------------------
// Color Selection Logic
//--------------------------------------------------------------------------
always @(*) begin
    case (color_idx)
        3'd0: begin target_r=100; target_g=0;   target_b=0;   end // Red [cite: 5]
        3'd1: begin target_r=100; target_g=40;  target_b=0;   end // Orange [cite: 6]
        3'd2: begin target_r=100; target_g=100; target_b=0;   end // Yellow [cite: 7]
        3'd3: begin target_r=0;   target_g=100; target_b=0;   end // Green [cite: 8]
        3'd4: begin target_r=0;   target_g=0;   target_b=100; end // Blue [cite: 9]
        3'd5: begin target_r=40;  target_g=0;   target_b=100; end // Purple/Indigo (Adjusted from original)
        3'd6: begin target_r=80;  target_g=0;   target_b=80;  end // Violet/Pink (Adjusted from original White)
        default: begin target_r=0; target_g=0; target_b=0;    end
    endcase
end

// Color Rotation (every 1 second)
always @(posedge clk or posedge rst) begin
    if (rst) begin
        color_idx <= 0;
    end else if (acc_999ms) begin // Use 1-second tick [cite: 20]
        color_idx <= (color_idx == 6) ? 0 : color_idx + 1;
    end
end

//--------------------------------------------------------------------------
// Breathing Brightness Control
//--------------------------------------------------------------------------
always @(posedge clk or posedge rst) begin
    if (rst) begin
        bright_threshold <= 0;
        breathing_up <= 1'b1; // Start by breathing in
    end else if (breath_update_tick) begin // Update based on selected speed interval
        if (breathing_up) begin
            if (bright_threshold == 100) begin
                breathing_up <= 1'b0; // Change direction to down
                bright_threshold <= bright_threshold - 1; // Start decreasing
            end else begin
                bright_threshold <= bright_threshold + 1; // Increase brightness
            end
        end else begin // breathing down
             if (bright_threshold == 0) begin
                breathing_up <= 1'b1; // Change direction to up
                bright_threshold <= bright_threshold + 1; // Start increasing
            end else begin
                bright_threshold <= bright_threshold - 1; // Decrease brightness
            end
        end
    end
end

//--------------------------------------------------------------------------
// PWM Generation
//--------------------------------------------------------------------------
// PWM Phase Counter (0-199) - Adjust max value for PWM resolution vs frequency trade-off
always @(posedge clk or posedge rst) begin
    if (rst) begin
        phase_counter <= 0;
    end else begin
        // Adjust 199 based on desired PWM resolution/frequency
        // Higher value = finer brightness control, lower PWM frequency
        // Lower value = coarser brightness control, higher PWM frequency
        phase_counter <= (phase_counter == 199) ? 0 : phase_counter + 1;
    end
end

// PWM Output Assignment [cite: 24, 25]
// Multiply target color by brightness threshold, scale to PWM counter range
assign led_r = (phase_counter < (bright_threshold * target_r) / 100);
assign led_g = (phase_counter < (bright_threshold * target_g) / 100);
assign led_b = (phase_counter < (bright_threshold * target_b) / 100);

//--------------------------------------------------------------------------
// Mode Indicator LEDs
//--------------------------------------------------------------------------
assign led_mode[0] = (speed_mode == 2'd0); // Slowest (2s cycle)
assign led_mode[1] = (speed_mode == 2'd1); // Medium-Slow (1s cycle)
assign led_mode[2] = (speed_mode == 2'd2); // Medium-Fast (~0.5s cycle)
assign led_mode[3] = (speed_mode == 2'd3); // Fastest (~0.25s cycle)

endmodule
