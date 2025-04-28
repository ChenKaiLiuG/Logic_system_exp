module MC_TOP (
    input clk, rst,
    input [1:0] btn,
    output [3:0] led
);

    
    wire btn0_deb, btn1_deb;
    wire up_pulse, down_pulse;
    BTN_DEB btn_deb0 (
        .clk(clk),
        .rst(rst),
        .btn(btn[0]),
        .btn_deb(btn0_deb)
    );

    BTN_DEB btn_deb1 (
        .clk(clk),
        .rst(rst),
        .btn(btn[1]),
        .btn_deb(btn1_deb)
    );

  
    Pulse_GEN pulse_gen0 (
        .clk(clk),
        .rst(rst),
        .in(btn0_deb),
        .out(up_pulse)
    );

    Pulse_GEN pulse_gen1 (
        .clk(clk),
        .rst(rst),
        .in(btn1_deb),
        .out(down_pulse)
    );

    
    MC counter (
        .clk(clk),
        .rst(rst),
        .up_pulse(up_pulse),
        .down_pulse(down_pulse),
        .led(led)
    );

endmodule