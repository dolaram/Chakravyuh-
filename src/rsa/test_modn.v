module main;

reg [7:0] b,y;
reg [15:0] a;
reg clock,reset,enable;
wire [7:0] x;
wire ready;

modn modn(x,ready,a,b,clock,enable,reset);

initial begin 
    $display("test >> Resetting the modn module");
    reset = 1;
    enable = 0;
    #10;
    reset = 0;
    if (~ready) begin
        $display("test >> modn is ready");
    end
    else begin
        $display("test >> modn is not ready");
    end
    a = 16'b0000000011110001;
    b = 8'b00100000;
    y = 8'b00000011;
    enable = 1;

    $display("test >> Waiting till modn has its data ready");
    while (ready == 1'b0) begin
        #1;
    end

    $display("test >> modn has its data ready!");
    enable = 0;
    $display("test >> a was %d, b was %d, axb = %d",a,b,x);

    $display("test >> Resetting the modn module for the next computation");

    enable = 0;
    reset = 1;
    while (ready != 1'b0) begin
        #1;
    end
    reset = 0;

    $display("test >> emul_sql is ready");

    a = 16'b0000000011110001;
    b = 8'b00011011;
    y = 8'b00000011;
    enable = 1;

    $display("test >> Waiting till modn has its data ready");
    while (ready == 1'b0) begin
        #1;
    end

    $display("test >> modn has its data ready!");
    enable = 0;

    $display("test >> a was %d, b was %d, axb = %d",a,b,x);
end

always begin
    clock = 0; 
    #5;
    clock = 1;
    #5;
end

endmodule
