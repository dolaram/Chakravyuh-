/* =============================================================
 *
 *                          CHAKRAVYUH                          
 *                          ~~~~~~~~~~
 * 
 * Filename : test_cu.v
 * Purpose  : Test bed for the entire system 
 *
 * ============================================================= */

module main;
`include "constants.vh"

reg clock,reset,enable;
reg [OPCODE_WIDTH-1:0] opcode;
reg [DATA_WIDTH-1:0] datain,addr;
wire [DATA_WIDTH-1:0] dataout;
wire cu_ready;
wire [STATUS_WIDTH-1:0] status;

fullsystem fs( clock,reset,enable,opcode,datain,addr,
               dataout,status,cu_ready
             );

initial begin

    $display("test >> Resetting Chakravyuh");

    addr = 0;
    opcode = 0;
    datain = 0;
    reset = 1'b1;
    enable = 0;
    #20;
    reset = 1'b0;

    // #80; // Nonce will change when we introduce a delay here

    if (cu_ready == 0) begin
        $display("test >> Chakravyuh is ready for authentication stage");
    end

    $display("test >> Performing authentication procedure");
    opcode = OPCODE_AUTH_START;
    enable = 1'b1;

    while (cu_ready != 1) begin
        #1;     
    end

    $display("test >> Received nonce {%d} from Chakravyuh",dataout);
    enable = 1'b0;

    while (cu_ready == 1) begin
        #1;
    end

    datain = 30; // Valid encrypted version of nonce '17'
    //datain = 99; // Invalid encrypted version of nonce '17'
    $display("test >> Sending encrypted nonce {%d} to Chakravyuh",datain);
    enable = 1'b1;

    while (cu_ready != 1) begin
        #1;
    end

    enable = 1'b0;

    //Memory read / write tests
    $display("\n############ test >> Testing Memory write ############## \n");
    test_chakravyuh(OPCODE_MEM_WRITE,23,100);
    $display("\n############ test >> Testing Memory write ############## \n");
    test_chakravyuh(OPCODE_MEM_WRITE,123,121);
    $display("\n############ test >> Testing Memory write ############## \n");
    test_chakravyuh(OPCODE_MEM_WRITE,78,140);
    $display("\n############ test >> Testing Memory read ############## \n");
    test_chakravyuh(OPCODE_MEM_READ,23,100);
    $display("test >> Data read was %d", dataout);
    $display("\n############ test >> Testing Memory read ############## \n");
    test_chakravyuh(OPCODE_MEM_READ,23,121);
    $display("test >> Data read was %d", dataout);
    $display("\n############ test >> Testing Memory read ############## \n");
    test_chakravyuh(OPCODE_MEM_READ,23,140);
    $display("test >> Data read was %d", dataout);

    // RSA encryption / decryption tests
    $display("\n############ test >> Testing RSA enc ############## \n");
    test_chakravyuh(OPCODE_RSA_ENC,9,140);
    $display("test >> Data read was %d", dataout);
    $display("\n############ test >> Testing RSA dec ############## \n");
    test_chakravyuh(OPCODE_RSA_DEC,48,140);
    $display("test >> Data read was %d", dataout);

    $display("\n############ test >> Testing RSA enc ############## \n");
    test_chakravyuh(OPCODE_RSA_ENC,54,140);
    $display("test >> Data read was %d", dataout);
    $display("\n############ test >> Testing RSA dec ############## \n");
    test_chakravyuh(OPCODE_RSA_DEC,76,140);
    $display("test >> Data read was %d", dataout);

    $display("\n############ test >> Testing RSA enc ############## \n");
    test_chakravyuh(OPCODE_RSA_ENC,96,140);
    $display("test >> Data read was %d", dataout);
    $display("\n############ test >> Testing RSA dec ############## \n");
    test_chakravyuh(OPCODE_RSA_DEC,112,140);
    $display("test >> Data read was %d", dataout);

/*
    // Invalid state tests
    $display("\n############ test >> Testing Invalid state  ############## \n");
    test_chakravyuh(10,112,140);
    $display("test >> Data read was %d, status was %d", dataout,status);
    reset = 1'b1;
    #10;
    reset = 1'b0;
    $display("\n############ test >> Testing RSA dec ############## \n");
    test_chakravyuh(OPCODE_RSA_DEC,112,140);
    $display("test >> Data read was %d", dataout);
*/

end

always begin
    clock = 0;
    #5;
    clock = 1;
    #5;
end


task test_chakravyuh;
    input [OPCODE_WIDTH-1:0] temp_opcode;
    input [DATA_WIDTH-1:0] temp_datain,temp_addr;
begin

    $display("test >> Waiting for CU to get ready for next operation");

    enable = 1'b0;

    while (cu_ready != 1'b0) begin
        #1;
    end

    opcode = temp_opcode;
    datain = temp_datain;
    addr = temp_addr;

    $display("test >> Testing operation %d", opcode);

    enable = 1'b1;

    $display("test >> Waiting for ready signal");

    while (cu_ready == 1'b0) begin
        #1;
    end

    $display("test >> Got the ready signal, setting enable to zero");
    enable = 1'b0;

end
endtask

endmodule
