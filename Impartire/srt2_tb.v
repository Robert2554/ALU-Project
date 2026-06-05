`timescale 1ns / 1ps

module srt2_tb;

    reg clk;
    reg rst;
    reg start;
    reg [7:0] Dividend;
    reg [7:0] Divisor;

    wire [7:0] Quotient;
    wire [7:0] Remainder;
    wire ready;

    srt2_final uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .Dividend(Dividend),
        .Divisor(Divisor),
        .Quotient(Quotient),
        .Remainder(Remainder),
        .ready(ready)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        start = 0;
        Dividend = 0;
        Divisor = 0;

        #15; 
        rst = 0;
        #10;

        // Test 1: 45 / 6 -> Cat = 7, Rest = 3
        Dividend = 8'd45; 
        Divisor = 8'd6;
        start = 1;  
        #10;        
        start = 0;  
        wait(ready == 1); 
        #20;

        // Test 2: 100 / 3 -> Cat = 33, Rest = 1
        Dividend = 8'd100;
        Divisor = 8'd3;  
        start = 1;
        #10;
        start = 0;
        wait(ready == 1);
        #20;

        // Test 3: 127 / 10 -> Cat = 12, Rest = 7
        Dividend = 8'd127;
        Divisor = 8'd10;
        start = 1;
        #10;
        start = 0;
        wait(ready == 1);
        #20;

    end

endmodule
