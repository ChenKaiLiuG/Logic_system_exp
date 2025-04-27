`timescale 1ns/1ns

module ButtonControlledMarquee_tb;

    reg clk;
    reg rst;
    reg btn0; // Speed Up
    reg btn1; // Speed Down
    wire [3:0] led;
    wire [3:0] speed_led;

    ButtonControlledMarquee uut (
        .clk(clk),
        .rst(rst),
        .btn0(btn0),
        .btn1(btn1),
        .led(led),
        .speed_led(speed_led)
    );

    parameter CLK_PERIOD = 8; // 對應 125MHz 時脈
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    initial begin
        rst = 1;
        #20;
        rst = 0;
        #20;
    end

    initial begin
        btn0 = 1'b0; 
        btn1 = 1'b0;

        #500000; 

        // Speed Up to 1 (btn0)
        btn0 = 1'b1;
        #50000;
        btn0 = 1'b0;
        #1000000;

        // Speed Down to 0 (btn1)
        btn1 = 1'b1;
        #50000;
        btn1 = 1'b0;
        #1000000;

        // Speed Up to 1
        btn0 = 1'b1;
        #50000;
        btn0 = 1'b0;
        #2000000;
        
        // Speed Up to 2
        btn0 = 1'b1;
        #50000;
        btn0 = 1'b0;
        #2000000;
        
        // Speed Up to 3
        btn0 = 1'b1;
        #50000;
        btn0 = 1'b0;
        #2000000;

        $finish;
    end

    initial begin
        $monitor("Time=%t, rst=%b, btn0=%b, btn1=%b, led=%b, speed_led=%b", $time, rst, btn0, btn1, led, speed_led);
    end

endmodule
