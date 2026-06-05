module shr8bit(
    input [7:0] a, 
    input [2:0] sa, 
    output [7:0] out
);
    assign out = a >> sa;
endmodule
