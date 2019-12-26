`timescale 1ns / 1ps

//flipping os
module buffer_tube(
    input clk,
    input rst_n,
    output reg [7:0] seg_out,
    output reg [7:0] seg_en
    );
    
    wire clkout;
    frequency_divider #(1) fd(clk,rst_n,clkout);
    reg time_cnt;
    always@(posedge clkout or negedge rst_n)
    if(!rst_n)
        time_cnt<=0;
    else
        time_cnt<=~time_cnt;
    
    
    wire clk_tc;
    reg tube_count;
    frequency_divider fd_tc(clk,rst_n,clk_tc);
  
    always@(posedge clk_tc or negedge rst_n) begin
        if(!rst_n) begin
            tube_count = 0;
            seg_en = 8'b1111_1111;
        end          
        else begin
            tube_count = ~tube_count;
            case(time_cnt)
                0:case(tube_count)
                    0: seg_en=8'b1010_1010;
                    1: seg_en=8'b0101_0101;
                    default: seg_en=8'b1111_1111;
                endcase
                1:case(tube_count)
                    0: seg_en=8'b0101_0101;
                    1: seg_en=8'b1010_1010;
                    default: seg_en=8'b1111_1111;
                endcase
                default: seg_en=8'b1111_1111;
            endcase
        end
    end
    
    always @*
    case(tube_count)
        0: seg_out=8'b0010_0011;            //lower o
        1: seg_out=8'b0001_1100;            //upper o
        default: seg_out = 8'b1111_1111;    //no display
    endcase

endmodule
