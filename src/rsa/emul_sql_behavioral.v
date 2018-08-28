module emul_sql_behavioral(x,a,b,clock,enable,reset,ready,emul_a,emul_b,emul_x);
input [7:0] a,b;
input clock,reset,enable;
output reg [15:0] x;
input [15:0] emul_x;
output ready;
output reg [7:0] emul_a,emul_b;
reg [3:0]state,next_state;
reg ready;

parameter STATE_RESET                     =  0;
parameter STATE_TAKE_USER_INPUT           =  1;
parameter STATE_WAIT_FOR_EMUL_OUTPUT      =  2;
parameter STATE_TRANSFER_COMPUTED_PRODUCT =  3;

always @(*)begin
case (state)
    STATE_RESET:
    begin
        next_state = STATE_TAKE_USER_INPUT;
        ready = 0;
        x = 0;
    end
    STATE_TAKE_USER_INPUT:
        begin
            $display("\temul_sql >> STATE_TAKE_USER_INPUT");
            emul_a = a;
            emul_b = b;
            next_state = STATE_WAIT_FOR_EMUL_OUTPUT;
        end
    STATE_WAIT_FOR_EMUL_OUTPUT:
        begin
            $display("\temul_sql >> STATE_WAIT_FOR_EMUL_OUTPUT");
            next_state = STATE_TRANSFER_COMPUTED_PRODUCT;
        end
    STATE_TRANSFER_COMPUTED_PRODUCT:
        begin
            $display("\temul_sql >> STATE_TRANSFER_COMPUTED_PRODUCT");
            x = emul_x;
            ready = 1;
            next_state = STATE_TRANSFER_COMPUTED_PRODUCT;
        end
endcase // case
end

always @(posedge clock)begin
    if (reset)begin
        state <= STATE_RESET;
    end
    else if (enable) begin
        state <= next_state;
    end // reset
end // clock

endmodule

