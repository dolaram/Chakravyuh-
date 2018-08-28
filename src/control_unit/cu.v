/* =============================================================
 *
 *                          CHAKRAVYUH                          
 *                          ~~~~~~~~~~
 * 
 * Filename : cu.v
 * Purpose  : Control Unit implementation
 *
 * ============================================================= */

module cu( clock,reset,enable,opcode,datain,addr,
           rsa_dataout,rsa_ready,mem_dataout,mem_ready,
           dataout,status,cu_ready,
           rsa_datain,rsa_modulusin,rsa_keyin,mem_datain,mem_addr,
           rsa_en,rsa_rst,mem_en,mem_rst,mem_op
          );
`include "constants.vh"

/* ============================================================= */


/* =============================== */
/* Input / Output Line definitions */
/* =============================== */

/* Input Lines */

/* Blackbox inputs: */
input clock;
input enable;
input reset;
input [OPCODE_WIDTH-1:0]opcode;
input [DATA_WIDTH-1:0]datain;
input [ADDR_WIDTH-1:0]addr;

/* Inputs from other modules */
input [DATA_WIDTH-1:0]rsa_dataout;
input rsa_ready;
input [DATA_WIDTH-1:0]mem_dataout;
input mem_ready;

/* Output Lines */          

/* Blackbox outputs */
output [DATA_WIDTH-1:0]dataout;
output [STATUS_WIDTH-1:0]status;
output cu_ready;

/* Outputs to other modules */
output [DATA_WIDTH-1:0]rsa_datain;
output [DATA_WIDTH-1:0]rsa_modulusin;
output [DATA_WIDTH-1:0]rsa_keyin;
output [DATA_WIDTH-1:0]mem_datain;
output [MEMORY_ADDR_WIDTH-1:0]mem_addr;
output rsa_en,rsa_rst;
output mem_en;
output mem_rst,mem_op;

/* Register declarations for output lines */
reg [DATA_WIDTH-1:0]dataout;
reg [DATA_WIDTH-1:0]temp_rsa_buffer;
reg [STATUS_WIDTH-1:0]status;
reg [DATA_WIDTH-1:0] rsa_datain, rsa_modulusin, rsa_keyin, mem_datain;
reg [MEMORY_ADDR_WIDTH-1:0]mem_addr;
reg rsa_en,rsa_rst,mem_en,mem_rst,mem_op,temp_mem_op;
reg cu_ready;

reg rsa_op;

/* Miscellaneous registers */
reg cpu_authenticated;
reg [NONCE_COUNTER_SIZE-1:0] nonce;
reg [NONCE_COUNTER_SIZE-1:0] selected_nonce;

/* ============================================================= */

/* =============================== */
/* Temporary register declarations */
/* =============================== */

reg [STATE_WIDTH-1:0]state;        // State machine variable
reg [STATE_WIDTH-1:0]next_state;   // Next State machine variable
reg [STATE_WIDTH-1:0]restore_state;// State machine variable
reg ret;                           // Holds return value for each operation
reg [DATA_WIDTH-1:0]temp_datain;
reg [OPCODE_WIDTH-1:0]temp_opcode;
reg [ADDR_WIDTH-1:0]temp_addr;

/* ============================================================= */

/* ====================== */
/* Logic code starts here */
/* ====================== */

always @(posedge clock)begin
    if (reset)begin
        state <= STATE_RESET;
    end // reset
    else if (enable) begin
        state <= next_state;
    end // enable
    else begin
        if (~cpu_authenticated) begin
            /* If authentication was not performed earlier,
             * restore the next logical state in the authentication
             * state machine
             */
            cu_ready <= 1'b0;
            state <= restore_state;
        end // ~cpu_authenticated
        else begin
            /* If authentication was already done once before :
             * We shall make the state machine ready for the next operation
             * without necessitating authentication all over again
             */
            cu_ready <= 1'b0;
            state <= STATE_UI_TAKE_USER_INPUT;
            //$display("cu >> Idle, current state is %d",state);
        end // cpu_authenticated
    end // ~enable
end // clock

always @(*) begin

    //$display("cu >> enable is %d, cu_ready is %d, state is %d",enable,cu_ready,state);

    /* Our processor state machine starts here,
     * it kicks off only when enable is set high */

    case (state)

    /* Authentication state machine */
        STATE_RESET:
            begin
                restore_state = STATE_START_AUTHENTICATION; 
                cu_ready = 0;
                mem_en = 0;
                rsa_en = 0;
                cpu_authenticated = 1'b0;
                nonce = NONCE_RANDOM_VALUE;
                selected_nonce = 0;
                temp_rsa_buffer = 0;
                dataout = 0;
                status = OP_SUCCESS;
                next_state = STATE_START_AUTHENTICATION;
            end
        STATE_START_AUTHENTICATION:
            begin
                $display("\tcu >> STATE_START_AUTHENTICATION");
                temp_opcode = opcode;
                cu_ready = 1'b0;
                next_state = STATE_VERIFY_AUTH_OPCODE;
            end
            STATE_VERIFY_AUTH_OPCODE:
            begin
                $display("\tcu >> STATE_VERIFY_AUTH_OPCODE");
                if (opcode == OPCODE_AUTH_START) begin
                    $display("\tcu >> STATE_VERIFY_AUTH_OPCODE - Authentication routine initialized successfully");
                    $display("\tcu >> STATE_VERIFY_AUTH_OPCODE - Sending challenge nonce %d", nonce);
                    dataout = nonce;
                    selected_nonce = nonce;
                    next_state = STATE_AUTH_SET_CU_READY;
                end
                else begin
                    /* Hacker alert !! Stop everything !!!*/
                    $display("\tcu >> STATE_VERIFY_AUTH_OPCODE - Invalid opcode, expected %d", OPCODE_AUTH_START);
                    cu_ready = 1'b1;
                    next_state = STATE_END_OPERATION;
                end
            end
            STATE_AUTH_SET_CU_READY:
            begin
                next_state = STATE_GET_ENCRYPTED_NONCE;
                cu_ready = 1'b1;
                restore_state = STATE_GET_ENCRYPTED_NONCE;
            end
            STATE_GET_ENCRYPTED_NONCE:
            begin
                $display("\tcu >> STATE_GET_ENCRYPTED_NONCE");
                temp_datain = datain;
                next_state = STATE_DECRYPT_ENCRYPTED_NONCE;
            end
            STATE_DECRYPT_ENCRYPTED_NONCE:
            begin
                $display("\tcu >> STATE_DECRYPT_ENCRYPTED_NONCE");
                restore_state = STATE_VERIFY_DECRYPTED_NONCE; 
                next_state = STATE_PERFORM_OP_RSA;
                rsa_op = DEC;
            end
            STATE_VERIFY_DECRYPTED_NONCE:
            begin
                $display("\tcu >> STATE_VERIFY_DECRYPTED_NONCE");
                if (dataout == selected_nonce) begin
                    $display("\tcu >> STATE_VERIFY_DECRYPTED_NONCE - Decrypted nonce matches the original one !");
                    $display("\tcu >> STATE_VERIFY_DECRYPTED_NONCE - Authentication successful !");
                    cpu_authenticated = 1;
                    cu_ready = 1;
                    next_state = STATE_UI_TAKE_USER_INPUT;
                end
                else begin
                    /* Hacker alert !! Stop everything !! */
                    $display("\tcu >> STATE_VERIFY_DECRYPTED_NONCE - Decrypted nonce doesn't match the original one !");
                    $display("\tcu >> STATE_VERIFY_DECRYPTED_NONCE - ALARM ! ALARM ! HACKER ON BOARD !! :D ");
                    next_state = STATE_END_OPERATION;
                    cu_ready = 1;
                end
            end

        /* OPCode processing state machine (post authentication) */
        /* Grab user input & send it to next state for validation */
            STATE_UI_TAKE_USER_INPUT:
            begin
                $display("\tcu >> STATE_UI_TAKE_USER_INPUT : Taking user input");
                temp_datain = datain; 
                temp_opcode = opcode;
                temp_addr = addr;
                cu_ready = 1'b0;
                next_state = STATE_UI_VALIDATE_USER_INPUT;
            end

        /* Validate user input & somersault if erroneous, else
         * proceed to next state  */
        STATE_UI_VALIDATE_USER_INPUT:
            begin
                $display("\tcu >> STATE_UI_VALIDATE_USER_INPUT");
                case (temp_opcode)
                    OPCODE_MEM_READ:
                        begin
                            $display("\tcu >> STATE_UI_VALIDATE_USER_INPUT : Memory read operation parsed");
                            temp_mem_op = RD;
                            next_state = STATE_PERFORM_OP_MEM;
                            rsa_op = DEC;
                            restore_state = STATE_PERFORM_OP_RSA;
                        end
                    OPCODE_MEM_WRITE:
                        begin
                            $display("\tcu >> STATE_UI_VALIDATE_USER_INPUT : Memory write operation parsed");
                            temp_mem_op = WR;
                            next_state = STATE_PERFORM_OP_RSA;
                            rsa_op = ENC;
                            restore_state = STATE_PERFORM_OP_MEM;
                        end
                    OPCODE_RSA_ENC:
                        begin
                            $display("\tcu >> OPCODE_RSA_ENC");
                            next_state = STATE_PERFORM_OP_RSA;
                            rsa_op = ENC;
                            restore_state = STATE_END_OPERATION;
                        end
                    OPCODE_RSA_DEC:
                        begin
                            $display("\tcu >> OPCODE_RSA_DEC");
                            next_state = STATE_PERFORM_OP_RSA;
                            rsa_op = DEC;
                            restore_state = STATE_END_OPERATION;
                        end
                    default:
                        begin
                            $display("\tcu >> STATE_UI_VALIDATE_USER_INPUT : Invalid operation parsed");
                            next_state = STATE_END_OPERATION;
                            status = OP_INVALID_OPCODE;
                            /* We wish to be hack-proof, so if invalid
                             * opcode sensed; simply don't allow any
                             * operation to proceed. The hacker will be
                             * forced to do a reset and perform
                             * authentication all over again.
                             */
                            cu_ready = 1;
                        end
                endcase
            end
        STATE_PERFORM_OP_MEM:
            begin
                $display("\tcu >> STATE_PERFORM_OP_MEM");
                next_state = STATE_MEM_RESET_AND_LOAD_INPUTS;
            end
        STATE_MEM_RESET_AND_LOAD_INPUTS:
            begin
                $display("\tcu >> STATE_MEM_RESET_AND_LOAD_INPUTS");
                mem_rst = 1;
                mem_en = 0;
                next_state = STATE_LOADIP_AFTER_MEM_READY;
            end
        STATE_LOADIP_AFTER_MEM_READY:
            begin
                mem_rst = 0;
                $display("\tcu >> STATE_LOADIP_AFTER_MEM_READY");
                if (mem_ready == 1'b0) begin
                    $display("\tcu >> STATE_LOADIP_AFTER_MEM_READY : RSA input is %d", temp_rsa_buffer);
                    mem_datain = temp_rsa_buffer;
                    mem_addr = temp_addr;
                    mem_op = temp_mem_op;
                    next_state = STATE_MEM_ENABLE;
                end
                else begin
                    next_state = STATE_LOADIP_AFTER_MEM_READY;
                end
            end
        STATE_MEM_ENABLE:
            begin
                $display("\tcu >> STATE_MEM_ENABLE");
                mem_en = 1; 
                next_state = STATE_MEM_WAIT_FOR_RESULT;
            end
        STATE_MEM_WAIT_FOR_RESULT:
            begin
                $display("\tcu >> STATE_MEM_WAIT_FOR_RESULT");
                if (mem_ready) begin
                    if (temp_mem_op == RD) begin
                        $display("\tcu >> STATE_MEM_WAIT_FOR_RESULT : Read %d from memory", mem_dataout);
                        temp_rsa_buffer = mem_dataout; 
                        next_state = restore_state;
                    end
                    else begin
                        next_state = STATE_END_OPERATION;
                    end
                    status = OP_SUCCESS;
                end
                else begin
                    next_state = STATE_MEM_WAIT_FOR_RESULT;
                end
            end
        STATE_PERFORM_OP_RSA:
            begin
                $display("\tcu >> STATE_PERFORM_OP_RSA");
                next_state = STATE_RSA_RESET_AND_LOAD_INPUTS;
            end
        STATE_RSA_RESET_AND_LOAD_INPUTS:
            begin
                $display("\tcu >> STATE_RSA_RESET_AND_LOAD_INPUTS");
                rsa_rst = 1;
                rsa_en = 0;
                next_state = STATE_LOADIP_AFTER_RSA_READY;
            end
        STATE_LOADIP_AFTER_RSA_READY:
            begin
                rsa_rst = 1;
                $display("\tcu >> STATE_LOADIP_AFTER_RSA_READY,rsa_ready is %d",rsa_ready);
                if (rsa_ready == 1'b0) begin
                    rsa_rst = 0;
                    if (temp_opcode == OPCODE_MEM_READ) begin
                        rsa_datain = temp_rsa_buffer;
                    end
                    else begin
                        rsa_datain = temp_datain;
                    end
                    rsa_modulusin = MOD1;
                    if (rsa_op == ENC) begin
                        rsa_keyin = PUBLIC_KEY1;
                    end
                    else begin
                        rsa_keyin = PRIVATE_KEY1;
                    end
                    next_state = STATE_RSA_ENABLE;
                end
                else begin
                    next_state = STATE_LOADIP_AFTER_RSA_READY;
                end
            end
        STATE_RSA_ENABLE:
            begin
                $display("\tcu >> STATE_RSA_ENABLE");
                rsa_en = 1; 
                next_state = STATE_RSA_WAIT_FOR_RESULT;
            end
        STATE_RSA_WAIT_FOR_RESULT:
            begin
                $display("\tcu >> STATE_RSA_WAIT_FOR_RESULT");
                if (rsa_ready) begin
                    if (temp_opcode == OPCODE_MEM_WRITE) begin
                        $display("\tcu >> STATE_RSA_WAIT_FOR_RESULT : Enc / Dec data is %d", rsa_dataout);
                        temp_rsa_buffer = rsa_dataout;
                    end
                    else begin
                        if (temp_opcode == OPCODE_MEM_READ) begin
                            restore_state = STATE_END_OPERATION;
                        end
                        dataout = rsa_dataout; 
                    end
                    status = OP_SUCCESS;
                    next_state = restore_state;
                end
                else begin
                    next_state = STATE_RSA_WAIT_FOR_RESULT;
                end
            end
        STATE_END_OPERATION:
            begin
                $display("\tcu >> STATE_END_OPERATION");
                cu_ready = 1'b1;
                next_state = STATE_END_OPERATION;
            end
        default:
            begin
                $display("\tcu >> INVALID_STATE, freeze everything!");
                next_state = STATE_END_OPERATION;
                cu_ready = 1'b1;
            end
    endcase // case
end

endmodule
