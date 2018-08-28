module emul(a,b,x);
input [7:0] a,b;
//input clock;
output reg [15:0] x;
reg [15:0] p1,p2,p3,p4,P2,P3,P4,add1,add2;
reg [15:0] x1,x2;
always @(*) begin //This code is..... 
  P2[1:0]=0;
  P3[3:0]=0;
  P4[5:0]=0;
  x1[15:8]=0;
  x2[15:9]=0;
  x2[0]=0;
  x1[7:0]=a;
  x2[8:1]=a;
    if(b[1:0]==2'b00) begin
        p1=0;
    end 
    else if(b[1:0]==2'b01) begin
        p1=x1;
    end 
    else if(b[1:0]==2'b10)begin
        p1=x2;
    end 
    else if(b[1:0]==2'b11) begin
        p1=x1+x2;
    end
    
    if(b[3:2]==2'b00)
        p2=0;
    else if(b[3:2]==2'b01)
        p2=x1;
    else if(b[3:2]==2'b10)
        p2=x2;
    else if(b[3:2]==2'b11)
        p2=x1+x2;
    
    if(b[5:4]==2'b00)
        p3=0;
    else if(b[5:4]==2'b01)
        p3=x1;
    else if(b[5:4]==2'b10)
        p3=x2;
    else if(b[5:4]==2'b11)
        p3=x1+x2;
    
    if(b[7:6]==2'b00)
        p4=0;
    else if(b[7:6]==2'b01)
        p4=x1;
    else if(b[7:6]==2'b10)
        p4=x2;
    else if(b[7:6]==2'b11)
        p4=x1+x2;
    
      P2[15:2]=p2[13:0];
      P3[15:4]=p3[11:0];
      P4[15:6]=p4[9:0];
      add1=p1+P2;
      add2=add1+P3;
      x=add2+P4;
end
endmodule 



