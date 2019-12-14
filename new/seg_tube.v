`timescale 1ns / 1ps

module seg_tube(
    input rst_n,
    input [4:0] sw,     //32 possible combinations
    output reg [7:0] seg_out,
    output reg seg_en
    );
      
    always @* begin
        if(!rst_n) begin
            seg_en = 1'b1;          //low voltage active
            seg_out = 8'b1111_1111; //x->blank
        end
        else begin
            seg_en = 1'b0;
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
                5'b10000: seg_out=8'b0001_1100;     //U
                5'b10001: seg_out=8'b0000_1000;     //A
                5'b10010: seg_out=8'b0100_0011;     //o
                5'b10011: seg_out=8'b0001_1100;     //upper o
                5'b10100: seg_out=8'b0001_1100;     //b
                default: seg_out = 8'b1111_1111;    //no display
            endcase
        end        
    end
    
endmodule