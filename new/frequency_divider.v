`timescale 1ns / 1ps

//default 100MHz divided into 100Hz
module frequency_divider#(parameter target=100)(
    input clk,
    input rst_n,
    output reg clkout
    );
    
    //2^27 > 100M
    reg [26:0] cnt=0;
    parameter divisor=100_000_000/target;
    
    always@(posedge clk,negedge rst_n)
    begin
        if(!rst_n) begin
            cnt<=0;
            clkout<=0;
        end
        else if(cnt==(divisor>>1)-1) begin  
            cnt<=0;
            clkout=~clkout;
        end
        else
            cnt<=cnt+1;
    end
    
endmodule
