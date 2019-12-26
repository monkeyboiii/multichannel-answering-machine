`timescale 1ns / 1ps

//t is second(s)
//intensity is frequency
module beeper #(parameter t=1,parameter intensity=1000)(
    input clk,
    input rst_n,
    output reg beep
    );
    
    wire clkout;
    frequency_divider #(intensity) fd(clk,rst_n,clkout);
    
    //maximium cnt is 1048576 beeps
    reg [19:0] cnt=0;
	parameter total=2*t*intensity;
	
	always @ (posedge clkout or negedge rst_n)
	begin
	   if(!rst_n)
	       cnt <= 20'b0;
	   else if(cnt<total)
	       cnt <= cnt + 1'b1;
	end
 
	always @ (posedge clkout or negedge rst_n)
	begin
		if(!rst_n)
            beep <= 0;
		else if(cnt<total)
            beep <= ~beep;
	end
	
endmodule