`define CYCLE_05S 27'd49
`define CYCLE_025S 27'd99

module Marquee (
    input clk,
    input rst,
    output reg [3:0] led,
    output reg led4_g,
    output reg led5_g
);

    reg [28:0] counter;
    reg [3:0] current_state;
    reg round_type;

    // 第一輪狀態
    localparam R1_S0 = 4'b0000; // led0
    localparam R1_S1 = 4'b0001; // led1
    localparam R1_S2 = 4'b0010; // led2
    localparam R1_S3 = 4'b0011; // led3
    localparam R1_S4 = 4'b0100; // led2
    localparam R1_S5 = 4'b0101; // led1
    localparam R1_END = 4'b0110;

    // 第二輪狀態
    localparam R2_S0 = 4'b1000; // led0
    localparam R2_S1 = 4'b1001; // led1
    localparam R2_S2 = 4'b1010; // led2
    localparam R2_S3 = 4'b1011; // led3
    localparam R2_S4 = 4'b1100; // led2
    localparam R2_S5 = 4'b1101; // led1
    localparam R2_END = 4'b1110;

    always @(*) begin
        if (round_type == 0) begin // 第一輪
            led4_g = 1'b1;
            led5_g = 1'b0;
            case (current_state)
                R1_S0: led = 4'b0001; // led0
                R1_S1: led = 4'b0010; // led1
                R1_S2: led = 4'b0100; // led2
                R1_S3: led = 4'b1000; // led3
                R1_S4: led = 4'b0100; // led2
                R1_S5: led = 4'b0010; // led1
                default: led = 4'b0000;
            endcase
        end else begin // 第二輪
            led4_g = 1'b0;
            led5_g = 1'b1;
            case (current_state)
                R2_S0: led = 4'b0001; // led0
                R2_S1: led = 4'b0010; // led1
                R2_S2: led = 4'b0100; // led2
                R2_S3: led = 4'b1000; // led3
                R2_S4: led = 4'b0100; // led2
                R2_S5: led = 4'b0010; // led1
                default: led = 4'b0000;
            endcase
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 29'd0;
            current_state <= R1_S0;
            round_type <= 0;
        end else begin
            if (round_type == 0) begin // 第一輪
                if (counter == `CYCLE_05S - 1) begin
                    counter <= 29'd0;
                    case (current_state)
                        R1_S0: current_state <= R1_S1;
                        R1_S1: current_state <= R1_S2;
                        R1_S2: current_state <= R1_S3;
                        R1_S3: current_state <= R1_S4;
                        R1_S4: current_state <= R1_S5;
                        R1_S5: current_state <= R1_END;
                        R1_END: begin
                            current_state <= R2_S0;
                            round_type <= 1;
                        end
                        default: current_state <= R1_S0;
                    endcase
                end else begin
                    counter <= counter + 1'b1;
                end
            end else begin // 第二輪
                if (counter == `CYCLE_025S - 1) begin
                    counter <= 29'd0;
                    case (current_state)
                        R2_S0: current_state <= R2_S1;
                        R2_S1: current_state <= R2_S2;
                        R2_S2: current_state <= R2_S3;
                        R2_S3: current_state <= R2_S4;
                        R2_S4: current_state <= R2_S5;
                        R2_S5: current_state <= R2_END;
                        R2_END: begin
                            current_state <= R1_S0;
                            round_type <= 0;
                        end
                        default: current_state <= R2_S0;
                    endcase
                end else begin
                    counter <= counter + 1'b1;
                end
            end
        end
    end

endmodule
