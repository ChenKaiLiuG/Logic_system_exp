`timescale 1ns/1ns

module Adjustable_Rainbow_Breathing_LED_tb;

    // Inputs
    reg clk;
    reg rst;
    reg [1:0] btn;

    // Outputs
    wire [3:0] led_mode;
    wire led_r, led_g, led_b;

    // Instantiate the Unit Under Test (UUT)
    Adjustable_Rainbow_Breathing_LED uut (
        .clk(clk),
        .rst(rst),
        .btn(btn),
        .led_mode(led_mode),
        .led_r(led_r),
        .led_g(led_g),
        .led_b(led_b)
    );

    // Clock Generation
    parameter CLK_PERIOD = 8; // 125MHz clock => 8ns period [cite: 2, 3]
    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // Reset Generation
    initial begin
        rst = 1'b1;
        #10;  // Hold reset for 10 time units
        rst = 1'b0;
    end

    // Test Sequence
    initial begin
        // Initialize inputs
        btn = 2'b00;

        // Test Case 1: Initial State
        #20;
        $display("Time=%0t: rst=%b, btn=%b, led_mode=%b, led_r=%b, led_g=%b, led_b=%b", $time, rst, btn, led_mode, led_r, led_g, led_b);
        assert(led_mode == 4'b0010) else $error("ERROR: Initial speed mode should be 1 (0010)");

        // Test Case 2: Speed Up Button Press
        btn = 2'b01; // Press btn[0] to speed up
        #((20 * 8 * 20)/2); // Wait for debounce time (20ms) + extra
        btn = 2'b00;
        #100;
        $display("Time=%0t: rst=%b, btn=%b, led_mode=%b, led_r=%b, led_g=%b, led_b=%b", $time, rst, btn, led_mode, led_r, led_g, led_b);
        assert(led_mode == 4'b0100) else $error("ERROR: Speed mode should increase to 2 (0100)");

        // Test Case 3: Slow Down Button Press
        btn = 2'b10; // Press btn[1] to slow down
        #((20 * 8 * 20)/2); // Wait for debounce time (20ms)
        btn = 2'b00;
        #100;
         $display("Time=%0t: rst=%b, btn=%b, led_mode=%b, led_r=%b, led_g=%b, led_b=%b", $time, rst, btn, led_mode, led_r, led_g, led_b);
        assert(led_mode == 4'b0010) else $error("ERROR: Speed mode should decrease to 1 (0010)");

        // Test Case 4: Multiple Speed Up Presses
        btn = 2'b01; #((20 * 8 * 20)/2); btn = 2'b00; #100;
        btn = 2'b01; #((20 * 8 * 20)/2); btn = 2'b00; #100;
        $display("Time=%0t: rst=%b, btn=%b, led_mode=%b, led_r=%b, led_g=%b, led_b=%b", $time, rst, btn, led_mode, led_r, led_g, led_b);
        assert(led_mode == 4'b1000) else $error("ERROR: Speed mode should be 3 (1000)");

        // Test Case 5: Multiple Slow Down Presses
         btn = 2'b10; #((20 * 8 * 20)/2); btn = 2'b00; #100;
         btn = 2'b10; #((20 * 8 * 20)/2); btn = 2'b00; #100;
         btn = 2'b10; #((20 * 8 * 20)/2); btn = 2'b00; #100;
         $display("Time=%0t: rst=%b, btn=%b, led_mode=%b, led_r=%b, led_g=%b, led_b=%b", $time, rst, btn, led_mode, led_r, led_g, led_b);
         assert(led_mode == 4'b0001) else $error("ERROR: Speed mode should be 0 (0001)");

        // Test Case 6: Color Change (Check after 1 second)
        #100000;  // Wait for 1 second (125_000_000 cycles) - Adjust as needed
        $display("Time=%0t: rst=%b, btn=%b, led_mode=%b, led_r=%b, led_g=%b, led_b=%b", $time, rst, btn, led_mode, led_r, led_g, led_b);
       // Add assertions to check for color changes (this is complex and depends on PWM)

        #100;
        $finish; // End simulation
    end

endmodule
