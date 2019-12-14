`timescale 1ns / 1ps

module switch_mux(
    input in0,
    input in1,
    input in2,
    input in3,
    input [1:0] sel,
    output reg out
    );
    
    always @(in0 or in1 or in2 or in3 or sel)
        case(sel)
            2'b00: out=in0;
            2'b01: out=in1;
            2'b10: out=in2;
            2'b11: out=in3;
            default: out=2'b00;
    endcase
    
endmodule