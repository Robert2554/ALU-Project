module shl8bit(
    input [7:0] a,       // Numarul care trebuie shiftat
    input [2:0] sa,      // Shift Amount (cate pozitii sa fie shiftat: 0-7)
    output [7:0] out     // Rezultatul
);

    assign out = a << sa;

endmodule
