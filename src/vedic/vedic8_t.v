/* =============================================================
 *
 *                          CHAKRAVYUH                          
 *                          ~~~~~~~~~~
 * 
 * Filename : vedic8_t.v
 * Purpose  : Test Bench for Vedic Multiplier Unit implementation (8bits X 8bits)
 *
 * ============================================================= */

module vedic8_t;
wire d;
wire e;
wire f;
reg [7:0]a;
reg [7:0]b;
wire [15:0]q0;	
wire [15:0]q1;	
wire [15:0]q2;
wire [15:0]q3;	
wire [15:0]c;
wire [7:0]temp1;
wire [11:0]temp2;
wire [11:0]temp3;
wire [11:0]temp4;
wire [7:0]q4;
wire [11:0]q5;
wire [11:0]q6;
vedic8 uut(.a(a),.b(b),.c(c));
initial begin
#10 a=8'b11111111;b=8'b11111111;
#10$stop;
end
endmodule

