module marquee(
    input clk,                  // 125MHz clock
    input [2:0] btn,            // btn[0]: speed up, btn[1]: speed down, btn[2]: reset
    output reg [7:0] led,       // LED 跑馬燈輸出
    output reg [3:0] speed_led  // 顯示目前速度（只用 4 個 LED）
);

    parameter S0 = 125_000_000 * 2;     // 2秒
    parameter S1 = 125_000_000 * 1;     // 1秒
    parameter S2 = 125_000_000 / 2;     // 0.5秒
    parameter S3 = 125_000_000 / 4;     // 0.25秒

    reg [31:0] count;
    reg [1:0] speed;
    reg [31:0] count_max;

    // 按鈕記憶避免重複觸發
    reg [2:0] btn_last;

    // 設定目前速度對應的計時上限
    always @(*) begin
        case (speed)
            2'd0: count_max = S0;
            2'd1: count_max = S1;
            2'd2: count_max = S2;
            2'd3: count_max = S3;
        endcase
    end

    // 按鈕處理：速度調整 & reset
    always @(posedge clk) begin
        btn_last <= btn;

        if (btn[2]) begin // 非同步 reset（btn[2]）
            speed <= 2'd0;
        end else begin
            if (btn[0] && !btn_last[0] && speed < 2'd3)
                speed <= speed + 1;
            else if (btn[1] && !btn_last[1] && speed > 2'd0)
                speed <= speed - 1;
        end
    end

    // 跑馬燈控制
    always @(posedge clk) begin
        if (btn[2]) begin
            count <= 0;
            led <= 8'b00000001;
        end else begin
            if (count >= count_max) begin
                count <= 0;
                led <= (led == 8'b10000000) ? 8'b00000001 : led << 1;
            end else begin
                count <= count + 1;
            end
        end
    end

    // 顯示當前速度模式
    always @(*) begin
        case (speed)
            2'd0: speed_led = 4'b0001;
            2'd1: speed_led = 4'b0010;
            2'd2: speed_led = 4'b0100;
            2'd3: speed_led = 4'b1000;
        endcase
    end

endmodule
