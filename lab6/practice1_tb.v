`timescale 1ns / 1ns

module Rainbow_Breathing_LED_tb;

    // Inputs
    reg clk;
    reg rst;

    // Outputs
    wire led_r;
    wire led_g;
    wire led_b;
    //wire led;

    // Instantiate the unit under test (UUT)
    Rainbow_Breathing_LED uut (
        .clk(clk),
        .rst(rst),
        .led_r(led_r),
        .led_g(led_g),
        .led_b(led_b)//,
        //.led_0(led)
    );

    // Clock generation
    parameter CLK_PERIOD = 8; // 8ns clock period (adjust as needed)
    always # (CLK_PERIOD / 2) clk = ~clk;

    // Testbench stimulus
    initial begin
        // Initialize inputs
        clk = 0;
        rst = 1;

        // Apply reset
        #10 rst = 0;
        // Simulate for a while
        #10000000  // Run simulation for 2ms (adjust as needed)
         $finish;  // End simulation
    end

    // Add any testbench logic to check outputs here
    // For example, you can monitor the outputs and display values
    initial begin
        $monitor ("Time = %t, rst = %b, clk = %b, led_r = %b, led_g = %b, led_b = %b", $time, rst, clk, led_r, led_g, led_b);
    end

endmodule
