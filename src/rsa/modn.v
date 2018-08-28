module modn(result,ready,x,y,clock,enable,reset);
input [15:0] x;
input [7:0] y;
input clock,enable,reset;
output reg [7:0] result;
output reg ready;
reg stop_computation;
reg [15:0] temp_x,temp_y;

reg [1:0]state;

always @(posedge clock) begin
if(reset) begin
   $display("\tmodn >> Undergoing reset");
   temp_x<=0;
   temp_y<=0;
   ready<=0;
   result<=0;
   stop_computation <=0;
   state <= 0;
end //end for reset if
if(enable & ~stop_computation) begin
   if(state == 0) begin
       $display("\tmodn >> Buffering user input, x is %d, y is %d", x,y);
       temp_x<=x;
       temp_y[7:0]<=y;
       temp_y[15:8]<=0;
       ready<=0;
       state <= 1;
   end//end for start
   else if(state == 1) begin
       if(temp_x>=temp_y) begin
          $display("\tmodn >> Computation under progress, tempx is %d, temp_y is %d", temp_x, temp_y);
          temp_x<=temp_x-temp_y;
          ready<=0;
          state<= 1;
       end//end for temp_x
       else begin 
          state<= 2;
       end
   end
   else if (state == 2) begin
       $display("\tmodn >> Result is ready!");
       result<=temp_x[7:0];
       ready<=1;
       stop_computation <= 1;
   end //end for else temp_x
end//end for enable
end//end for always
endmodule 

