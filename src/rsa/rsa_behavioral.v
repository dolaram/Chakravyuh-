module rsa_behavioral (result,e,d,y,clock,enable,reset,ready,
                emul_x,emul_a,emul_b,emul_en,emul_rst,emul_ready,
                modn_x,modn_ready,modn_a,modn_b,modn_en,modn_rst);

// Parameter definitions :
parameter DATA_WIDTH = 8;
parameter DATA_DOUBLE_WIDTH = 16;
parameter STATE_WIDTH = 5;

// State definitions :
parameter STATE_RESET                         = 0;
parameter STATE_TAKE_INPUT                    = 1;
parameter STATE_WAIT_ONE_CLOCK_CYCLE          = 2;
parameter STATE_PERFORM_OP_MUL                = 3;
parameter STATE_MUL_WAIT_FOR_RESET_READY      = 4;
parameter STATE_MUL_START_EXP                 = 5;
parameter STATE_MUL_WAIT_FOR_RESULT_READY     = 6;
parameter STATE_END_COMPUTATION               = 7;
parameter STATE_PERFORM_OP_MOD                = 8;
parameter STATE_MOD_WAIT_FOR_RESET_READY      = 9;
parameter STATE_MOD_START_EXP                 = 10;
parameter STATE_MOD_WAIT_FOR_RESULT_READY     = 11;
parameter STATE_PERFORM_EXPMODN               = 12;
parameter STATE_EXPMODN_NONTRIVIAL            = 13;

// Input / Output definitions :
output [DATA_WIDTH-1:0]result; 
//output [DATA_DOUBLE_WIDTH-1:0]result;
input [DATA_WIDTH-1:0]e,d,y;
input clock,reset,enable;
input [DATA_DOUBLE_WIDTH-1:0] emul_x;
input [DATA_WIDTH-1:0] modn_x;
input emul_ready,modn_ready;


// Register definitions
output reg [DATA_WIDTH-1:0]emul_a,emul_b,modn_b;
reg [DATA_WIDTH-1:0]result; 
output reg ready,emul_en,emul_rst,modn_en,modn_rst;
output reg [DATA_DOUBLE_WIDTH-1:0]modn_a;
reg [STATE_WIDTH-1:0] state;
reg [STATE_WIDTH-1:0] next_state;
reg [STATE_WIDTH-1:0] saved_state1; // For holding the saved state for 1 clk delay routine
reg [STATE_WIDTH-1:0] saved_state2; // For holding the saved state for multiplication routine
reg [STATE_WIDTH-1:0] saved_state3; // For holding the saved state for mod routine
reg [DATA_WIDTH-1:0]temp_e,temp_d,temp_y,temp_k;
reg [DATA_DOUBLE_WIDTH-1:0]temp_x;

always @(posedge clock)begin
    if (reset)begin
        state <= STATE_RESET;
    end
    else if (enable) begin
        state <= next_state;
    end // reset
end // clock

always @(*) begin
    case (state)
        STATE_RESET:
        begin
            saved_state1 = STATE_END_COMPUTATION; 
            saved_state2 = STATE_END_COMPUTATION; 
            saved_state3 = STATE_END_COMPUTATION; 
            result = 0;
            ready = 1'b0;
            $display("\t\trsa >> ready signal is %d inside reset routine",ready);
            next_state = STATE_TAKE_INPUT;
        end
        STATE_TAKE_INPUT: 
        begin
            $display("\trsa >> STATE_TAKE_INPUT");
            temp_e = e;
            temp_d = d;
            temp_y = y;
            temp_k = e;
            temp_x = temp_e; 
            next_state = STATE_PERFORM_EXPMODN;
        end
        STATE_PERFORM_EXPMODN:
        begin
            $display("\trsa >> STATE_PERFORM_EXPMODN");
            /* First, deal with trivial case :
             *    - d = 1
             *      &
             *        - e < y
             *          or
             *        - e >= y
             */
            if (temp_d == 1) begin
                $display("\trsa >> STATE_PERFORM_EXPMODN : Trivial case - (d = 1)");
                if (temp_e < temp_y) begin
                    $display("\trsa >> STATE_PERFORM_EXPMODN : Trivial case - (e < y)");
                    temp_x = temp_e; 
                    next_state = STATE_END_COMPUTATION;
                end // temp_e < temp_y
                else begin
                    $display("\trsa >> STATE_PERFORM_EXPMODN : Trivial case - (e >= y)");
                    temp_x = temp_e; 
                    saved_state3 = STATE_END_COMPUTATION;         
                    next_state = STATE_PERFORM_OP_MOD;
                end
            end // temp_d
            else begin
                    $display("\trsa >> STATE_PERFORM_EXPMODN : Non-trivial case : (d > 1)");
                    next_state = STATE_EXPMODN_NONTRIVIAL;
                    temp_x = temp_e;
            end // temp_d > 1
        end
        STATE_EXPMODN_NONTRIVIAL:
        begin
            $display("\trsa >> STATE_EXPMODN_NONTRIVIAL");
            if (temp_d > 1) begin
                if (temp_k == 0) begin
                    $display("\trsa >> Mod was 0, so taking a shortcut to end the computation");
                    next_state = STATE_END_COMPUTATION;
                end
                else begin
                    next_state = STATE_PERFORM_OP_MUL;
                    saved_state2 = STATE_PERFORM_OP_MOD;
                    saved_state3 = STATE_EXPMODN_NONTRIVIAL;
                    temp_d = temp_d-1;
                end
            end
            else begin
                temp_x = temp_k;
                next_state = STATE_END_COMPUTATION;
            end
        end
        STATE_PERFORM_OP_MUL:
        begin
            // First, reset emul_sql 
            $display("\trsa >> STATE_PERFORM_OP_MUL");
            emul_rst = 1;
            emul_en = 0;
            saved_state1 = STATE_MUL_WAIT_FOR_RESET_READY;
            next_state = STATE_WAIT_ONE_CLOCK_CYCLE;
        end
        STATE_WAIT_ONE_CLOCK_CYCLE:
        begin
            $display("\trsa >> STATE_WAIT_ONE_CLOCK_CYCLE");
            next_state = saved_state1;
        end
        STATE_MUL_WAIT_FOR_RESET_READY:
        begin
            $display("\trsa >> STATE_MUL_WAIT_FOR_RESET_READY");
            if (emul_ready == 1'b0) begin
                next_state = STATE_MUL_START_EXP;
                emul_a = temp_k;
                emul_b = temp_e;
                emul_rst = 0;
            end
            else begin
                next_state = STATE_MUL_WAIT_FOR_RESET_READY;
            end
        end
        STATE_MUL_START_EXP:
        begin
            $display("\trsa >> STATE_MUL_START_EXP");
            emul_en = 1; 
            next_state = STATE_MUL_WAIT_FOR_RESULT_READY;
        end
        STATE_MUL_WAIT_FOR_RESULT_READY:
        begin
            $display("\trsa >> STATE_MUL_WAIT_FOR_RESULT_READY");
            if (~emul_ready) begin
                next_state = STATE_MUL_WAIT_FOR_RESULT_READY;
            end
            else begin
                temp_x = emul_x; 
                next_state = saved_state2;
            end
        end
        STATE_PERFORM_OP_MOD:
        begin
            // First, reset modn 
            $display("\trsa >> STATE_PERFORM_OP_MOD");
            modn_rst = 1;
            modn_en = 0;
            saved_state1 = STATE_MOD_WAIT_FOR_RESET_READY;
            next_state = STATE_WAIT_ONE_CLOCK_CYCLE;
        end
        STATE_WAIT_ONE_CLOCK_CYCLE:
        begin
            $display("\trsa >> STATE_WAIT_ONE_CLOCK_CYCLE");
            next_state = saved_state1;
        end
        STATE_MOD_WAIT_FOR_RESET_READY:
        begin
            $display("\trsa >> STATE_MOD_WAIT_FOR_RESET_READY");
            if (modn_ready == 1'b0) begin
                next_state = STATE_MOD_START_EXP;
                modn_a = temp_x;
                modn_b = temp_y;
                modn_rst = 0;
            end
            else begin
                next_state = STATE_MOD_WAIT_FOR_RESET_READY;
            end
        end
        STATE_MOD_START_EXP:
        begin
            $display("\trsa >> STATE_MOD_START_EXP");
            modn_en = 1; 
            next_state = STATE_MOD_WAIT_FOR_RESULT_READY;
        end
        STATE_MOD_WAIT_FOR_RESULT_READY:
        begin
            $display("\trsa >> STATE_MOD_WAIT_FOR_RESULT_READY");
            if (~modn_ready) begin
                next_state = STATE_MOD_WAIT_FOR_RESULT_READY;
            end
            else begin
                temp_k = modn_x; 
                next_state = saved_state3;
            end
        end
        // End computation state - Final state
        STATE_END_COMPUTATION:
        begin
            $display("\trsa >> STATE_END_COMPUTATION");
            //result = temp_x;
            result = temp_k;
            ready = 1;
            next_state = STATE_END_COMPUTATION;
        end
    endcase
end

endmodule
