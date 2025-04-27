`timescale 1ns / 1ps

module tb_marquee_pynq_real;

    reg clk;
    reg [2:0] btn;
    wire [7:0] led;
    wire [3:0] speed_led;

    // Instantiate the DUT
    marquee_pynq uut (
        .clk(clk),
        .btn(btn),
        .led(led),
        .speed_led(speed_led)
    );

    // 125MHz clock (8ns period)
    always #4 clk = ~clk;

    initial begin
        $display("Real-Time Simulation starts...");
        $dumpfile("marquee_real.vcd");
        $dumpvars(0, tb_marquee_pynq_real);

        clk = 0;
        btn = 3'b000;

        #100;

        // Reset system
        btn[2] = 1;  // assert reset
        #80;
        btn[2] = 0;  // deassert reset

        // Let it run at 2 sec mode (default after reset)
        #2_500_000_000;  // 2.5s

        // Speed up to 1 sec mode
        btn[0] = 1;
        #80;
        btn[0] = 0;

        #1_200_000_000;  // 1.2s

        // Speed up to 0.5 sec mode
        btn[0] = 1;
        #80;
        btn[0] = 0;

        #600_000_000;    // 0.6s

        // Speed up to 0.25 sec mode
        btn[0] = 1;
        #80;
        btn[0] = 0;

        #400_000_000;    // 0.4s

        // Slow down back to 0.5 sec mode
        btn[1] = 1;
        #80;
        btn[1] = 0;

        #600_000_000;    // 0.6s

        // Reset again
        btn[2] = 1;
        #80;
        btn[2] = 0;

        #2_500_000_000;  // 2.5s

        $finish;
    end

endmodule
