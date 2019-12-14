`timescale 1ns / 1ps

// the main entry point
module set_main(setting_en,
                enter_btn,
                input_val,
                /*
                seg_en,
                seg_out,
                speaker,
                alarm_light,
                output_light,
                */
                is_set_over,    //in-state varible
                num_people,
                count_seconds,
                corrcet_point,
                mistake_point);
    // input and output
    input setting_en,enter_btn;//ori switch
    
    input [5:0] input_val;//input the number to save as reg
    //output [7:0] seg_en, seg_out;
    //output speaker;
    //output [5:0] output_light;//output the input val via corr switch light
    //output reg alarm_light;
    output reg is_set_over;
    output reg [5:0] num_people, count_seconds,corrcet_point,mistake_point;
    //
    reg [2:0] cur_set = 0;//0:without setting,1-set the number,2-set the countdown,3-set the add points,4-set the minus points
    
    
    // state machine
    always @ (posedge enter_btn) begin
        if (setting_en == 1) begin
            pass
        end
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
            if (mistake_point<1) begin
                cur_set = 3;
                end else begin
                cur_set = cur_set + 1;
            end
            end else if (cur_set == 4) begin
            is_set_over = 1;
        end
    end
    
    /*
     //output state light，可忽略
     always @ (posedge clk) begin
     case (cur_set)
     0: begin clk_en = 1; sw_en = 0; al_en = 0; cd_en = 0; end
     1: begin clk_en = 0; sw_en = 1; al_en = 0; cd_en = 0; end
     2: begin clk_en = 0; sw_en = 0; al_en = 1; cd_en = 0; end
     3: begin clk_en = 0; sw_en = 0; al_en = 0; cd_en = 1; end
     endcase
     end
     */
    
    
endmodule
