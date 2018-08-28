/* =============================================================
 *
 *                          CHAKRAVYUH                          
 *                          ~~~~~~~~~~
 * 
 * Filename : constants.vh
 * Purpose  : Constant definitions used by the modules
 *
 * ============================================================= */

/* 
 * Parameters for Control Unit 
 * =========================== 
 */

// Bit-widths
parameter STATE_WIDTH  = 5;
parameter OPCODE_WIDTH = 4;
parameter DATA_WIDTH   = 8;
parameter ADDR_WIDTH   = 8;
parameter STATUS_WIDTH = 1;

// Control Unit states

parameter STATE_RESET                             = 0;
parameter STATE_START_AUTHENTICATION              = 1;
parameter STATE_VERIFY_AUTH_OPCODE                = 2;
parameter STATE_GET_ENCRYPTED_NONCE               = 3;
parameter STATE_DECRYPT_ENCRYPTED_NONCE           = 4;
parameter STATE_VERIFY_DECRYPTED_NONCE            = 5;
parameter STATE_AUTH_SET_CU_READY                 = 6;
parameter STATE_UI_TAKE_USER_INPUT                = 7;
parameter STATE_UI_VALIDATE_USER_INPUT            = 8;
parameter STATE_PERFORM_OP_MEM                    = 9;
parameter STATE_MEM_RESET                         = 10;
parameter STATE_MEM_RESET_AND_LOAD_INPUTS         = 11;
parameter STATE_LOADIP_AFTER_MEM_READY            = 12;
parameter STATE_MEM_ENABLE                        = 13;
parameter STATE_MEM_WAIT_FOR_RESULT               = 14;
parameter STATE_END_OPERATION                     = 15;
parameter STATE_PERFORM_OP_RSA                    = 16;
parameter STATE_RSA_RESET_AND_LOAD_INPUTS         = 17;
parameter STATE_LOADIP_AFTER_RSA_READY            = 18;
parameter STATE_RSA_ENABLE                        = 19;
parameter STATE_RSA_WAIT_FOR_RESULT               = 20;

// Control Unit status codes
parameter OP_SUCCESS = 1'b0;
parameter OP_INVALID_OPCODE = 1'b1;

// Control Unit opcodes
parameter OPCODE_MEM_READ    = 4'b0000;
parameter OPCODE_MEM_WRITE   = 4'b0001;
parameter OPCODE_RSA_ENC     = 4'b0010;
parameter OPCODE_RSA_DEC     = 4'b0011;
parameter OPCODE_AUTH_START  = 4'b0100;

parameter PUBLIC_KEY1      = 7;
parameter MOD1             = 143;
parameter PRIVATE_KEY1     = 103;
parameter ENC = 0;
parameter DEC = 1;

parameter NONCE_COUNTER_SIZE = 8;
parameter NONCE_INCREMENT_OFFSET = 17;
parameter NONCE_RANDOM_VALUE = 17;

/* ============================================================= */

/* 
 * Parameters for Memory Unit 
 * ========================== 
 */

parameter WORDSIZE = 8;
parameter MEMORY_ADDR_WIDTH = 8;
parameter NUMBER_OF_WORDS = 256;
parameter WR=1'b1;                 // Write operation
parameter RD=1'b0;                 // Read operation
parameter SUCCESS=2'b00;
parameter FAILURE=2'b11;
parameter ADDR_OUT_OF_RANGE = 2'b10;
parameter MAX_MEMORY_ADDR = 8'b11111111;

parameter BUFFER_USER_INPUT = 0;
parameter PROCESS_COMMAND   = 1;

/* ============================================================= */
