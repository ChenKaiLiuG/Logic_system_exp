`timescale 1ps / 1ps

module tb_mc_top;
    reg clk, rst;
    reg [1:0] btn;
    wire [3:0] led;
    
    MC_TOP mc_top(
    .clk(clk),
    .rst(rst),
    .btn(btn),
    .led(led)
    );
    
    always #5000 clk <= ~clk;
    
    initial begin
        clk = 1; rst = 1;
        btn = 2'd0;
        #5000 rst = 0;
        #15000 btn[0] = 1;
        #1
        for(integer i = 0; i < 40; i=i+1) begin
            #500 btn[0] = ~btn[0];
        end
        #500 btn[0] = 1;
        #70000 btn[0] = 0;
        for(integer i = 0; i < 40; i=i+1) begin
            #500 btn[0] = ~btn[0];
        end
        #500 btn[0] = 0;
        
        #35000;
        $finish;
    end
endmodule
