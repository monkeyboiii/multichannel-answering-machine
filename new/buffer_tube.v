`timescale 1ns / 1ps

//flipping os going up and down
module buffer_tube(
    input clk,
    input rst_n,
    output [63:0] seg_out,
    output [7:0] seg_en
    );
    
    wire clkout;
    frequency_divider #(1) fd(rst_n,clk,clkout);
    
    reg [39:0] sw;
    seg_tube st7(rst_n,sw[39:35],seg_out[63:56],seg_en[7]);
    seg_tube st6(rst_n,sw[34:30],seg_out[55:48],seg_en[6]);
    seg_tube st5(rst_n,sw[29:25],seg_out[47:40],seg_en[5]);
    seg_tube st4(rst_n,sw[24:20],seg_out[39:32],seg_en[4]);
    seg_tube st3(rst_n,sw[19:15],seg_out[31:24],seg_en[3]);
    seg_tube st2(rst_n,sw[14:10],seg_out[23:16],seg_en[2]);
    seg_tube st1(rst_n,sw[9:5],seg_out[15:8],seg_en[1]);
    seg_tube st0(rst_n,sw[4:0],seg_out[7:0],seg_en[0]);
    
    reg count;
    always@(posedge clkout or negedge rst_n) begin
        if(!rst_n)
            count<=0;
        else
            count<=count+1;
    end
    
    always@(posedge clkout or negedge rst_n) begin
        if(!rst_n)
            sw=64'b0;
        else begin
            case(count)
                0:begin
                   sw[4:0]<=5'b10010;
                   sw[9:5]<=5'b10010;
                   sw[14:10]<=5'b10010;
                   sw[19:15]<=5'b10010;
                   sw[24:20]<=5'b10010;
                   sw[29:25]<=5'b10010;
                   sw[34:30]<=5'b10010;
                   sw[39:35]<=5'b10010;
                end
                1:begin
                   sw[4:0]<=5'b10011;
                   sw[9:5]<=5'b10011;
                   sw[14:10]<=5'b10011;
                   sw[19:15]<=5'b10011;
                   sw[24:20]<=5'b10011;
                   sw[29:25]<=5'b10011;
                   sw[34:30]<=5'b10011;
                   sw[39:35]<=5'b10011;
                end
            endcase
        end
    end

endmodule
