`timescale 1ns / 1ps


//JPL1 PL01/Pb01/SC10
module rejudge_tube(
    input clk,
    input rst_n,
    input [1:0] player,
    input [7:0] score,
    input [7:0] problemID,
    output [63:0] seg_out,
    output [7:0] seg_en    
    );
    
    wire clkout;
    frequency_divider #(1) fd(rst_n,clk,clkout);
    
    wire [4:0] player_num;
    assign player_num=player+1;
    
    seg_tube st7(rst_n,{1'b0,4'he},seg_out[63:56],seg_en[7]);
    seg_tube st6(rst_n,5'b1_0000,seg_out[55:48],seg_en[6]);
    seg_tube st5(rst_n,5'b0,seg_out[47:40],seg_en[5]);
    seg_tube st4(rst_n,5'b0,seg_out[39:32],seg_en[4]);
    
    reg [1:0] count;
    always@(posedge clkout or negedge rst_n) begin
        if(!rst_n)
            count<=0;
        else
            count<=count+1;
    end    
    
    //change
    reg [19:0] sw;    
    seg_tube st3(rst_n,sw[19:15],seg_out[31:24],seg_en[3]);
    seg_tube st2(rst_n,sw[14:10],seg_out[23:16],seg_en[2]);
    seg_tube st1(rst_n,sw[9:5],seg_out[15:8],seg_en[1]);
    seg_tube st0(rst_n,sw[4:0],seg_out[7:0],seg_en[0]);    
    
    wire [3:0] IDmsb;
    wire [3:0] IDlsb;
    bcd_convert pbc(problemID,IDmsb,IDlsb);
    wire [3:0] SCmsb;
    wire [3:0] SClsb;
    bcd_convert sbc(score,SCmsb,SClsb);
    
    always@(posedge clkout or negedge rst_n) begin
        if(!rst_n)
            sw<=0;
        else
            case(count)
                0:begin
                    sw[4:0]=player_num;
                    sw[9:5]={1'b0,4'h0};
                    sw[14:10]={1'b0,4'hb};
                    sw[19:15]={1'b0,4'ha};
                end
                1:begin
                    sw[4:0]=player_num;
                    sw[9:5]={1'b0,4'h0};
                    sw[14:10]={1'b0,4'hb};
                    sw[19:15]={1'b0,4'ha};
                end
                2:begin
                    sw[4:0]=IDlsb;
                    sw[9:5]=IDmsb;
                    sw[14:10]=5'b10100;
                    sw[19:15]={1'b0,4'ha}; 
                end
                3:begin               
                    sw[4:0]=SClsb;
                    sw[9:5]=SCmsb;
                    sw[14:10]={1'b0,4'hd};
                    sw[19:15]={1'b0,4'hc};
                end
            endcase
    end
    
endmodule