`timescale 1ns / 1ps

//maximium 99 seconds
//countdown from 10 intervals/seconds (default)
module countdown_tube #(parameter t=10)(
    input clk,                      //clock
    input rst_n,                    //asychronous negative reset
    input run_pause,                //run or pause
    output reg [7:0] seg_out,       //2 seg tube in use MSB, LSB
    output reg [7:0] seg_en,        //low voltage active
    output beep                     //triggered when terminated
    );


    reg state;          //state 0: counting down    //state 1: finished
    reg [7:0] seconds;
    wire clkout;
    frequency_divider #(1) fd(clk,rst_n,clkout);    //1Hz clkout
    beeper countdown_beep(clk,state,beep);
    
    always @(posedge clkout or negedge rst_n) begin
        if(!rst_n) begin
            seconds <= 8'h00;
            state <= 0;
        end
        else if(run_pause && !state)
            if(seconds<t)
                seconds<=seconds+1'b1;
            else
                state<=1;
    end

    
    
    wire clk_tc;
    reg tube_count;
    frequency_divider fd_tc(clk,rst_n,clk_tc);
    wire [3:0] msb;
    wire [3:0] lsb;
    reg [3:0] sw;
    bcd_convert bc(t-seconds,msb,lsb);
    
    always@(posedge clk_tc or negedge rst_n) begin
        if(!rst_n) begin
            tube_count = 0;
            seg_en = 8'b1111_1111;
        end          
        else begin
            tube_count = ~tube_count;
            case(tube_count)
                0:begin 
                    seg_en = 8'b1111_1110;
                    sw = lsb; 
                end
                1:begin
                    seg_en = 8'b1111_1101;
                    sw = msb;
                end
            endcase
        end
    end
    
    always @* begin
    case(sw)
        4'h0: seg_out=8'b0100_0000;         //0
        4'h1: seg_out=8'b0111_1001;         //1
        4'h2: seg_out=8'b0010_0100;
        4'h3: seg_out=8'b0011_0000;
        4'h4: seg_out=8'b0001_1001;
        4'h5: seg_out=8'b0001_0010;
        4'h6: seg_out=8'b0000_0010;
        4'h7: seg_out=8'b0111_1000;
        4'h8: seg_out=8'b0000_0000;
        4'h9: seg_out=8'b0001_0000;         //9
        default: seg_out = 8'b1111_1111;    //no display
    endcase
    end        
    
endmodule