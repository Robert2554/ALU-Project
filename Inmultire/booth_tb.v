`timescale 1ns / 1ps

module booth_tb;

    reg clk;
    reg rst;
    reg start;
    reg [7:0] M;
    reg [7:0] Q;

    wire [15:0] Prod;
    wire ready;

    booth_final uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .M(M),
        .Q(Q),
        .Prod(Prod),
        .ready(ready)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        start = 0;
        M = 0;
        Q = 0;

        #15; 
        rst = 0;
        #10;

        M = 8'd7; 
        Q = 8'd5;
        start = 1;  
        #10;        
        start = 0;  
        wait(ready == 1); 
        #20;

        M = 8'd6;
        Q = -8'd3;  
        start = 1;
        #10;
        start = 0;
        wait(ready == 1);
        #20;

        M = -8'd7;
        Q = -8'd6;
        start = 1;
        #10;
        start = 0;
        wait(ready == 1);
        #20;

    end

endmodule
