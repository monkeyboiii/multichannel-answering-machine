`timescale 1ns / 1ps

//maximium 99 seconds
//countdown from 10 intervals/seconds (default)
module countdown_tube #(parameter t=10)(
    input clk,                      //clock
    input rst_n,                    //asychronous negative reset
    input run_pause,                //run or pause
    output [15:0] seg_out,         //2 seg tube in use MSB, LSB
    output [1:0] seg_en,
    output beep                     //triggered when terminated
    );

    //state 0: counting down; state 1: finished
    reg state=0;
    //maximium 99 (256) seconds
    reg [7:0] seconds=0;
    wire [7:0] current;
    assign current=t-seconds;
    
    //1Hz clkout
    wire clkout;
    frequency_divider #(1) fd(clk,rst_n,clkout);
    
    always @(posedge clkout) begin
        if(!rst_n) begin
            seconds<=8'b0;
            state<=0;
        end
        else if(run_pause)
            if(!state)
                seconds<=seconds+1'b1;
    end
    
    
    //end
    //state = 1 indicates termination, triggering beeper
    beeper countdown_beep(clk,state,beep);
    always@(seconds)
        if(current==0)
            state<=1;
    
    
    //convert current into to bcd numbers
    wire [3:0] c_msb;
    wire [3:0] c_lsb;
    bcd_convert bc(current,c_msb,c_lsb);

    
    //display 2 bit number
    seg_tube msb(rst_n,{1'b0,c_msb},seg_out[15:8],seg_en[1]);
    seg_tube lsb(rst_n,{1'b0,c_lsb},seg_out[7:0],seg_en[0]);
    
endmodule