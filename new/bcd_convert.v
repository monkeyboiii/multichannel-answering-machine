`timescale 1ns / 1ps

module bcd_convert(
    input [7:0] current,
    output reg [3:0] msb,
    output reg [3:0] lsb
    );
    
    integer i;
    always @(current)
    begin
        msb = 4'd0;
        lsb = 4'd0;
        for( i=7; i>=0 ;i=i-1)
        begin
            if(msb >=5)
                msb = msb+3;
            if(lsb >=5)
                lsb = lsb+3;        
            msb = msb <<1;
            msb [0] = lsb[3];
            lsb = lsb<<1;
            lsb[0] = current[i];
                
        end
    end

endmodule