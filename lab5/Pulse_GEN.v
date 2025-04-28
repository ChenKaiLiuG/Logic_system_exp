module Pulse_GEN (
input clk, rst,
input in,
output out
);
reg executed_once;
reg pulse;
always @(posedge clk or posedge rst) begin
    if (rst) begin
      executed_once <= 1'b0;
      pulse <= 0; 
    end 
    else begin
      if (in == 1'b1 & executed_once == 0) begin
        pulse <= 1; 
        executed_once <= 1'b1; 
        end
      else if(in == 1'b1 & executed_once != 0) begin
        pulse <= 0; 
        end
      end
    end
 
  assign out = pulse;
 
endmodule