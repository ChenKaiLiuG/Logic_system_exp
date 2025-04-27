`define CLK_FREQUENCY 125000000
`define DEBOUNCE_TIME 27'd2000000 // 16ms @ 125MHz
// * 1/1000000

module ButtonControlledMarquee (
    input clk,
    input rst,
    input btn0, // Speed Up 
    input btn1, // Speed Down 
    output reg [3:0] led, 
    output reg [3:0] speed_led // {led5_g, led4_g, led_r, led4_r}
);

    // 速度模式定義 (計數器終止值)
    localparam SPEED_2S   = `CLK_FREQUENCY * 2 - 1;
    localparam SPEED_1S   = `CLK_FREQUENCY * 1 - 1;
    localparam SPEED_05S  = `CLK_FREQUENCY / 2 - 1;
    localparam SPEED_025S = `CLK_FREQUENCY / 4 - 1;

    // 速度模式參數
    parameter SPEED_2S_MODE   = 2'b00;
    parameter SPEED_1S_MODE   = 2'b01;
    parameter SPEED_05S_MODE  = 2'b10;
    parameter SPEED_025S_MODE = 2'b11;

    reg [26:0] counter;
    reg [2:0] current_led; 
    reg [1:0] current_speed;
    reg [26:0] debounce_counter_up;
    reg [1:0] btn_history_up;
    reg [26:0] debounce_counter_down;
    reg [1:0] btn_history_down;
    reg update_led; 

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_speed <= SPEED_2S_MODE;
            current_led <= 3'd0; 
            counter <= 27'd0;
            speed_led <= 4'b0001;
            btn_history_up <= 1'b0;
            debounce_counter_up <= 27'd0;
            btn_history_down <= 1'b0;
            debounce_counter_down <= 27'd0;
            led <= 4'b0001;
            update_led <= 1'b0;
        end else begin
            if (btn0 != btn_history_up) debounce_counter_up <= 27'd0;
            else if (debounce_counter_up < `DEBOUNCE_TIME - 1) debounce_counter_up <= debounce_counter_up + 1'b1;
            btn_history_up <= btn0;
            if (debounce_counter_up == `DEBOUNCE_TIME - 1 && btn0 == 1'b1 && btn_history_up == 1'b0) begin
                case (current_speed)
                    SPEED_2S_MODE   : current_speed <= SPEED_1S_MODE;
                    SPEED_1S_MODE   : current_speed <= SPEED_05S_MODE;
                    SPEED_05S_MODE  : current_speed <= SPEED_025S_MODE;
                    default         : current_speed <= SPEED_025S_MODE;
                endcase
                counter <= 27'd0; 
                update_led <= 1'b1; 
            end

            if (btn1 != btn_history_down) debounce_counter_down <= 27'd0;
            else if (debounce_counter_down < `DEBOUNCE_TIME - 1) debounce_counter_down <= debounce_counter_down + 1'b1;
            btn_history_down <= btn1;
            if (debounce_counter_down == `DEBOUNCE_TIME - 1 && btn1 == 1'b1 && btn_history_down == 1'b0) begin
                case (current_speed)
                    SPEED_025S_MODE : current_speed <= SPEED_05S_MODE;
                    SPEED_05S_MODE  : current_speed <= SPEED_1S_MODE;
                    SPEED_1S_MODE   : current_speed <= SPEED_2S_MODE;
                    default         : current_speed <= SPEED_2S_MODE;
                endcase
                counter <= 27'd0; 
                update_led <= 1'b1; 
            end

            case (current_speed)
                SPEED_2S_MODE   : speed_led <= 4'b0001;
                SPEED_1S_MODE   : speed_led <= 4'b0010;
                SPEED_05S_MODE  : speed_led <= 4'b0100;
                SPEED_025S_MODE : speed_led <= 4'b1000;
                default         : speed_led <= 4'b0001;
            endcase

            case (current_speed)
                SPEED_2S_MODE:
                    if (update_led || counter == SPEED_2S) begin
                        counter <= 27'd0;
                        current_led <= (current_led + 1) % 4;
                        update_led <= 1'b0; 
                    end else begin
                        counter <= counter + 1'b1;
                    end
                SPEED_1S_MODE:
                    if (update_led || counter == SPEED_1S) begin
                        counter <= 27'd0;
                        current_led <= (current_led + 1) % 4;
                        update_led <= 1'b0; 
                    end else begin
                        counter <= counter + 1'b1;
                    end
                SPEED_05S_MODE:
                    if (update_led || counter == SPEED_05S) begin
                        counter <= 27'd0;
                        current_led <= (current_led + 1) % 4;
                        update_led <= 1'b0; 
                    end else begin
                        counter <= counter + 1'b1;
                    end
                SPEED_025S_MODE:
                    if (update_led || counter == SPEED_025S) begin
                        counter <= 27'd0;
                        current_led <= (current_led + 1) % 4;
                        update_led <= 1'b0; 
                    end else begin
                        counter <= counter + 1'b1;
                    end
                default: counter <= counter + 1'b1;
            endcase

            led <= (1 << current_led);
        end
    end

endmodule
