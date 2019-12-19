`timescale 1ns / 1ps

module scan_tube(
    input clk,
    input rst_n,
    input [5:0] num_people,            //number of people
    input [2:0] winner,                //winner
    input [7:0] score,                //score of winner
    input       pos_1,
    input [7:0] total_1,
    input       pos_2,
    input [7:0] total_2,
    input       pos_3,
    input [7:0] total_3,
    input       pos_4,
    input [7:0] total_4,
    output reg [7:0] seg_out,
    output reg [7:0] seg_en
    );
    
    
    wire [3:0] msb_s;
    wire [3:0] lsb_s;
    bcd_convert bc(score,msb_s,lsb_s);
    wire [3:0] msb_1;
    wire [3:0] lsb_1;
    bcd_convert bc1(total_1,msb_1,lsb_1);
    wire [3:0] msb_2;
    wire [3:0] lsb_2;
    bcd_convert bc2(total_2,msb_2,lsb_2);
    wire [3:0] msb_3;
    wire [3:0] lsb_3;
    bcd_convert bc3(total_3,msb_3,lsb_3);
    wire [3:0] msb_4;
    wire [3:0] lsb_4;
    bcd_convert bc4(total_4,msb_4,lsb_4);
  
  
    wire clkout;
    frequency_divider #(2) fd(clk,rst_n,clkout);    //2 bits scan per seconds
    reg [4:0] scan_cnt;
    reg [2:0] now_playing; 
    
    
    always@(posedge clkout or negedge rst_n)
    if(!rst_n) begin
        scan_cnt<=0;
        now_playing<=num_people;
    end
    else if(scan_cnt<15)
        if(now_playing==0 && scan_cnt==8)
            scan_cnt<=scan_cnt;
        else
            scan_cnt<=scan_cnt+1;    //stay or traverse
    else if(scan_cnt==15 && now_playing>0) begin
        scan_cnt<=0;
        now_playing<=now_playing-1;
    end
    
    reg [2:0] player;
    reg       pos;
    reg [3:0] msb;
    reg [3:0] lsb;
    
    always@(posedge clk or negedge rst_n)
    if(!rst_n) begin
        player=3'b000;
    end
    else 
        case(now_playing)   
            0:begin player=winner;  pos=1 ;msb=msb_s;lsb=lsb_s; end
            1:begin player=3'b001;pos=pos_1;msb=msb_1;lsb=lsb_1; end
            2:begin player=3'b010;pos=pos_2;msb=msb_2;lsb=lsb_2; end
            3:begin player=3'b011;pos=pos_3;msb=msb_3;lsb=lsb_3; end
            4:begin player=3'b100;pos=pos_4;msb=msb_4;lsb=lsb_4; end
            default:begin player=3'b000;msb=4'h0;lsb=4'h0; end
        endcase
    
    
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
                        0:begin seg_en = 8'b1111_1110;
                            case(player)
                                0:sw=4'hf;
                                default:sw = {1'b0,player};
                        endcase
                        end
                        1:begin seg_en = 8'b1111_1101; sw = 4'hb; end
                        2:begin seg_en = 8'b1111_1011; sw = 4'ha; end
                        default: seg_en = 8'b1111_1111;
                    endcase
                end
                4:begin 
                    case(tube_count)
                        1:begin seg_en = 8'b1111_1101;
                            case(player)
                                0:sw=4'hf;
                                default:sw = {1'b0,player};
                            endcase
                        end
                        2:begin seg_en = 8'b1111_1011; sw = 4'hb; end
                        3:begin seg_en = 8'b1111_0111; sw = 4'ha; end
                        default: seg_en = 8'b1111_1111;
                    endcase
                end
                5:begin 
                    case(tube_count)
                        2:begin seg_en = 8'b1111_1011;
                            case(player)
                                0:sw=4'hf;
                                default:sw = {1'b0,player};
                            endcase
                        end
                        3:begin seg_en = 8'b1111_0111; sw = 4'hb; end
                        4:begin seg_en = 8'b1110_1111; sw = 4'ha; end
                        default: seg_en = 8'b1111_1111;
                    endcase
                end
                6:begin 
                    case(tube_count)
                        0:if(!pos) begin
                            seg_en = 8'b1111_1110;
                            sw=4'hf;
                        end 
                        3:begin seg_en = 8'b1111_0111; 
                            case(player)
                                0:sw=4'hf;
                                default:sw = {1'b0,player};
                            endcase
                        end
                        4:begin seg_en = 8'b1110_1111; sw = 4'hb; end
                        5:begin seg_en = 8'b1101_1111; sw = 4'ha; end
                        default: seg_en = 8'b1111_1111;
                    endcase
                end
                7:begin 
                    case(tube_count)
                        0:begin seg_en = 8'b1111_1110; sw = msb; end
                        1:if(!pos) begin
                            seg_en = 8'b1111_1101;
                            sw=4'hf;
                        end
                        4:begin seg_en = 8'b1110_1111; 
                            case(player)
                                0:sw=4'hf;
                                default:sw = {1'b0,player};
                            endcase                        
                        end
                        5:begin seg_en = 8'b1101_1111; sw = 4'hb; end
                        6:begin seg_en = 8'b1011_1111; sw = 4'ha; end
                        default: seg_en = 8'b1111_1111;
                    endcase
                end
                8:begin
                    case(tube_count)
                        0:begin seg_en = 8'b1111_1110; sw = lsb; end
                        1:begin seg_en = 8'b1111_1101; sw = msb; end
                        2:if(!pos) begin
                            seg_en = 8'b1111_1011;
                            sw=4'hf;
                        end
                        5:begin seg_en = 8'b1101_1111; 
                            case(player)
                                0:sw=4'hf;
                                default:sw = {1'b0,player};
                            endcase
                        end
                        6:begin seg_en = 8'b1011_1111; sw = 4'hb; end
                        7:begin seg_en = 8'b0111_1111; sw = 4'ha; end
                        default: seg_en = 8'b1111_1111;
                    endcase
                end
                9:begin
                    case(tube_count)
                        1:begin seg_en = 8'b1111_1101; sw = lsb; end
                        2:begin seg_en = 8'b1111_1011; sw = msb; end
                        3:if(!pos) begin
                            seg_en = 8'b1111_0111;
                            sw=4'hf;
                        end
                        6:begin seg_en = 8'b1011_1111; 
                            case(player)
                                0:sw=4'hf;
                                default:sw = {1'b0,player};
                            endcase
                        end
                        7:begin seg_en = 8'b0111_1111; sw = 4'hb; end
                        default: seg_en = 8'b1111_1111;
                    endcase
                end
                10:begin
                    case(tube_count)
                        2:begin seg_en = 8'b1111_1011; sw = lsb; end
                        3:begin seg_en = 8'b1111_0111; sw = msb; end
                        4:if(!pos) begin
                            seg_en = 8'b1110_1111;
                            sw=4'hf;
                        end
                        7:begin seg_en = 8'b0111_1111; 
                            case(player)
                                0:sw=4'hf;
                                default:sw = {1'b0,player};
                            endcase
                        end
                        default: seg_en = 8'b1111_1111;
                    endcase
                end
                11:begin
                    case(tube_count)
                        3:begin seg_en = 8'b1111_0111; sw = lsb; end
                        4:begin seg_en = 8'b1110_1111; sw = msb; end
                        5:if(!pos) begin
                            seg_en = 8'b1101_1111;
                            sw=4'hf;
                        end
                        default: seg_en = 8'b1111_1111;
                    endcase
                end
                12:begin
                    case(tube_count)
                        4:begin seg_en = 8'b1110_1111; sw = lsb; end
                        5:begin seg_en = 8'b1101_1111; sw = msb; end
                        6:if(!pos) begin
                            seg_en = 8'b1011_1111;
                            sw=4'hf;
                        end
                        default: seg_en = 8'b1111_1111;
                    endcase
                end
                13:begin
                    case(tube_count)
                        5:begin seg_en = 8'b1101_1111; sw = lsb; end
                        6:begin seg_en = 8'b1011_1111; sw = msb; end
                        7:if(!pos) begin
                            seg_en = 8'b0111_1111;
                            sw=4'hf;
                        end
                        default: seg_en = 8'b1111_1111;
                    endcase
                end
                14:begin
                    case(tube_count)
                        6:begin seg_en = 8'b1011_1111; sw = lsb; end
                        7:begin seg_en = 8'b0111_1111; sw = msb; end
                        default: seg_en = 8'b1111_1111;
                    endcase
                end
                15:begin
                    case(tube_count)
                        7:begin seg_en = 8'b0111_1111; sw = lsb; end
                        default: seg_en = 8'b1111_1111;
                    endcase
                end
                default: seg_en = 8'b1111_1111;
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
        4'hf: seg_out=8'b1011_1111;         //-
        default: seg_out = 8'b1111_1111;    //no display
    endcase
    end
    
endmodule