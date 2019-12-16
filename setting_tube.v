`timescale 1ns / 1ps

module setting_tube(
   input clk,
   input rst_n,
   input [1:0] cur_set,         //0: # of players; 1: time; 2: pos; 3: neg
   input [5:0] number,      //32 possible combinations
   output reg [7:0] seg_out,
   output reg [7:0] seg_en,
   output [5:0] led
);
    
    assign led=number;
    
    wire clkout;
    frequency_divider #(2) fd(clk,rst_n,clkout);
    reg state_cnt;        //2 state with blank pause 
    always@(posedge clkout or negedge rst_n)
        if(!rst_n)
            state_cnt<=0;
        else
            state_cnt<=~state_cnt;
    
               
    reg [4:0]sw;
    wire [3:0] msb;
    wire [3:0] lsb;
    bcd_convert pbc(number,msb,lsb);
    reg [2:0] tube_count;
    wire clk_tc;
    frequency_divider fd_tc(clk,rst_n,clk_tc);
    always@(posedge clk_tc or negedge rst_n) begin
        if(!rst_n) begin
            seg_en=8'b1111_1111;
            tube_count=tube_count+1;
        end
        else begin
            tube_count=tube_count+1;
            case(cur_set)
            0:begin //set # of players
                case(state_cnt)
                    0:case(tube_count)
                        0:begin seg_en = 8'b1111_1110; sw = lsb; end    //   
                        1:begin seg_en = 8'b1111_1101; sw = msb; end    //   
                        2:begin seg_en = 8'b1111_1011; sw = 4'hb; end   //L   
                        3:begin seg_en = 8'b1111_0111; sw = 4'ha; end   //P   
                        4:begin seg_en = 8'b1110_1111; sw = 4'ha; end   //P
                        6:begin seg_en = 8'b1011_1111; sw = 4'hc; end   //S
                        default: seg_en = 8'b1111_1111;
                    endcase
                    1:case(tube_count)
                        2:begin seg_en = 8'b1111_1011; sw = 4'hb; end  //L   
                        3:begin seg_en = 8'b1111_0111; sw = 4'ha; end  //P   
                        4:begin seg_en = 8'b1110_1111; sw = 4'ha; end  //P
                        6:begin seg_en = 8'b1011_1111; sw = 4'hc; end  
                        default: seg_en = 8'b1111_1111;
                    endcase
                    default: seg_en = 8'b1111_1111;
                endcase
            end
            1:begin //set countdown time
                case(state_cnt)
                    0:case(tube_count)
                        0:begin seg_en = 8'b1111_1110; sw = lsb; end    //   
                        1:begin seg_en = 8'b1111_1101; sw = msb; end    //   
                        2:begin seg_en = 8'b1111_1011; sw = 4'hc; end   //   
                        3:begin seg_en = 8'b1111_0111; sw = 4'he; end   //   
                        4:begin seg_en = 8'b1110_1111; sw = 5'b10111; end   //
                        6:begin seg_en = 8'b1011_1111; sw = 4'hc; end  
                        default: seg_en = 8'b1111_1111;
                    endcase
                    1:case(tube_count)
                        2:begin seg_en = 8'b1111_1011; sw = 4'hc; end       //S   
                        3:begin seg_en = 8'b1111_0111; sw = 4'he; end       //J  
                        4:begin seg_en = 8'b1110_1111; sw = 5'b10111; end   //d
                        6:begin seg_en = 8'b1011_1111; sw = 4'hc; end  
                        default: seg_en = 8'b1111_1111;
                    endcase
                    default: seg_en = 8'b1111_1111;
                endcase
            end
            2:begin //set positive
                case(state_cnt)
                    0:case(tube_count)
                        0:begin seg_en = 8'b1111_1110; sw = lsb; end    //   
                        1:begin seg_en = 8'b1111_1101; sw = msb; end    //   
                        2:begin seg_en = 8'b1111_1011; sw = 4'hc; end   //   
                        3:begin seg_en = 8'b1111_0111; sw = 4'h0; end   //   
                        4:begin seg_en = 8'b1110_1111; sw = 4'ha; end   //
                        6:begin seg_en = 8'b1011_1111; sw = 4'hc; end  
                        default: seg_en = 8'b1111_1111;
                    endcase
                    1:case(tube_count)
                        2:begin seg_en = 8'b1111_1011; sw = 4'hc; end  //S   
                        3:begin seg_en = 8'b1111_0111; sw = 4'h0; end  //0   
                        4:begin seg_en = 8'b1110_1111; sw = 4'ha; end  //P
                        6:begin seg_en = 8'b1011_1111; sw = 4'hc; end  
                        default: seg_en = 8'b1111_1111;
                    endcase
                    default: seg_en = 8'b1111_1111;
                endcase
            end
            3:begin //set negative
                case(state_cnt)
                    0:case(tube_count)
                        0:begin seg_en = 8'b1111_1110; sw = lsb; end    //   
                        1:begin seg_en = 8'b1111_1101; sw = msb; end    //   
                        2:begin seg_en = 8'b1111_1011; sw = 5'b10011; end   //G   
                        3:begin seg_en = 8'b1111_0111; sw = 5'b10100; end   //E  
                        4:begin seg_en = 8'b1110_1111; sw = 5'b10110; end   //N
                        6:begin seg_en = 8'b1011_1111; sw = 4'hc; end  
                        default: seg_en = 8'b1111_1111;
                    endcase
                    1:case(tube_count)
                        2:begin seg_en = 8'b1111_1011; sw = 5'b10011; end  //L   
                        3:begin seg_en = 8'b1111_0111; sw = 5'b10100; end  //   
                        4:begin seg_en = 8'b1110_1111; sw = 5'b10110; end  //
                        6:begin seg_en = 8'b1011_1111; sw = 4'hc; end  
                        default: seg_en = 8'b1111_1111;
                    endcase
                    default: seg_en = 8'b1111_1111;
                endcase
            end
            
            default seg_en = 8'b1111_1111;
            endcase
        end
    end
            
    always@*
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
        5'b10000: seg_out=8'b0100_0001;     //U
        5'b10001: seg_out=8'b0000_1000;     //A
        5'b10010: seg_out=8'b0000_0011;     //b
        5'b10011: seg_out=8'b0100_0010;     //G
        5'b10100: seg_out=8'b0000_0110;     //E
        5'b10101: seg_out=8'b1011_1111;     //-
        5'b10110: seg_out=8'b0100_1000;     //N
        5'b10111: seg_out=8'b0010_0001;     //d
        default: seg_out = 8'b1111_1111;    //no display
   endcase
    
endmodule