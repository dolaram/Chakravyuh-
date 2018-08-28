/* =============================================================
 *
 *                          CHAKRAVYUH                          
 *                          ~~~~~~~~~~
 * 
 * Filename : fullsystem.v
 * Purpose  : Structural description of the entire system
 *
 * ============================================================= */

module fullsystem( clock,reset,enable,opcode,datain,addr,
                   dataout,status,cu_ready
                 );

`include "constants.vh"

input clock,reset,enable;
input [OPCODE_WIDTH-1:0] opcode;
input [DATA_WIDTH-1:0] datain,addr;
output [DATA_WIDTH-1:0] dataout;
output cu_ready;
output [STATUS_WIDTH-1:0] status;

wire [MEMORY_ADDR_WIDTH-1:0] mem_addr;
wire rsa_en,mem_en,mem_rst,mem_op,cu_ready;
wire [DATA_WIDTH-1:0] rsa_dataout,mem_dataout,dataout,rsa_datain,rsa_modulusin,rsa_keyin,mem_datain;

wire mem_ready;
wire rsa_ready;

cu cu ( clock,reset,enable,opcode,datain,addr,
        rsa_dataout,rsa_ready,mem_dataout,mem_ready,
        dataout,status,cu_ready,
        rsa_datain,rsa_modulusin,rsa_keyin,mem_datain,mem_addr,
        rsa_en,rsa_rst,mem_en,mem_rst,mem_op
      );

memory memory(clock,mem_en,mem_rst,mem_op,mem_addr,mem_datain,mem_dataout,mem_ready);

rsa rsa(rsa_dataout,rsa_datain,rsa_keyin,rsa_modulusin,clock,rsa_en,rsa_rst,rsa_ready);

endmodule
/* ============================================================= */

