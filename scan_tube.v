`timescale 1ns / 1ps

module scan_tube(
    input clk,
    input rst_n,
    input [1:0] player,
    input [7:0] score,
    output reg [7:0] seg_out,
    output reg [7:0] seg_en
    );
    
  
    wire clkout;
    frequency_divider #(2) fd(clk,rst_n,clkout);    //2 bits scan per seconds
    reg [4:0] scan_cnt;
    
    always@(posedge clkout or negedge rst_n)
    if(!rst_n)
        scan_cnt<=0;
    else if(scan_cnt<8)          
        scan_cnt<=scan_cnt+1;    //stay or traverse
    
    
    wire [3:0] msb;
    wire [3:0] lsb;
    bcd_convert bc(score,msb,lsb);
    wire [3:0] player_num;
    assign player_num=player+1;
    
    wire clk_tc;
    reg [2:0] tube_count;
    frequency_divider fd_tc(clk,rst_n,clk_tc);
    reg [3:0] sw;
    
    always@(posedge clk_tc or negedge rst_n) begin
        if(!rst_n) begin
            tube_count = 0;
            seg_en = 8'b1111_1111;
        end          
        else begin
            tube_count = tube_count + 1;
            
            case(scan_cnt)
                0:seg_en = 8'b1111_1111;
                1:begin 
                    seg_en = 8'b1111_1110; 
                    sw =4'ha;
                end
                2:begin
                    case(tube_count)
                        0:begin seg_en = 8'b1111_1110; sw = 4'hb; end
                        1:begin seg_en = 8'b1111_1101; sw = 4'ha; end
                        default: seg_en = 8'b1111_1111;
                    endcase
                end
                3:begin 
                    case(tube_count)
                        0:begin seg_en = 8'b1111_1110; sw = 4'h0; end
                        1:begin seg_en = 8'b1111_1101; sw = 4'hb; end
                        2:begin seg_en = 8'b1111_1011; sw = 4'ha; end
                        default: seg_en = 8'b1111_1111;
                    endcase
                end
                4:begin 
                    case(tube_count)
                        0:begin seg_en = 8'b1111_1110; sw = player_num; end
                        1:begin seg_en = 8'b1111_1101; sw = 4'h0; end
                        2:begin seg_en = 8'b1111_1011; sw = 4'hb; end
                        3:begin seg_en = 8'b1111_0111; sw = 4'ha; end
                        default: seg_en = 8'b1111_1111;
                    endcase
                end
                5:begin 
                    case(tube_count)
                        0:begin seg_en = 8'b1111_1110; sw = 4'hc; end
                        1:begin seg_en = 8'b1111_1101; sw = player_num; end
                        2:begin seg_en = 8'b1111_1011; sw = 4'h0; end
                        3:begin seg_en = 8'b1111_0111; sw = 4'hb; end
                        4:begin seg_en = 8'b1110_1111; sw = 4'ha; end
                        default: seg_en = 8'b1111_1111;
                    endcase
                end
                6:begin 
                    case(tube_count)
                        0:begin seg_en = 8'b1111_1110; sw = 4'hd; end
                        1:begin seg_en = 8'b1111_1101; sw = 4'hc; end
                        2:begin seg_en = 8'b1111_1011; sw = player_num; end
                        3:begin seg_en = 8'b1111_0111; sw = 4'h0; end
                        4:begin seg_en = 8'b1110_1111; sw = 4'hb; end
                        5:begin seg_en = 8'b1101_1111; sw = 4'ha; end
                        default: seg_en = 8'b1111_1111;
                    endcase
                end
                7:begin 
                    case(tube_count)
                        0:begin seg_en = 8'b1111_1110; sw = msb; end
                        1:begin seg_en = 8'b1111_1101; sw = 4'hd; end
                        2:begin seg_en = 8'b1111_1011; sw = 4'hc; end
                        3:begin seg_en = 8'b1111_0111; sw = player_num; end
                        4:begin seg_en = 8'b1110_1111; sw = 4'h0; end
                        5:begin seg_en = 8'b1101_1111; sw = 4'hb; end
                        6:begin seg_en = 8'b1011_1111; sw = 4'ha; end
                        default: seg_en = 8'b1111_1111;
                    endcase
                end
               
                8:begin
                    case(tube_count)
                        0:begin seg_en = 8'b1111_1110; sw = lsb; end
                        1:begin seg_en = 8'b1111_1101; sw = msb; end
                        2:begin seg_en = 8'b1111_1011; sw = 4'hd; end
                        3:begin seg_en = 8'b1111_0111; sw = 4'hc; end
                        4:begin seg_en = 8'b1110_1111; sw = player_num; end
                        5:begin seg_en = 8'b1101_1111; sw = 4'h0; end
                        6:begin seg_en = 8'b1011_1111; sw = 4'hb; end
                        7:begin seg_en = 8'b0111_1111; sw = 4'ha; end
                        default: seg_en = 8'b1111_1111;
                    endcase
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
        4'ha: seg_out=8'b0000_1100;         //P
        4'hb: seg_out=8'b0100_0111;         //L
        4'hc: seg_out=8'b0001_0010;         //S=5
        4'hd: seg_out=8'b0100_0110;         //C
        4'he: seg_out=8'b0111_0001;         //J
        4'hf: seg_out=8'b0111_1111;         //. and blank
        default: seg_out = 8'b1111_1111;    //no display
    endcase
    end
    
endmodule
