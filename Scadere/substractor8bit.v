module subtractor8bit (
    input [7:0] a,
    input [7:0] b,
    output [7:0] diff,
    output bout // Borrow out (similar cu carry out)
);
    wire [7:0] b_inv;
    
    // Pasul 1: Invertim toti bitii lui B (Complement fata de 1)
    assign b_inv = ~b; 

    // Pasul 2: Folosim adder-ul tau!
    // Ii dam a si b_inv, iar cin il punem pe 1 (pentru a completa Complementul fata de 2)
    adder8bit sub_inst (
        .a(a),
        .b(b_inv),
        .cin(1'b1),    // Acest +1 transforma b_inv in -b
        .sum(diff),
        .cout(bout)
    );
endmodule
