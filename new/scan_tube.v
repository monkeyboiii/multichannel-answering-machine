`timescale 1ns / 1ps

module scan_tube(
    input clk,
    input rst_n,
    input [1:0] player,
    input [7:0] score,
    output [63:0] seg_out,
    output [7:0] seg_en
    );
    
  
    //2 bits scan per seconds
    wire clkout;
    frequency_divider #(2) fd(clk,rst_n,clkout);
    
    
    //up to 16
    reg [3:0] scan_cnt;
    
    
    //flipped for better interpretation, negative trigger
    reg [7:0] seg_en_n;
    assign seg_en=~seg_en_n;
     
    
    always@(posedge clkout or negedge rst_n)
    begin
       if(!rst_n)
           scan_cnt<=0;
       else if(scan_cnt<8)          //stay
           scan_cnt<=scan_cnt+1;    //traverse
    end
    
    
    //can be improved
    always@(scan_cnt)
    begin 
       case(scan_cnt)
           4'b0000: seg_en_n=8'b0000_0000;
           4'b0001: seg_en_n=8'b0000_0001;
           4'b0010: seg_en_n=8'b0000_0011;
           4'b0011: seg_en_n=8'b0000_0111;
           4'b0100: seg_en_n=8'b0000_1111;
           4'b0101: seg_en_n=8'b0001_1111;
           4'b0110: seg_en_n=8'b0011_1111;
           4'b0111: seg_en_n=8'b0111_1111;
           4'b1000: seg_en_n=8'b1111_1111;
           default: seg_en_n=8'b0000_0000;
       endcase
    end
    
    
    wire [3:0] msb;
    wire [3:0] lsb;
    bcd_convert bc(score,msb,lsb);
    wire [3:0] player_num;
    assign player_num=player+1;
    
    reg [4:0] sw;
    //separate control of the seg_tubes, here seg_en_lower is obsolete
    wire [7:0] seg_en_lower;
    seg_tube st7(rst_n,{1'b0,sw[31:28]},seg_out[63:56],seg_en_lower[7]);
    seg_tube st6(rst_n,{1'b0,sw[27:24]},seg_out[55:48],seg_en_lower[6]);
    seg_tube st5(rst_n,{1'b0,sw[23:20]},seg_out[47:40],seg_en_lower[5]);
    seg_tube st4(rst_n,{1'b0,sw[19:16]},seg_out[39:32],seg_en_lower[4]);
    seg_tube st3(rst_n,{1'b0,sw[15:12]},seg_out[31:24],seg_en_lower[3]);
    seg_tube st2(rst_n,{1'b0,sw[11:8]},seg_out[23:16],seg_en_lower[2]);
    seg_tube st1(rst_n,{1'b0,sw[7:4]},seg_out[15:8],seg_en_lower[1]);
    seg_tube st0(rst_n,{1'b0,sw[3:0]},seg_out[7:0],seg_en_lower[0]);
    
    always@(scan_cnt) begin
        if(!rst_n)
            sw=0;
        else
            if(scan_cnt==0)
                sw=4'b0000;
            else begin
                sw[31:4]=sw[27:0];
                case(scan_cnt)
                    4'b0000: sw[3:0]=4'hf;
                    4'b0001: sw[3:0]=4'ha;
                    4'b0010: sw[3:0]=4'hb;
                    4'b0011: sw[3:0]=player_num;
                    4'b0100: sw[3:0]=4'hf;
                    4'b0101: sw[3:0]=4'hc;
                    4'b0110: sw[3:0]=4'hd;
                    4'b0111: sw[3:0]=msb;
                    4'b1000: sw[3:0]=lsb;
                    default: sw[3:0]=4'b000;
                endcase
            end
    end
     
endmodule
