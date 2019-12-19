`timescale 1ns / 1ps

module main(
    input   clk,
            rst_n,
            
    input   [5:0]input_val,     //setting mode    
            [1:0]judge,         //each round
    
    input   enter_btn,          //enter button, confirm
            next_stage,         //stage forward

    input   [3:0] press,        //player answer
    input   run_pause,          //count down run or pause
    input   rejudge,        
    
    output  buzz,               //beeper
            reg [3:0] press_led,//show who got the answer
            reg [7:0] seg_out,              
            reg [7:0] seg_en,   
                   
            reg [1:0] stage     //debug
                       
);

//------------------------------------------------------------------    
//parameters below


    
    
parameter  p1 = 3'b001,        //player number
            p2 = 3'b010,
            p3 = 3'b011,
            p4 = 3'b100,
            pd = 3'b000;        //default player


//reg [1:0] stage = 0;
reg [1:0]   cur_set;            //current setting mode
reg [5:0]   num_people,         //registers for setting saving
            count_seconds,
            correct_point,
            mistake_point;
            
                                
wire [7:0]  seg_out_buffer,     //wire seg tube connector for seg mode switching
            seg_en_buffer,  
            seg_out_setting,
            seg_en_setting,     
            seg_out_ctd,
            seg_en_ctd,
            seg_out_pl,
            seg_en_pl,
            seg_out_st,
            seg_en_st,
            seg_out_rejudge,
            seg_en_rejudge;


reg         buffer_en,          //enabler
            setting_en,                
            answer_en, 
            display_en, 
            judge_en,
            score_en,
            if_next_turn_en,
            next_en,
            final_en,
            check_en,
            rejudge_en;


reg [26:0]  if_answer_1 = 0,    //if player 1 answered question #<bit>
            if_answer_2 = 0,
            if_answer_3 = 0,
            if_answer_4 = 0;
reg [26:0]  score_1 = 0,        //if player 1 answered question #<bit> correctly
            score_2 = 0,
            score_3 = 0,
            score_4 = 0;
reg         pos_1,              //negative(0) or positive(1) score of player 1       
            pos_2,
            pos_3,
            pos_4;
reg [7:0]   total_1,            //total score of player 1
            total_2,            
            total_3,            
            total_4;            
            
reg         pos;                //positive or negative score for lht_num                           
reg [7:0]   lht_num;


reg         final;              //one player wins





//parameters above
//------------------------------------------------------------------
//stage change below




//next stage jumper
wire next_stage_pos;            
edge_detect next_stage_u(clk,rst_n,next_stage,next_stage_pos);

//state transition
always@(posedge clk, negedge rst_n) begin
    if(!rst_n || final)
        stage <= 0;
    else if(next_stage_pos)
        if(stage == 3)
            stage <= 2;
        else
            stage <= stage + 1;
end

//enabler update
always@(posedge clk, negedge rst_n) begin
    if(!rst_n)
        {setting_en, answer_en, judge_en}=3'b000;
    else
    case(stage)
        0: begin {setting_en, answer_en, judge_en} = {1'b0,1'b0,1'b0};end
        1: begin {setting_en, answer_en, judge_en} = {1'b1,1'b0,1'b0};end
        2: begin {setting_en, answer_en, judge_en} = {1'b0,1'b1,1'b0};end
        3: begin {setting_en, answer_en, judge_en} = {1'b0,1'b0,1'b1};end
    endcase
end

//seg tube stage change
always@(posedge clk) begin 
    if(rejudge_en) begin
        seg_out = seg_out_rejudge;
        seg_en = seg_en_rejudge;
    end
    else
    case(stage)
        0: begin 
            if(final) begin
                buffer_en = 0;
                seg_out=seg_out_st;
                seg_en=seg_en_st;
            end
            else begin
                buffer_en = 1;
                seg_out=seg_out_buffer;
                seg_en=seg_en_buffer;
            end
        end
        1: begin 
            buffer_en = 0;
            seg_out=seg_out_setting;
            seg_en=seg_en_setting;
        end
        2: begin 
            buffer_en = 0;
            seg_out=seg_out_ctd;
            seg_en=seg_en_ctd;
        end
        3: begin 
            buffer_en = 0;
            seg_out=seg_out_pl;
            seg_en=seg_en_pl;
        end
    endcase
end




//stage change above
//------------------------------------------------------------------
//buffer stage below




buffer_tube bt(clk,buffer_en,seg_out_buffer,seg_en_buffer);




//buffer stage above
//------------------------------------------------------------------
//setting stage below




wire [1:0]  wcur_set;             //wire connector for register setting             
wire [5:0]  wnum_people,          
            wcount_seconds,
            wcorrect_point,
            wmistake_point;

set_main set_main_u(clk,rst_n,setting_en,
                    enter_btn,input_val,
                    wnum_people,wcount_seconds,wcorrect_point,wmistake_point,
                    wcur_set);

setting_tube setting_tube_u(clk,setting_en,cur_set, input_val,seg_out_setting,seg_en_setting);




//setting stage above
//------------------------------------------------------------------
//count down/answer stage below


reg lock;
reg [2:0] get_chance;
reg [2:0] get_chance_lock;          //number of the player who answered

//activate or deactivate the lock
always@(posedge clk,negedge rst_n) begin
    if(!rst_n)
        lock=0;
    else if(!answer_en)
        lock=1;
    else
        lock= ~answer_en || press[0] || press[1] || press[2] || press[3];
end

//get the number of the player who answered
always@* begin
    if(!rst_n)
        get_chance=0;
    else case(press)
        1: get_chance = p1;
        2: get_chance = p2;
        4: get_chance = p3;
        8: get_chance = p4;
        default: get_chance = pd;
    endcase
end

//put in the answer
always@* begin
    if(!rst_n)
        get_chance_lock <= 3'b000;
    else if(lock)
        get_chance_lock <= get_chance_lock;
    else
        get_chance_lock <= get_chance;
end

//show the player who got the answer
always@(posedge clk, negedge rst_n) begin
    if(!rst_n)
        press_led = 4'b0000;
    else if(lock)
        case(get_chance_lock)
            p1:press_led = 4'b0001;
            p2:press_led = 4'b0010;
            p3:press_led = 4'b0100;
            p4:press_led = 4'b1000;
            default:press_led = 4'b0000;
        endcase
end

countdown_tube countdown_tube_u(clk,answer_en,count_seconds,run_pause,get_chance_lock,seg_out_ctd,seg_en_ctd,buzz);




//count down/answer stage above
//------------------------------------------------------------------
//judge stage below



reg         sa1_en,             //if player 1 answered
            sa2_en,
            sa3_en,
            sa4_en;
reg         ss1_en,             //if player 1 answered correctly
            ss2_en,
            ss3_en,
            ss4_en;
wire [26:0] wif_answer_1,       //wire answer for register score update
            wif_answer_2,
            wif_answer_3,
            wif_answer_4;
wire [26:0] wscore_1,           //wire score for register score update
            wscore_2,
            wscore_3,
            wscore_4;
wire        wpos_1,             //wire for positive or neagtive score forplayer 1
            wpos_2,
            wpos_3,
            wpos_4;
wire [7:0]  wtotal_1,           //wire for total score of player 1
            wtotal_2,
            wtotal_3,
            wtotal_4;


//left shift the score into answer and score of each player and calculate the respective current total score
shift_left score_shift_1(clk,rst_n,judge_en,sa1_en,ss1_en,correct_point,mistake_point,wif_answer_1,wscore_1,wtotal_1,wpos_1);
shift_left score_shift_2(clk,rst_n,judge_en,sa2_en,ss2_en,correct_point,mistake_point,wif_answer_2,wscore_2,wtotal_2,wpos_2);
shift_left score_shift_3(clk,rst_n,judge_en,sa3_en,ss3_en,correct_point,mistake_point,wif_answer_3,wscore_3,wtotal_3,wpos_3);
shift_left score_shift_4(clk,rst_n,judge_en,sa4_en,ss4_en,correct_point,mistake_point,wif_answer_4,wscore_4,wtotal_4,wpos_4);


//player tube display
always@(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
        display_en = 0;  
        pos = 1;
        lht_num = 0;     
        final = 0; 
    end
    else begin
        case(get_chance_lock)
        p1:begin
            {sa1_en,sa2_en,sa3_en,sa4_en} = {1'b1,1'b0,1'b0,1'b0};          
            case(judge)
                1:{ss1_en,ss2_en,ss3_en,ss4_en} = {1'b1,1'b0,1'b0,1'b0};
                2:{ss1_en,ss2_en,ss3_en,ss4_en} = {1'b0,1'b0,1'b0,1'b0};
                default: {ss1_en,ss2_en,ss3_en,ss4_en} = 4'b0000;
            endcase
        end
        p2:begin
            {sa1_en,sa2_en,sa3_en,sa4_en} = {1'b0,1'b1,1'b0,1'b0};  
            case(judge)
                1:{ss1_en,ss2_en,ss3_en,ss4_en} = {1'b0,1'b1,1'b0,1'b0};
                2:{ss1_en,ss2_en,ss3_en,ss4_en} = {1'b0,1'b0,1'b0,1'b0};
                default: {ss1_en,ss2_en,ss3_en,ss4_en} = 4'b0000;
            endcase
        end
        p3:begin
            {sa1_en,sa2_en,sa3_en,sa4_en} = {1'b0,1'b0,1'b1,1'b0};
            case(judge)
                1:{ss1_en,ss2_en,ss3_en,ss4_en} = {1'b0,1'b0,1'b1,1'b0};
                2:{ss1_en,ss2_en,ss3_en,ss4_en} = {1'b0,1'b0,1'b0,1'b0};
                default: {ss1_en,ss2_en,ss3_en,ss4_en} = 4'b0000;
            endcase
        end
        p4:begin
            {sa1_en,sa2_en,sa3_en,sa4_en} = {1'b0,1'b0,1'b0,1'b1};
            case(judge)
                1:{ss1_en,ss2_en,ss3_en,ss4_en} = {1'b0,1'b0,1'b0,1'b1};
                2:{ss1_en,ss2_en,ss3_en,ss4_en} = {1'b0,1'b0,1'b0,1'b0};
                default: {ss1_en,ss2_en,ss3_en,ss4_en} = 4'b0000;
            endcase
        end
        default:begin
                    {sa1_en,sa2_en,sa3_en,sa4_en} = {1'b0,1'b0,1'b0,1'b0};
                    {ss1_en,ss2_en,ss3_en,ss4_en} = {1'b0,1'b0,1'b0,1'b0};
                end   
        endcase
        case(get_chance_lock)
            p1: begin pos = pos_1; lht_num = total_1;end
            p2: begin pos = pos_2; lht_num = total_2;end
            p3: begin pos = pos_3; lht_num = total_3;end
            p4: begin pos = pos_4; lht_num = total_4;end
            default: begin pos = pos; lht_num = lht_num;end
        endcase 
        if(pos==1 && lht_num >= 10) begin
            display_en = 0;
            final = 1;
        end
        else begin
            if(judge_en)
                display_en = 1;
            else
                display_en = 0;
        end       
    end
end

player_tube player_tube_u(clk,display_en,get_chance_lock,pos,lht_num,seg_out_pl,seg_en_pl);




//judge stage above
//------------------------------------------------------------------
//winner scan stage below




scan_tube st(clk,final,num_people,
                get_chance_lock,lht_num,
                pos_1,total_1,
                pos_2,total_2,
                pos_3,total_3,
                pos_4,total_4,
                seg_out_st,seg_en_st);




//winner scan stage above
//------------------------------------------------------------------
//rejudge stage below




reg rejudge_pos;
reg [2:0]rejudge_player; 
reg [7:0] rejudge_score;

always@(posedge clk, negedge rst_n) begin
    if(rst_n && final) begin
        if(rejudge&& input_val < 28&& input_val > 0) begin
            case(press)            
            1: begin
                rejudge_player = 3'b001;
                if(if_answer_1[input_val - 1]) begin
                    if(score_1[input_val - 1]) begin
                        rejudge_score = correct_point;
                        rejudge_pos = 1;
                    end
                    else begin
                        rejudge_score = mistake_point;
                        rejudge_pos = 0;
                    end
                end
                else begin
                    rejudge_pos = 1;
                    rejudge_score = 0;
                end                
            end
            2: begin
                rejudge_player = 3'b010;
                if(if_answer_2[input_val - 1]) begin
                    if(score_2[input_val - 1]) begin
                        rejudge_score = correct_point;
                        rejudge_pos = 1;
                    end
                    else begin
                        rejudge_score = mistake_point;
                        rejudge_pos = 0;
                    end
                end
                else begin
                    rejudge_pos = 1;
                    rejudge_score = 0;
                end                
            end
            4: begin
                rejudge_player = 3'b011;
                if(if_answer_3[input_val - 1]) begin
                    if(score_3[input_val - 1]) begin
                        rejudge_score = correct_point;
                        rejudge_pos = 1;
                    end
                    else begin
                        rejudge_score = mistake_point;
                        rejudge_pos = 0;
                    end
                end
                else begin
                    rejudge_pos = 1;
                    rejudge_score = 0;
                end                
            end
            8: begin
                rejudge_player = 3'b100;
                if(if_answer_4[input_val - 1]) begin
                    if(score_4[input_val - 1]) begin
                        rejudge_score = correct_point;
                        rejudge_pos = 1;
                    end
                    else begin
                        rejudge_score = mistake_point;
                        rejudge_pos = 0;
                    end
                end
                else begin
                    rejudge_pos = 1;
                    rejudge_score = 0;
                end                
            end
            default: begin
                rejudge_player = 3'b000;
                rejudge_pos = 1;
                rejudge_score = 0;
            end
            endcase
            rejudge_en = 1;
        end
    end
    else begin
        rejudge_en = 0;
        rejudge_player = 3'b000;
        rejudge_pos = 1;
        rejudge_score = 0;
    end
end

rejudge_tube rj_tube(clk, rejudge_en,rejudge_player,rejudge_pos, rejudge_score,{2'b00, input_val}, seg_out_rejudge, seg_en_rejudge);




//rejudge stage above
//------------------------------------------------------------------
//regsiter sychronization below




always@(posedge clk,negedge rst_n)begin
    if(!rst_n)begin
        score_1 <= 0;
        score_2 <= 0;
        score_3 <= 0;
        score_4 <= 0;
        if_answer_1 <= 0;
        if_answer_2 <= 0;
        if_answer_3 <= 0;
        if_answer_4 <= 0;
        num_people<=0;
        count_seconds<=0;
        correct_point<=0;
        mistake_point<=0;
        cur_set<=0;
        total_1 <= 0;
        total_2 <= 0;
        total_3 <= 0;
        total_4 <= 0;
        pos_1 <= 1;
        pos_2<=1;
        pos_3<=1;
        pos_4<=1;
    end
    else begin
        score_1 <= wscore_1;
        score_2 <= wscore_2;
        score_3 <= wscore_3;
        score_4 <= wscore_4;
        if_answer_1 <= wif_answer_1;
        if_answer_2 <= wif_answer_2;
        if_answer_3 <= wif_answer_3;
        if_answer_4 <= wif_answer_4;
        num_people<=wnum_people;
        count_seconds<=wcount_seconds;
        correct_point<=wcorrect_point;
        mistake_point<=wmistake_point;
        cur_set<=wcur_set;
        total_1 <= wtotal_1;
        total_2 <= wtotal_2;
        total_3 <= wtotal_3;
        total_4 <= wtotal_4;
        pos_1 <= wpos_1;
        pos_2<=wpos_2;
        pos_3<=wpos_3;
        pos_4<=wpos_4;
    end
end




//regsiter sychronization above
//------------------------------------------------------------------

endmodule