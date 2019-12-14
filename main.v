`timescale 1ns / 1ps

module main(
    input   clk,
            rst_n,
            [6:0] people,
            [5:0] timekeeping,
            [1:0]judge,
            start,
            check,
            each_score,
            next_stage,
            [3:0] press,
            
    output  buzz,
            [7:0] screen  
);
parameter p1 = 3'b001, p2 = 3'b010, p3 = 3'b011, p4 = 3'b100, pd = 3'b000;
reg [2:0] stage = 0;
reg setting_en, answer_en, judge_en, score_en, display_en, if_next_turn_en, next_en, final_en, check_en; 
reg [99:0] score_1 = 0;
reg [99:0] score_2 = 0;
reg [99:0] score_3 = 0;
reg [99:0] score_4 = 0;
reg [99:0] if_answer_1 = 0;
reg [99:0] if_answer_2 = 0;
reg [99:0] if_answer_3 = 0;
reg [99:0] if_answer_4 = 0;
reg go_on = 0;

wire next_stage_pos;
edge_detect next_stage_u(clk,rst_n,next_stage,next_stage_pos);
wire next_en_pos;
edge_detect next_en_u(clk,rst_n,next_en,next_en_pos);

always@(posedge clk, negedge rst_n)begin
    if(!rst_n || next_en_pos)stage <= 0;
    else if(next_en_pos) begin
        if(stage == 6) stage <= 1;
        else stage <= stage + 1;
    end
end


always@(posedge clk, negedge rst_n) begin
    case(stage)
        0: begin {setting_en, answer_en, judge_en, display_en, if_next_turn_en} = {1'b1,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0};end
        1: begin {setting_en, answer_en, judge_en, display_en, if_next_turn_en} = {1'b0,1'b1,1'b0,1'b0,1'b0,1'b0,1'b0};end
        2: begin {setting_en, answer_en, judge_en, display_en, if_next_turn_en} = {1'b0,1'b0,1'b1,1'b0,1'b0,1'b0,1'b0};end
        3: begin {setting_en, answer_en, judge_en, display_en, if_next_turn_en} = {1'b0,1'b0,1'b0,1'b1,1'b0,1'b0,1'b0};end
        4: begin {setting_en, answer_en, judge_en, display_en, if_next_turn_en} = {1'b0,1'b0,1'b0,1'b0,1'b1,1'b0,1'b0};end
        5: begin {setting_en, answer_en, judge_en, display_en, if_next_turn_en} = {1'b0,1'b0,1'b0,1'b0,1'b0,1'b1,1'b0};end
        6: begin {setting_en, answer_en, judge_en, display_en, if_next_turn_en} = {1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b1};end        
    endcase
end

//抢答
wire lock;
assign lock = ~answer_en||((~press[0])&(~press[1])&(~press[2])&(~press[3]));
reg [2:0] get_chance;
reg [2:0] get_chance_lock;
always@* begin
    case(press)
    1: get_chance = p1;
    2: get_chance = p2;
    4: get_chance = p3;
    8: get_chance = p4;
    default: get_chance = pd;
    endcase
end 

//抢答锁存
always@* begin
    if(!rst_n) get_chance_lock <= 3'b000;
    else if(lock)  get_chance_lock <= get_chance_lock;
    else get_chance_lock <= get_chance;
end

reg ss1_en,ss2_en,ss3_en,ss4_en;
reg sa1_en,sa2_en,sa3_en,sa4_en;

//更新答案是否正确
shift_left score_shift_1(clk,rst_n,ss1_en,score_1);
shift_left score_shift_2(clk,rst_n,ss2_en,score_2);
shift_left score_shift_3(clk,rst_n,ss3_en,score_3);
shift_left score_shift_4(clk,rst_n,ss4_en,score_4);

//更新是否回答
shift_left answer_shift_1(clk, rst_n, sa1_en, if_answer_1);
shift_left answer_shift_2(clk, rst_n, sa2_en, if_answer_2);
shift_left answer_shift_3(clk, rst_n, sa3_en, if_answer_3);
shift_left answer_shift_4(clk, rst_n, sa4_en, if_answer_4);


wire judge_en_pos;
edge_detect judge_en_u(clk,rst_n,judge_en,judge_en_pos);

//判题
always@(posedge clk, negedge rst_n)begin
    if(!rst_n)begin
        score_1<=0;score_2<=0;score_3<=0;score_4<=0;
        if_answer_1<=0;if_answer_2<=0;if_answer_3<=0;if_answer_4<=0;
    end
    else if(judge_en_pos)begin
        case(get_chance_lock)
        p1:begin
            {sa1_en,sa2_en,sa3_en,sa4_en} = {1'b1,1'b0,1'b0,1'b0};          
            case(judge)
                1:{ss1_en,ss2_en,ss3_en,ss4_en} = {1'b1,1'b0,1'b0,1'b0};
                2:{ss1_en,ss2_en,ss3_en,ss4_en} = {1'b0,1'b0,1'b0,1'b0};
            endcase
        end
        p2:begin
            {sa1_en,sa2_en,sa3_en,sa4_en} = {1'b0,1'b1,1'b0,1'b0};  
            case(judge)
                1:{ss1_en,ss2_en,ss3_en,ss4_en} = {1'b0,1'b1,1'b0,1'b0};
                2:{ss1_en,ss2_en,ss3_en,ss4_en} = {1'b0,1'b0,1'b0,1'b0};
            endcase
        end
        p3:begin
            {sa1_en,sa2_en,sa3_en,sa4_en} = {1'b0,1'b0,1'b1,1'b0};
            case(judge)
                1:{ss1_en,ss2_en,ss3_en,ss4_en} = {1'b0,1'b0,1'b1,1'b0};
                2:{ss1_en,ss2_en,ss3_en,ss4_en} = {1'b0,1'b0,1'b0,1'b0};
            endcase
        end
        p4:begin
            {sa1_en,sa2_en,sa3_en,sa4_en} = {1'b0,1'b0,1'b0,1'b1};
            case(judge)
                1:{ss1_en,ss2_en,ss3_en,ss4_en} = {1'b0,1'b0,1'b0,1'b1};
                2:{ss1_en,ss2_en,ss3_en,ss4_en} = {1'b0,1'b0,1'b0,1'b0};
            endcase
        end
        default:begin
                    {sa1_en,sa2_en,sa3_en,sa4_en} = {1'b0,1'b0,1'b0,1'b0};
                    {ss1_en,ss2_en,ss3_en,ss4_en} = {1'b0,1'b0,1'b0,1'b0};
                end   
        endcase
    end
end


wire if_next_turn_en_pos;
edge_detect if_next_turn_en_u(clk,rst_n,if_next_turn_en,if_next_turn_en_pos);

//决出胜负
always@(negedge rst_n, posedge clk)begin
    if(!rst_n)begin
        next_en <= 0; final_en <= 0;
    end
    else if(if_next_turn_en_pos) begin
        if(go_on) begin
            next_en <= 1;
            final_en <= 0;
        end
        else begin
            final_en <= 1;
            next_en <= 0;
        end
    end
end


setting setting_u(each_score, clk, people, timekeeping, setting_en);
beeper beeper_u(clk, answer_en,buzz);
timekeeper timekeeper_u(clk, rst_n, answer_en, screen);
display display_u(clk,display_en, people, score_1, score_2, score_3, score_4,if_answer_1,if_answer_2,if_answer_3,if_answer_4,screen);
result result_u(clk, final_en, people, score_1, score_2, score_3, score_4,if_answer_1,if_answer_2,if_answer_3,if_answer_4,screen);

endmodule

