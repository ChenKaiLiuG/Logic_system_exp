module MC (
input clk, rst,
input up_pulse, down_pulse,
output [3:0] led
);
reg [3:0] counter;
wire add, minus;
assign add = ((up_pulse == 1) & (counter <= 4'd15));
assign minus = ((down_pulse == 1) & (counter >= 4'd0));

always@(posedge rst or posedge clk)begin
if(rst) counter <= 4'd0;
else if(add) counter <= counter + 4'd1;
else if (minus) counter <= counter - 4'd1;
else counter <= counter;
end

assign led = counter;

endmodule