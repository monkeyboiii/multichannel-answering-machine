`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/12/14 10:40:17
// Design Name: 
// Module Name: edge_detect
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module edge_detect(
input clk,rst_n,trig,
output pos
    );
    reg trig1,trig2,trig3;
    always @(posedge clk,negedge rst_n) begin
        if(!rst_n)
            trig1 <=1'b0;
        else
            trig1 <= trig;
    end
    always @(posedge clk,negedge rst_n) begin
            if(!rst_n)
                trig2 <=1'b0;
            else
                trig2 <= trig1;
     end
     always @(posedge clk,negedge rst_n) begin
                    if(!rst_n)
                        trig3 <=1'b0;
                    else
                        trig3 <= trig2;
      end
      assign pos = ~trig3 && trig2;
endmodule
