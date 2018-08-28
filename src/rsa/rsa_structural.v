module rsa(result,e,d,y,clock,enable,reset,ready);

// Parameter definitions :
parameter DATA_WIDTH = 8;
parameter DATA_DOUBLE_WIDTH = 16;
parameter STATE_WIDTH = 5;


// Input / Output definitions :
output [DATA_WIDTH-1:0]result; 
//output [DATA_DOUBLE_WIDTH-1:0]result;
output ready;
input [DATA_WIDTH-1:0]e,d,y;
input clock,reset,enable;

// Register definitions
wire [DATA_WIDTH-1:0]emul_a,emul_b,modn_b;
wire [DATA_WIDTH-1:0]result; 
wire ready,emul_en,emul_rst,modn_en,modn_rst;
wire [DATA_DOUBLE_WIDTH-1:0]modn_a;

// Wire definitions
wire [DATA_DOUBLE_WIDTH-1:0] emul_x;
wire [DATA_WIDTH-1:0] modn_x;
wire emul_ready,modn_ready;

// Structural description of the RSA module :
rsa_behavioral rsa_behavioral(result,e,d,y,clock,enable,reset,ready,
                emul_x,emul_a,emul_b,emul_en,emul_rst,emul_ready,
                modn_x,modn_ready,modn_a,modn_b,modn_en,modn_rst);
emul_sql emul_sql(emul_x,emul_a,emul_b,clock,emul_en,emul_rst,emul_ready);
modn modn(modn_x,modn_ready,modn_a,modn_b,clock,modn_en,modn_rst);
endmodule
