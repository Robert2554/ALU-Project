module srt2_final (
    input clk,
    input rst,
    input start,
    input [7:0] Dividend, 
    input [7:0] Divisor,  
    output [7:0] Quotient,
    output [7:0] Remainder,
    output ready
);
    wire w_init, w_calc_en, w_correct_en, w_a_sign;
    wire [1:0] w_alu_sel;

    srt2_ctrl CONTROL (
        .clk(clk), .rst(rst), .start(start),
        .a_sign(w_a_sign),
        .init(w_init), .calc_en(w_calc_en), .correct_en(w_correct_en),
        .alu_sel(w_alu_sel), .ready(ready)
    );

    srt2_dp DATAPATH (
        .clk(clk), .rst(rst),
        .Dividend(Dividend), .Divisor(Divisor),
        .init(w_init), .calc_en(w_calc_en), .correct_en(w_correct_en),
        .alu_sel(w_alu_sel),
        .a_sign(w_a_sign),
        .Quotient(Quotient), .Remainder(Remainder)
    );
endmodule
