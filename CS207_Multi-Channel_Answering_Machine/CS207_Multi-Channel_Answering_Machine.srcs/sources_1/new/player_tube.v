`timescale 1ns / 1ps

module player_tube(
    input clk,
    input rst_n,                    //asychronous negative reset
    input [2:0] player,             //0:--; 1:1; 2:2; 3:3; 4:4;
    input pos,                      //0: negative; 1:positive
    input [7:0] score,              //current score to display
    output reg [7:0] seg_out,       //PL3SC(-)04
    output reg [7:0] seg_en
    );
    
      
    wire clk_tc;
    reg [2:0] tube_count;
    frequency_divider fd_tc(clk,rst_n,clk_tc);
    wire [3:0] msb;
    wire [3:0] lsb;
    reg [3:0] sw;
    bcd_convert bc(score,msb,lsb);
        
    always@(posedge clk_tc or negedge rst_n)
        if(!rst_n) begin
            tube_count = 0;
            seg_en = 8'b1111_1111;
        end          
        else begin
            tube_count = tube_count+1;                
            case(tube_count)
                0:begin seg_en = 8'b1111_1110; sw = lsb; end
                1:begin seg_en = 8'b1111_1101; sw = msb; end
                2:case(pos)
                    0:begin seg_en = 8'b1111_1011;sw=4'hf; end
                    default:begin seg_en = 8'b1111_1111; end
                endcase
                5:begin seg_en = 8'b1101_1111; 
                    case(player)
                        0:sw = 4'hf;
                        default: sw={1'b0,player};
                    endcase
                end
                6:begin seg_en = 8'b1011_1111; sw = 4'hb; end
                7:begin seg_en = 8'b0111_1111; sw = 4'ha; end
                default: seg_en = 8'b1111_1111;
            endcase
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
        4'hf: seg_out=8'b1011_1111;         //-
        default: seg_out = 8'b1111_1111;    //no display
    endcase
    end        
            
endmodule