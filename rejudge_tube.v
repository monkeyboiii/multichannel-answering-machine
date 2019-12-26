`timescale 1ns / 1ps


//JUGE PL01/Pb01/SC10
module rejudge_tube(
    input clk,
    input rst_n,
    input [1:0] player,
    input [7:0] score,
    input [7:0] problemID,
    output reg [7:0] seg_out,
    output reg [7:0] seg_en    
    );
    
    wire clkout;
    frequency_divider #(1) fd(clk,rst_n,clkout);
    reg [2:0] time_cnt;        //7 state with blank pause 
    always@(posedge clkout or negedge rst_n)
        if(!rst_n)
            time_cnt<=0;
        else if(time_cnt<6)
            time_cnt<=time_cnt+1;
        else
            time_cnt<=0;
    
               
    reg [4:0]sw;
    wire [3:0] IDmsb;
    wire [3:0] IDlsb;
    bcd_convert pbc(problemID,IDmsb,IDlsb);
    wire [3:0] SCmsb;
    wire [3:0] SClsb;
    bcd_convert sbc(score,SCmsb,SClsb);
    wire [3:0] player_num;
    assign player_num=player+1;
    reg [2:0] tube_count;
    wire clk_tc;
    frequency_divider fd_tc(clk,rst_n,clk_tc);
    always@(posedge clk_tc or negedge rst_n)
        if(!rst_n) begin
            seg_en=8'b1111_1111;
            tube_count=tube_count+1;
        end
        else begin
            tube_count=tube_count+1;
            casex(time_cnt)
            3'b00x: begin   //1, 2 second 
                 case(tube_count)
                 0:begin seg_en = 8'b1111_1110; sw = player_num; end//x
                 1:begin seg_en = 8'b1111_1101; sw = 4'h0; end      //0
                 2:begin seg_en = 8'b1111_1011; sw = 4'hb; end      //L
                 3:begin seg_en = 8'b1111_0111; sw = 4'ha; end      //P
                 4:begin seg_en = 8'b1110_1111; sw = 5'b10100; end  //E
                 5:begin seg_en = 8'b1101_1111; sw = 5'b10011; end  //G
                 6:begin seg_en = 8'b1011_1111; sw = 5'b10000; end  //U
                 7:begin seg_en = 8'b0111_1111; sw = 4'he; end      //J
                 default: seg_en = 8'b1111_1111;
                 endcase
            end
            3'b010: begin   //3 second 
                 case(tube_count)
                 0:begin seg_en = 8'b1111_1110; sw = 5'b10101; end  //-
                 1:begin seg_en = 8'b1111_1101; sw = 5'b10101; end  //-    
                 2:begin seg_en = 8'b1111_1011; sw = 5'b10101; end  //-   
                 3:begin seg_en = 8'b1111_0111; sw = 5'b10101; end  //-   
                 4:begin seg_en = 8'b1110_1111; sw = 5'b10100; end  
                 5:begin seg_en = 8'b1101_1111; sw = 5'b10011; end  
                 6:begin seg_en = 8'b1011_1111; sw = 5'b10000; end  
                 7:begin seg_en = 8'b0111_1111; sw = 4'he; end      
                 default: seg_en = 8'b1111_1111;
                 endcase
            end
            3'b011: begin   //4 second Pb 
                 case(tube_count)
                 0:begin seg_en = 8'b1111_1110; sw = IDlsb; end  
                 1:begin seg_en = 8'b1111_1101; sw = IDmsb; end      
                 2:begin seg_en = 8'b1111_1011; sw = 5'b10010; end   
                 3:begin seg_en = 8'b1111_0111; sw = 4'ha; end   
                 4:begin seg_en = 8'b1110_1111; sw = 5'b10100; end  
                 5:begin seg_en = 8'b1101_1111; sw = 5'b10011; end  
                 6:begin seg_en = 8'b1011_1111; sw = 5'b10000; end  
                 7:begin seg_en = 8'b0111_1111; sw = 4'he; end      
                 default: seg_en = 8'b1111_1111;
                 endcase
            end
            3'b100: begin   //5 second 
                 case(tube_count)
                 0:begin seg_en = 8'b1111_1110; sw = 5'b10101; end  //-
                 1:begin seg_en = 8'b1111_1101; sw = 5'b10101; end  //-    
                 2:begin seg_en = 8'b1111_1011; sw = 5'b10101; end  //-   
                 3:begin seg_en = 8'b1111_0111; sw = 5'b10101; end  //-   
                 4:begin seg_en = 8'b1110_1111; sw = 5'b10100; end  
                 5:begin seg_en = 8'b1101_1111; sw = 5'b10011; end  
                 6:begin seg_en = 8'b1011_1111; sw = 5'b10000; end  
                 7:begin seg_en = 8'b0111_1111; sw = 4'he; end      
                 default: seg_en = 8'b1111_1111;
                 endcase
            end
            3'b101: begin   //6 second 
                 case(tube_count)
                 0:begin seg_en = 8'b1111_1110; sw = SClsb; end  
                 1:begin seg_en = 8'b1111_1101; sw = SCmsb; end 
                 2:begin seg_en = 8'b1111_1011; sw = 4'hd; end  
                 3:begin seg_en = 8'b1111_0111; sw = 4'hc; end 
                 4:begin seg_en = 8'b1110_1111; sw = 5'b10100; end  
                 5:begin seg_en = 8'b1101_1111; sw = 5'b10011; end  
                 6:begin seg_en = 8'b1011_1111; sw = 5'b10000; end  
                 7:begin seg_en = 8'b0111_1111; sw = 4'he; end      
                 default: seg_en = 8'b1111_1111;
                 endcase
            end
            3'b110: begin   //7 second 
                 case(tube_count)
                 0:begin seg_en = 8'b1111_1110; sw = 5'b10101; end  //-
                 1:begin seg_en = 8'b1111_1101; sw = 5'b10101; end  //-    
                 2:begin seg_en = 8'b1111_1011; sw = 5'b10101; end  //-   
                 3:begin seg_en = 8'b1111_0111; sw = 5'b10101; end  //-   
                 4:begin seg_en = 8'b1110_1111; sw = 5'b10100; end  
                 5:begin seg_en = 8'b1101_1111; sw = 5'b10011; end  
                 6:begin seg_en = 8'b1011_1111; sw = 5'b10000; end  
                 7:begin seg_en = 8'b0111_1111; sw = 4'he; end      
                 default: seg_en = 8'b1111_1111;
                 endcase
            end
            default: seg_en = 8'b1111_1111;
            endcase
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
        default: seg_out = 8'b1111_1111;    //no display
   endcase
    
endmodule