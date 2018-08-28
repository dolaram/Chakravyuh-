/* =============================================================
 *
 *                          CHAKRAVYUH                          
 *                          ~~~~~~~~~~
 * 
 * Filename : test_cu.v
 * Purpose  : Test bed for the Control Unit
 *
 * ============================================================= */

module main;
`include "constants.vh"

reg clock,reset,enable;
reg [OPCODE_WIDTH-1:0] opcode;
reg [DATA_WIDTH-1:0] datain,addr;
wire [DATA_WIDTH-1:0] rsa_dataout,mem_dataout,dataout,rsa_datain,rsa_modulusin,rsa_keyin,mem_datain;
wire rsa_en,mem_en,cu_ready;
wire [STATUS_WIDTH-1:0] status;

reg mem_ready,rsa_ready;

cu cu( clock,reset,enable,opcode,datain,addr,
           rsa_dataout,rsa_ready,mem_dataout,mem_ready,
           dataout,status,cu_ready,
           rsa_datain,rsa_modulusin,rsa_keyin,mem_datain,
           rsa_en,mem_en
          );

initial begin

    $display("test >> Resetting Chakravyuh");

    rsa_ready = 1'b1;
    mem_ready = 1'b1;
    reset = 1'b1;
    #10;
    reset = 1'b0;

    if (cu_ready == 1'b0) begin
        $display("test >> All is well, CU is ready!");
    end

    $display("test >> Testing memory read");

    opcode = OPCODE_MEM_READ;
    enable = 1'b1;

    $display("test >> Waiting for ready signal");

    while (cu_ready == 1'b0) begin
        #1;
    end

    $display("test >> Got the ready signal, setting enable to zero");
    enable = 1'b0;

    $display("test >> Waiting for CU to get ready for next operation");
    while (cu_ready != 1'b0) begin
        #1;
    end

    $display("test >> Testing memory write");
    opcode = OPCODE_MEM_WRITE;
    enable = 1'b1;

    $display("test >> Waiting for ready signal");
    while (cu_ready == 1'b0) begin
        #1;
    end

    $display("test >> Got the ready signal, setting enable to zero");
    enable = 1'b0;

end

always begin
    clock = 0;
    #5;
    clock = 1;
    #5;
end

endmodule
