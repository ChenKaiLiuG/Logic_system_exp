`define CYCLE_025S 26'd31250000 // 99 to testbench

module Marquee (
    input clk,
    input rst,
    output [3:0] led
);

    reg [25:0] counter;
    reg [2:0] state;
    reg [3:0] led_sel;

    localparam S0 = 3'b000; // LED 1
    localparam S1 = 3'b001; // LED 2
    localparam S2 = 3'b010; // LED 3
    localparam S3 = 3'b011; // LED 4
    localparam S4 = 3'b100; // LED 3 (回程)
    localparam S5 = 3'b101; // LED 2 (回程)
    localparam S6 = 3'b110; // LED 1 (回程)

    assign led = led_sel;

    localparam DELAY = `CYCLE_025S;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 26'd0;
            state <= S0;
            led_sel <= 4'b0001;
        end else begin
            if (counter == DELAY) begin
                counter <= 26'd0;
                case (state)
                    S0: begin
                        state <= S1;
                        led_sel <= 4'b0010;
                    end
                    S1: begin
                        state <= S2;
                        led_sel <= 4'b0100;
                    end
                    S2: begin
                        state <= S3;
                        led_sel <= 4'b1000;
                    end
                    S3: begin
                        state <= S4;
                        led_sel <= 4'b0100;
                    end
                    S4: begin
                        state <= S5;
                        led_sel <= 4'b0010;
                    end
                    S5: begin
                        state <= S6;
                        led_sel <= 4'b0001;
                    end
                    S6: begin
                        state <= S1;
                        led_sel <= 4'b0010;
                    end
                    default: state <= S0;
                endcase
            end else begin
                counter <= counter + 1'b1;
            end
        end
    end

endmodule
