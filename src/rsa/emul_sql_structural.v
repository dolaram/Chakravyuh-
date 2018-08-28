module emul_sql(x,a,b,clock,enable,reset,ready);

input [7:0] a,b;
input clock,reset,enable;
output [15:0] x;
output ready;
wire [7:0] emul_a,emul_b;
wire [15:0]emul_x;

// Structural description of emul & emul_seq interconnection
emul el(emul_a,emul_b,emul_x);
emul_sql_behavioral esb(x,a,b,clock,enable,reset,ready,emul_a,emul_b,emul_x);
endmodule
