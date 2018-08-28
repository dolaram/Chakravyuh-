module main;
`include "constants.vh"

reg clk,en,reset;
wire [WORDSIZE-1:0] dataout;

rng rng(clk,en,reset,dataout,ready);

initial begin
    $display("test >> Resetting the RNG chip");
    en = 0;
    reset = 1;
    #10;
    reset= 0;

    en = 1;
    $display("test >> RNG counter is %d", dataout);
    #10;
    $display("test >> RNG counter is %d", dataout);
    #10;
    $display("test >> RNG counter is %d", dataout);
    #10;
end

always begin
    clk = 0;
    #5;
    clk = 1;
    #5;
end
endmodule
