/* =============================================================
 *
 *                          CHAKRAVYUH                          
 *                          ~~~~~~~~~~
 * 
 * Filename : memory.v
 * Purpose  : Memory Unit implementation (8bits X 256 words)
 *
 * ============================================================= */

// Module declaration
module memory(clk,en,reset,op,addr,datain,dataout,ready);
`include "constants.vh"

// Input & Output lines
input clk,en,op,reset;
input [WORDSIZE-1:0] datain;
input [MEMORY_ADDR_WIDTH-1:0] addr; 
output [WORDSIZE-1:0] dataout;
reg [WORDSIZE-1:0]dataout;
//output [1:0] status;
reg [1:0] status;
output reg ready;

// Temporary memory to buffer input parameters
reg temp_op; 
reg [MEMORY_ADDR_WIDTH-1:0]temp_addr;
reg [WORDSIZE-1:0]temp_datain;

// For the state machine 
reg state, end_of_operation;

integer i;

// Memory register file to store / retrieve data words
reg [MEMORY_ADDR_WIDTH-1:0] safe [0:NUMBER_OF_WORDS];

// Behavioral definition 
always @(posedge clk) begin
    if (reset) begin
        $display("\t\tmemory >> Entering reset stage");
        ready <= 1'b0;
        state <= BUFFER_USER_INPUT; 
        end_of_operation <= 1'b0;
        status <= 0;
        dataout <= 0;
    end // reset

    if (en & ~end_of_operation) begin
        $display("\t\tmemory >> Enabled & busy flag is 0");
        if (state == BUFFER_USER_INPUT) begin
            $display("\t\tmemory >> Buffering user input");
            temp_op <= op;
            temp_addr <= addr;
            temp_datain <= datain;
            ready <= 1'b0;
            state <= PROCESS_COMMAND;
            end_of_operation <= 1'b0;
            $display("\t\tmemory >> Op : %d, Addr : %d, Datain : %d",temp_op,temp_addr,temp_datain);
        end // buffer user input

        else if (state == PROCESS_COMMAND) begin
            $display("\t\tmemory >> Processing the command");
            if (temp_addr > MAX_MEMORY_ADDR) begin
                $display("\t\tmemory >> Address out of range");
                status <= ADDR_OUT_OF_RANGE;
            end
            if (temp_op == WR) begin
                $display("\t\tmemory >> Writing to memory %d", temp_datain);
                safe[temp_addr] <= temp_datain;
                status <= SUCCESS;
            end
            else if (temp_op == RD) begin
                $display("\t\tmemory >> Reading from memory");
                dataout <= safe[temp_addr];
                status <= SUCCESS;
                $writememh("memory.list",safe);
            end

            $display("\t\tmemory >> Setting ready flag to 1");
            state <= PROCESS_COMMAND;
            ready <= 1'b1;
            end_of_operation <= 1'b1;
        end // process command
    end // en
end // always block

// Initialize the memory with all 0's
initial begin
for (i = 0; i<NUMBER_OF_WORDS; i=i+1) begin
    safe[i] = 0;
end    
    $writememh("memory.list",safe);
end

endmodule
