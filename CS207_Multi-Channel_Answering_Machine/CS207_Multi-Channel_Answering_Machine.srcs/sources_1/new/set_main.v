`timescale 1ns / 1ps

// the main entry point
module set_main(clk,
                rst_n,          //global reset
                setting_en,
                enter_btn,
                input_val,
                num_people,
                count_seconds,
                corrcet_point,
                mistake_point,
                cur_set
                );
    // input and output
    input clk,rst_n,setting_en,enter_btn;//ori switch
    input [5:0] input_val;//input the number to save as reg
    output reg [5:0] num_people,count_seconds,corrcet_point,mistake_point;
    output reg [1:0] cur_set;//0:without setting,1-set the number,2-set the countdown,3-set the add points,4-set the minus points

wire enter_btn_pos;    
edge_detect u(clk, setting_en,enter_btn,enter_btn_pos);    
    always @ (posedge clk, negedge rst_n) begin
        if(!rst_n)begin
            cur_set = 0;
            num_people = 0;
            count_seconds = 0;
            corrcet_point = 0;
            mistake_point = 0;
        end
        else
        if(enter_btn_pos)begin
        if (setting_en == 1) begin
            if (cur_set == 0) begin
                num_people = input_val;
                if (num_people>4 || num_people<2) begin
                    cur_set = 0;
                    end else begin
                    cur_set = cur_set + 1;
                end
                end else if (cur_set == 1) begin
                count_seconds = input_val;
                if (count_seconds<1) begin
                    cur_set = 1;
                    end else begin
                    cur_set = cur_set + 1;
                end
                end else if (cur_set == 2) begin
                corrcet_point = input_val;
                if (corrcet_point<1) begin
                    cur_set = 2;
                    end else begin
                    cur_set = cur_set + 1;
                end
                end else if (cur_set == 3) begin
                mistake_point = input_val;
//                if (mistake_point<1) begin
//                    cur_set = 3;
//                    end
            end
        end
        end
    end

endmodule