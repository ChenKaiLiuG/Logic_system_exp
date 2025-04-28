`define CYCLE_05S 27'd62500000 // 99 to testbench
`define CYCLE_025S 27'd31250000 // 49 to testbench

module Marquee (
    input clk,
    input rst,
    output reg [3:0] led,
    output reg led4_g,
    output reg led5_g
);

    reg [28:0] counter;
    reg [4:0] current_state; 
    reg round_type;

    // 第一輪狀態
    localparam R1_S0 = 5'b00001; // led[0]
    localparam R1_S1 = 5'b00010; // led[1]
    localparam R1_S2 = 5'b00100; // led[2]
    localparam R1_S3 = 5'b01000; // led[3]
    localparam R1_S4 = 5'b01001; // led[2] (回程)
    localparam R1_S5 = 5'b01010; // led[1] (回程)
    localparam R1_END_WAIT = 5'b01011;

    // 第二輪狀態
    localparam R2_S0 = 5'b10001; // led[0]
    localparam R2_S1 = 5'b10010; // led[1]
    localparam R2_S2 = 5'b10100; // led[2]
    localparam R2_S3 = 5'b11000; // led[3]
    localparam R2_S4 = 5'b11001; // led[2] (回程)
    localparam R2_S5 = 5'b11010; // led[1] (回程)
    localparam R2_END_WAIT = 5'b11011;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 29'd0;
            current_state <= R1_S0;
            round_type <= 0;
            led <= 4'b0001; 
            led4_g <= 1'b1;
            led5_g <= 1'b0;
        end else begin
            counter <= counter + 1'b1;
            case (current_state)
                // 第一輪
                R1_S0: if (counter == `CYCLE_05S - 1) begin counter <= 29'd0; current_state <= R1_S1; led <= 4'b0010; end
                R1_S1: if (counter == `CYCLE_05S - 1) begin counter <= 29'd0; current_state <= R1_S2; led <= 4'b0100; end
                R1_S2: if (counter == `CYCLE_05S - 1) begin counter <= 29'd0; current_state <= R1_S3; led <= 4'b1000; end
                R1_S3: if (counter == `CYCLE_05S - 1) begin counter <= 29'd0; current_state <= R1_S4; led <= 4'b0100; end
                R1_S4: if (counter == `CYCLE_05S - 1) begin counter <= 29'd0; current_state <= R1_S5; led <= 4'b0010; end
                R1_S5: if (counter == `CYCLE_05S - 1) begin counter <= 29'd0; current_state <= R1_END_WAIT; led <= 4'b0000; end
                R1_END_WAIT: begin counter <= 29'd0; current_state <= R2_S0; round_type <= 1; led <= 4'b0001; end

                // 第二輪
                R2_S0: if (counter == `CYCLE_025S - 1) begin counter <= 29'd0; current_state <= R2_S1; led <= 4'b0010; end
                R2_S1: if (counter == `CYCLE_025S - 1) begin counter <= 29'd0; current_state <= R2_S2; led <= 4'b0100; end
                R2_S2: if (counter == `CYCLE_025S - 1) begin counter <= 29'd0; current_state <= R2_S3; led <= 4'b1000; end
                R2_S3: if (counter == `CYCLE_025S - 1) begin counter <= 29'd0; current_state <= R2_S4; led <= 4'b0100; end
                R2_S4: if (counter == `CYCLE_025S - 1) begin counter <= 29'd0; current_state <= R2_S5; led <= 4'b0010; end
                R2_S5: if (counter == `CYCLE_025S - 1) begin counter <= 29'd0; current_state <= R2_END_WAIT; led <= 4'b0000; end
                R2_END_WAIT: begin counter <= 29'd0; current_state <= R1_S0; round_type <= 0; led <= 4'b0001; end

                default: current_state <= R1_S0;
            endcase
            // 控制 led4_g 和 led5_g
            if (round_type == 0) begin
                led4_g <= 1'b1;
                led5_g <= 1'b0;
            end else begin
                led4_g <= 1'b0;
                led5_g <= 1'b1;
            end
        end
    end

endmodule
