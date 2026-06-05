`timescale 1ns / 1ps

module alu_top_tb;

    // Intrari
    reg clk;
    reg rst;
    reg start;
    reg [3:0] sel;
    reg [7:0] A;
    reg [7:0] B;

    // Iesiri
    wire [7:0] Result;
    wire [7:0] Result_High;
    wire Z, N, V;
    wire ready;

    // Instantierea ALU-ului final
    alu_top uut (
        .clk(clk), .rst(rst), .start(start), .sel(sel),
        .A(A), .B(B), .Result(Result), .Result_High(Result_High),
        .Z(Z), .N(N), .V(V), .ready(ready)
    );

    // Generare ceas (10ns period)
    always #5 clk = ~clk;

    initial begin
        // Init
        clk = 0; rst = 1; start = 0; sel = 0; A = 0; B = 0;
        #15 rst = 0; #10;

        // --- TEST 1: ADUNARE (45 + 5 = 50) ---
        sel = 4'd0; A = 8'd45; B = 8'd5; start = 1; #10 start = 0;
        #100; // Pauza fixa in loc de wait(ready)

        // --- TEST 2: SCADERE (10 - 15 = -5) ---
        // Rezultatul ar trebui sa fie 251 (complement fata de 2) si flag N=1
        sel = 4'd1; A = 8'd10; B = 8'd15; start = 1; #10 start = 0;
        #100;

        // --- TEST 3: INMULTIRE BOOTH (7 * -3 = -21) ---
        // Result_High:Result ar trebui sa fie FFEB (hex)
        sel = 4'd2; A = 8'd7; B = -8'd3; start = 1; #10 start = 0;
        #200; // Pauza mai mare pentru inmultire (secventiala)

        // --- TEST 4: IMPARTIRE SRT-2 (100 / 3 = 33 r 1) ---
        sel = 4'd3; A = 8'd100; B = 8'd3; start = 1; #10 start = 0;
        #200; // Pauza mai mare pentru impartire (secventiala)

        // --- TEST 5: LOGIC AND (8'hAA & 8'hF0 = 8'hA0) ---
        sel = 4'd4; A = 8'hAA; B = 8'hF0; start = 1; #10 start = 0;
        #100;

        // --- TEST 6: LOGIC OR (8'h55 | 8'hF0 = 8'hF5) ---
        sel = 4'd5; A = 8'h55; B = 8'hF0; start = 1; #10 start = 0;
        #100;

        // --- TEST 7: LOGIC XOR (8'hAA ^ 8'h55 = 8'hFF) ---
        sel = 4'd6; A = 8'hAA; B = 8'h55; start = 1; #10 start = 0;
        #100;

        // --- TEST 8: SHIFT LEFT (8'd1 << 3 = 8) ---
        sel = 4'd7; A = 8'd1; B = 8'd3; start = 1; #10 start = 0;
        #100;

        // --- TEST 9: SHIFT RIGHT (8'd16 >> 2 = 4) ---
        sel = 4'd8; A = 8'd16; B = 8'd2; start = 1; #10 start = 0;
        #100;

        // --- TEST OVERFLOW (120 + 10) ---
        // Depaseste 127 (limita signed pe 8 biti), V ar trebui sa fie 1
        sel = 4'd0; A = 8'd120; B = 8'd10; start = 1; #10 start = 0;
        #100;

    end

endmodule
