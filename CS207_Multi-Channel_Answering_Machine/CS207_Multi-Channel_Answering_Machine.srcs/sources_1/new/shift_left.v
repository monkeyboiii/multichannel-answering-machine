module shift_left(
    input   clk,
            rst_n,
            judge_en,
            sa_en,
            ss_en,
            [7:0]corrcet_point,
            [7:0]mistake_point,
    output reg [26:0]wif_answer,
    output reg [26:0]wscore,
    output reg [7:0]wtotal,
    output reg pos
);
wire judge_en_pos;
edge_detect u(clk,rst_n,judge_en,judge_en_pos);

always@(posedge clk, negedge rst_n)begin
    if(!rst_n)wif_answer <= 0;
    else if(judge_en_pos)begin
        wif_answer <= {wif_answer[25:0],sa_en};
    end
end

always@(posedge clk, negedge rst_n)begin
    if(!rst_n)wscore <= 0;
    else if(judge_en_pos)begin
        wscore <= {wscore[25:0],ss_en};
    end
end

always@(posedge clk, negedge rst_n)begin
    if(!rst_n)wtotal <= 0;
    else if(judge_en_pos)begin
        if(sa_en)begin
            if(ss_en)begin
                if(pos)begin
                    wtotal <= wtotal + corrcet_point;
                end
                else begin
                    if(wtotal > corrcet_point)begin
                        wtotal <= wtotal - corrcet_point;
                    end
                    else begin
                        pos <= ~pos;
                        wtotal <= corrcet_point - wtotal;
                    end
                end             
            end
            else begin
                if(pos)begin
                    if(wtotal > mistake_point)begin
                        wtotal <= wtotal - mistake_point;
                    end
                    else begin
                        pos <= ~pos;
                        wtotal <= mistake_point - wtotal;
                    end        
                end
                else begin
                    wtotal <= wtotal + mistake_point;            
                end
            end
        end
        
    end
end

endmodule