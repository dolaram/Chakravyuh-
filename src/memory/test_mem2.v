module main;
`include "constants.vh"

reg clk,en,op,reset;
reg [WORDSIZE-1:0]addr;
reg [MEMORY_ADDR_WIDTH-1:0] datain;
wire [MEMORY_ADDR_WIDTH-1:0] dataout;
wire [1:0]status;

memory mem(clk,en,reset,op,addr,datain,dataout,status,ready);

initial begin

    $display("test >> Resetting the chip");
    reset = 1'b1;
    #10; 
    reset = 1'b0;

    $display("test >> Setting input to chip & enabling it");
    op = 1'b1;
    addr = 8'b00001000;
    datain = 8'b11110000;
    en = 1'b1;

    $display("test >> Waiting for the chip to signal ready...");
    while (ready == 1'b0) begin
        #1;
    end

    $display("test >> Ready signaled !");
    en = 1'b0;

    $display("test >> Ready is %d",ready);

    $display("test >> Status of write operation was : %d",status);

    reset = 1'b1;
    while (ready) begin
        #1;
    end
    reset = 1'b0;

    op = 1'b0;
    addr = 8'b00001000;
    en = 1'b1;

    while (ready == 1'b0) begin
        #1;
    end

    $display("test >> Data read from memory was : %d",dataout);
    $display("test >> Status of read operation was : %d",status);

    en = 1'b0;

    reset = 1'b1;
    while (ready) begin
        #1;
    end
    reset = 1'b0;

    op = 1;
    addr = 8'b00001001;
    datain = 8'b11110001;
    en = 1;

    while (ready == 1'b0) begin
        #1;
    end

    $display("test >> Status of write operation was : %d",status);
    en = 0;

    reset = 1'b1;
    while (ready) begin
        #1;
    end
    reset = 1'b0;

    op = 0;
    en = 1;

    while (ready == 1'b0) begin
        #1;
    end

    $display("test >> Data read from memory was : %d",dataout);
    $display("test >> Status of read operation was : %d",status);

end

always begin
    clk = 1'b0;
    #5;
    clk = 1'b1;
    #5;
end

endmodule
