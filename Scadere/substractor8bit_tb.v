`timescale 1ns / 1ps

module subtractor8bit_tb;

    reg [7:0] a;
    reg [7:0] b;
    
    wire [7:0] diff;
    wire borrow_out;

    subtractor8bit dut (
        .a(a),
        .b(b),
        .diff(diff),
        .borrow_out(borrow_out)
    );

    // Blocul de test
    initial begin
        // Cazuri de test
        a = 8'd50;  b = 8'd20;  #10; // 50 - 20 = 30
        a = 8'd100; b = 8'd100; #10; // 100 - 100 = 0
        a = 8'd10;  b = 8'd20;  #10; // Sc?dere cu borrow
        a = 8'd255; b = 8'd1;   #10;
        
    end

endmodule
