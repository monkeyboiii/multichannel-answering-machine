`timescale 1ns / 1ps

module switch_decoder(
    input [1:0] in,
    output reg [3:0] out
    );
    
    always@*
    begin
        case(in)
            0: out=4'b0001;
            1: out=4'b0010;
            2: out=4'b0100;
            3: out=4'b1000;
        endcase    
    end
    
endmodule
