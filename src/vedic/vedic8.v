/* =============================================================
 *
 *                          CHAKRAVYUH                          
 *                          ~~~~~~~~~~
 * 
 * Filename : vedic8.v
 * Purpose  : Vedic Multiplier Unit implementation (8bits X 8bits)
 *
 * ============================================================= */

// 8 bit vedic multiplier module : 
// Built with four 4-bit vedic multiplier modules, two 12bit adders and one 8bit adder 
module vedic8(a,b,c);   
input [7:0]a;
input [7:0]b;
output [15:0]c;
wire d,e,f;
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
// four 4 bit vedic multiplier modules 
vedic4 z1(a[3:0],b[3:0],q0[15:0]);
vedic4 z2(a[7:4],b[3:0],q1[15:0]);
vedic4 z3(a[3:0],b[7:4],q2[15:0]);
vedic4 z4(a[7:4],b[7:4],q3[15:0]);
// addition using adders
assign temp1 ={4'b0000,q0[7:4]};
add8bit z5(q1[7:0],temp1,q4,d);
assign temp2 ={4'b0000,q2[7:0]};
assign temp3 ={q3[7:0],4'b0000};
add12bit z6(temp2,temp3,q5,e);
assign temp4={4'b0000,q4[7:0]};
add12bit z7(temp4,q5,q6,f);
assign c[3:0]=q0[3:0];
assign c[15:4]=q6[11:0];
endmodule
// code for 4bit vedic multiplier
// Built with four 2-bit vedic multiplier modules, two 6bit adders and one 4bit adder
module vedic4(a,b,c);
input [3:0]a;
input [3:0]b;
output [7:0]c;
wire d,e,f;
wire [3:0]q0;	
wire [3:0]q1;	
wire [3:0]q2;
wire [3:0]q3;	
wire [7:0]c;
wire [3:0]temp1;
wire [5:0]temp2;
wire [5:0]temp3;
wire [5:0]temp4;
wire [3:0]q4;
wire [5:0]q5;
wire [5:0]q6;
// four 2 bit vedic multiplier modules 
vedic2 z1(a[1:0],b[1:0],q0[3:0]);
vedic2 z2(a[3:2],b[1:0],q1[3:0]);
vedic2 z3(a[1:0],b[3:2],q2[3:0]);
vedic2 z4(a[3:2],b[3:2],q3[3:0]);
// addition using adders
assign temp1 ={2'b00,q0[3:2]};
add4bit z5(q1[3:0],temp1,q4,d);
assign temp2 ={2'b00,q2[3:0]};
assign temp3 ={q3[3:0],2'b00};
add6bit z6(temp2,temp3,q5,e);
assign temp4={2'b00,q4[3:0]};
add6bit z7(temp4,q5,q6,f);
assign c[1:0]=q0[1:0];
assign c[7:2]=q6[5:0];
endmodule
// code for 2bit vedic multiplier
// Built with two half adders and AND gates
module vedic2(a,b,q);
input [1:0]a;
input [1:0]b;
output [3:0]q;
wire [3:0]q;
wire [3:0]temp;
assign q[0]=a[0]&b[0];
assign temp[0]=a[1]&b[0];
assign temp[1]=a[0]&b[1];
assign temp[2]=a[1]&b[1];
ha z1(temp[0],temp[1],q[1],temp[3]);
ha z2(temp[2],temp[3],q[2],q[3]);
endmodule
// code for Half Adder
// For use in 2bit vedic multiplier module
module ha(x,y,sum,carry);
input x,y;
output sum,carry;
assign carry=x&y;
assign sum=x^y;
endmodule
// code for Full Adder
// For use in 4,6,8&12 BIT Adders' modules
module fa(a,b,c,sum,carry);
input a,b,c;
output sum,carry;
wire d,e,f;
xor(sum,a,b,c);
and(d,a,b);
and(e,b,c);
and(f,a,c);
or(carry,d,e,f);
endmodule
// code for 4bit Adder
// For use in 4bit vedic multiplier module
module add4bit(a,b,sum,carry);
input [3:0] a ;
input [3:0] b ;
output [3:0]sum ;
output carry;
wire [2:0]s;
fa z0(a[0],b[0],1'b0,sum[0],s[0]);
fa z1(a[1],b[1],s[0],sum[1],s[1]);
fa z2(a[2],b[2],s[1],sum[2],s[2]);
fa z3(a[3],b[3],s[2],sum[3],carry);
endmodule
// code for 6bit Adder
// For use in 4bit vedic multiplier module
module add6bit(a,b,sum,carry);
input [5:0] a ;
input [5:0] b ;
output [5:0]sum ;
output carry;
wire [4:0]s;
fa z0(a[0],b[0],1'b0,sum[0],s[0]);
fa z1(a[1],b[1],s[0],sum[1],s[1]);
fa z2(a[2],b[2],s[1],sum[2],s[2]);
fa z3(a[3],b[3],s[2],sum[3],s[3]);
fa z4(a[4],b[4],s[3],sum[4],s[4]);
fa z5(a[5],b[5],s[4],sum[5],carry);
endmodule
// code for 8bit Adder
// For use in 8bit vedic multiplier module
module add8bit(a,b,sum,carry);
input [7:0] a ;
input [7:0] b ;
output [7:0]sum ;
output carry;
wire [6:0]s;
fa z0(a[0],b[0],1'b0,sum[0],s[0]);
fa z1(a[1],b[1],s[0],sum[1],s[1]);
fa z2(a[2],b[2],s[1],sum[2],s[2]);
fa z3(a[3],b[3],s[2],sum[3],s[3]);
fa z4(a[4],b[4],s[3],sum[4],s[4]);
fa z5(a[5],b[5],s[4],sum[5],s[5]);
fa z6(a[6],b[6],s[5],sum[6],s[6]);
fa z7(a[7],b[7],s[6],sum[7],carry);
endmodule
// code for 12bit Adder
// For use in 8bit vedic multiplier module
module add12bit(a,b,sum,carry);
input [11:0] a ;
input [11:0] b ;
output [11:0]sum ;
output carry;
wire [10:0]s;
fa z0(a[0],b[0],1'b0,sum[0],s[0]);
fa z1(a[1],b[1],s[0],sum[1],s[1]);
fa z2(a[2],b[2],s[1],sum[2],s[2]);
fa z3(a[3],b[3],s[2],sum[3],s[3]);
fa z4(a[4],b[4],s[3],sum[4],s[4]);
fa z5(a[5],b[5],s[4],sum[5],s[5]);
fa z6(a[6],b[6],s[5],sum[6],s[6]);
fa z7(a[7],b[7],s[6],sum[7],s[7]);
fa z8(a[8],b[8],s[7],sum[8],s[8]);
fa z9(a[9],b[9],s[8],sum[9],s[9]);
fa z10(a[10],b[10],s[9],sum[10],s[10]);
fa z11(a[11],b[11],s[10],sum[11],carry);
endmodule

