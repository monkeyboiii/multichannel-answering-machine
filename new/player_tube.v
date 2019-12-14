`timescale 1ns / 1ps

module player_tube(
    input rst_n,                    //asychronous negative reset
    input [1:0] player,
    input [7:0] score,              //current score to display
    output [63:0] seg_out,
//    output reg [7:0] seg_out_7,     //P
//    output reg [7:0] seg_out_6,     //L
//    output reg [7:0] seg_out_5,     //1 or 2 or 3 or 4
//    output reg [7:0] seg_out_4,     //null
//    output [7:0] seg_out_3,         //S
//    output [7:0] seg_out_2,         //C
//    output [7:0] seg_out_1,         //score MSB
//    output [7:0] seg_out_0,         //score LSB
    output [7:0] seg_en
    );
    
    wire [3:0] msb;
    wire [3:0] lsb;
    bcd_convert bc(score,msb,lsb);
    
    wire [4:0] player_num;
    assign player_num=player+1;
    
    seg_tube st7(rst_n,{1'b0,4'ha},seg_out[63:56],seg_en[7]);
    
    seg_tube st6(rst_n,{1'b0,4'hb},seg_out[55:48],seg_en[6]);
    
    seg_tube st5(rst_n,player_num,seg_out[47:40],seg_en[5]);
    
    seg_tube st4(0,{1'b0,4'hf},seg_out[39:32],seg_en[4]);
    
    seg_tube st3(rst_n,{1'b0,4'hc},seg_out[31:24],seg_en[3]);
    
    seg_tube st2(rst_n,{1'b0,4'hd},seg_out[23:16],seg_en[2]);
    
    seg_tube st1(rst_n,{1'b0,msb},seg_out[15:8],seg_en[1]);
    
    seg_tube st0(rst_n,{1'b0,lsb},seg_out[7:0],seg_en[0]);
    
endmodule