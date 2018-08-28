module main;
reg [7:0] a,b,y;
reg clock,reset,enable;
wire [7:0] x;
wire ready;
rsa rsa(x,a,b,y,clock,enable,reset,ready);
initial begin 
    $display("test >> Resetting the rsa module");
    reset = 1;
    enable = 0;
    #10;
    reset = 0;

    if (~ready) begin
        $display("test >> rsa is ready");
    end
    else begin
        $display("test >> rsa is not ready");
    end
    a = 7;
    b = 3;
    y = 99;
    enable = 1;

    $display("test >> Waiting till rsa has its data ready");
    while (ready == 1'b0) begin
        #1;
    end

    $display("test >> rsa has its data ready!");
    enable = 0;
    $display("test >> a was %d, b was %d, y is %d,axb = %d",a,b,y,x);

    $display("test >> Resetting the rsa module for the next computation");

    enable = 0;
    reset = 1;
    while (ready != 1'b0) begin
        #1;
    end
    reset = 0;

    $display("test >> emul_sql is ready");

    a = 5;
    b = 5;
    y = 5;
    enable = 1;
    while (ready == 1'b0) begin
        #1;
    end
    enable = 0;
end
always begin
    clock = 0; 
    #5;
    clock = 1;
    #5;
end
endmodule
