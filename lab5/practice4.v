`define CLK_FREQUENCY 125000000
`define DEBOUNCE_TIME 27'd2000000 // 約 16ms @ 125MHz

module ButtonControlledMarquee (
    input clk,
    input rst,
    input [1:0] btn, // 0: Speed Up, 1: Speed Down
    output reg [3:0] led, // 假設控制 4 個 LED，最右邊是 led[0]
    output reg [3:0] speed_led // {led5_g, led4_g, led_r, led4_r}
);

    // 速度模式定義 (計數器終止值)
    localparam SPEED_2S   = `CLK_FREQUENCY * 2 - 1;
    localparam SPEED_1S   = `CLK_FREQUENCY * 1 - 1;
    localparam SPEED_05S  = `CLK_FREQUENCY / 2 - 1;
    localparam SPEED_025S = `CLK_FREQUENCY / 4 - 1;

    // 速度模式枚舉
    typedef enum logic [1:0] {
        SPEED_2S_MODE,
        SPEED_1S_MODE,
        SPEED_05S_MODE,
        SPEED_025S_MODE
    } speed_mode_t;

    reg [26:0] counter;
    reg [2:0] current_led; // 追蹤當前點亮的 LED (0 to 3)
    reg speed_mode_t current_speed;
    reg [26:0] debounce_counter;
    reg [1:0] btn_history;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_speed <= SPEED_2S_MODE;
            current_led <= 3'd0; // 最右邊的 LED
            counter <= 27'd0;
            speed_led <= 4'b0001;
            btn_history <= 2'b11; // 假設初始按鈕未按下
            debounce_counter <= 27'd0;
            led <= 4'b0001; // 初始點亮最右邊 LED
        end else begin
            // 按鈕消抖
            if (btn != btn_history) begin
                debounce_counter <= 27'd0;
            end 
            else if (debounce_counter < `DEBOUNCE_TIME - 1) begin
                debounce_counter <= debounce_counter + 1'b1;
            end
            btn_history <= btn;

            if (debounce_counter == `DEBOUNCE_TIME - 1) begin
                if (btn[0] == 1'b1 && btn_history[0] == 1'b0) begin // Speed Up
                    case (current_speed)
                        SPEED_2S_MODE   : current_speed <= SPEED_1S_MODE;
                        SPEED_1S_MODE   : current_speed <= SPEED_05S_MODE;
                        SPEED_05S_MODE  : current_speed <= SPEED_025S_MODE;
                        default         : current_speed <= SPEED_025S_MODE;
                    endcase
                end 
                else if (btn[1] == 1'b1 && btn_history[1] == 1'b0) begin // Speed Down
                    case (current_speed)
                        SPEED_025S_MODE : current_speed <= SPEED_05S_MODE;
                        SPEED_05S_MODE  : current_speed <= SPEED_1S_MODE;
                        SPEED_1S_MODE   : current_speed <= SPEED_2S_MODE;
                        default         : current_speed <= SPEED_2S_MODE;
                    endcase
                end
            end

            // 更新速度指示 LED
            case (current_speed)
                SPEED_2S_MODE   : speed_led <= 4'b0001;
                SPEED_1S_MODE   : speed_led <= 4'b0010;
                SPEED_05S_MODE  : speed_led <= 4'b0100;
                SPEED_025S_MODE : speed_led <= 4'b1000;
                default         : speed_led <= 4'b0001;
            endcase

            // 更新 LED 跑馬燈
            case (current_speed)
                SPEED_2S_MODE:
                    if (counter == SPEED_2S) begin
                        counter <= 27'd0;
                        current_led <= (current_led + 1) % 4;
                    end
                    else begin
                        counter <= counter + 1'b1;
                    end
                SPEED_1S_MODE:
                    if (counter == SPEED_1S) begin
                        counter <= 27'd0;
                        current_led <= (current_led + 1) % 4;
                    end 
                    else begin
                        counter <= counter + 1'b1;
                    end
                SPEED_05S_MODE:
                    if (counter == SPEED_05S) begin
                        counter <= 27'd0;
                        current_led <= (current_led + 1) % 4;
                    end 
                    else begin
                        counter <= counter + 1'b1;
                    end
                SPEED_025S_MODE:
                    if (counter == SPEED_025S) begin
                        counter <= 27'd0;
                        current_led <= (current_led + 1) % 4;
                    end 
                    else begin
                        counter <= counter + 1'b1;
                    end
                default: counter <= counter + 1'b1;
            endcase

            // 點亮對應的 LED
            led <= (1 << current_led);
        end
    end

endmodule
