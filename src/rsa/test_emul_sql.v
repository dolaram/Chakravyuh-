module main;

reg [7:0] a,b;
reg clock,reset,enable;
wire [15:0] x;
wire ready;

emul_sql emul_sql(x,a,b,clock,enable,reset,ready);

initial begin 
    $display("test >> Resetting the emul_sql module");
    reset = 1;
    enable = 0;
    #10;
    reset = 0;
    if (~ready) begin
        $display("test >> emul_sql is ready");
    end
    else begin
        $display("test >> emul_sql is not ready");
    end
    a = 8'b00001111;
    b = 8'b11111111;
    enable = 1;

    $display("test >> Waiting till emul_sql has its data ready");
    while (ready == 1'b0) begin
        #1;
    end

    $display("test >> emul_sql has its data ready!");
    enable = 0;
    $display("test >> a was %d, b was %d, axb = %d",a,b,x);

    $display("test >> Resetting the emul_sql module for the next computation");

    enable = 0;
    reset = 1;
    while (ready != 1'b0) begin
        #1;
    end
    reset = 0;

    $display("test >> emul_sql is ready");

    a = 8'b10101111;
    b = 8'b11011011;
    enable = 1;

    $display("test >> Waiting till emul_sql has its data ready");
    while (ready == 1'b0) begin
        #1;
    end

    $display("test >> emul_sql has its data ready!");
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
