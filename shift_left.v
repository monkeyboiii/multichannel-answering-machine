module shift_left(
    input   clk,
            rst_n,
            si,
            en,
    output  reg [99:0] D
);
    always @(posedge en, negedge rst_n)
        if(!rst_n)
            D<=0;
        else if(en)begin
             D<={D[98:0],si};
        end
endmodule