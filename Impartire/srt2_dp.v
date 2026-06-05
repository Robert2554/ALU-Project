module srt2_dp (
    input clk,
    input rst,
    input [7:0] Dividend, // Numarul pe care il impartim (intra in Q)
    input [7:0] Divisor,  // Numarul la care impartim (intra in M)
    input init,
    input calc_en,
    input correct_en,
    input [1:0] alu_sel,
    output a_sign,        // Trimitem semnul lui A la Control
    output [7:0] Quotient,// Catul
    output [7:0] Remainder// Restul
);
    wire [7:0] out_A, out_M, out_Q;
    wire [7:0] in_A, in_M, in_Q;

    // ====================================================
    // 1. CABLAJUL PENTRU SHIFTAREA LA STANGA
    // ====================================================
    // A primeste bucata de jos a lui A + cel mai de sus bit din Q
    wire [7:0] A_shifted = {out_A[6:0], out_Q[7]};

    // ====================================================
    // 2. ALU (Adder + Subtractor)
    // ====================================================
    // MUX care decide ce intra in ALU: A_shifted (in timpul calculului) sau out_A (la corectie)
    wire [7:0] A_alu_in;
    mux2to1_8bit MUX_ALU_IN (.d0(out_A), .d1(A_shifted), .sel(calc_en), .y(A_alu_in));

    wire [7:0] w_add, w_sub, alu_out;
    adder8bit      U_ADD (.a(A_alu_in), .b(out_M), .cin(1'b0), .sum(w_add), .cout());
    subtractor8bit U_SUB (.a(A_alu_in), .b(out_M), .diff(w_sub), .bout());

    mux4to1_8bit MUX_ALU (
        .d0(out_A), .d1(w_add), .d2(w_sub), .d3(8'b0),
        .sel(alu_sel), .y(alu_out)
    );

    // ====================================================
    // 3. GENERAREA BITULUI DE CAT
    // ====================================================
    // Daca rezultatul ALU e pozitiv (0), catul e 1. Altfel e 0.
    wire q_bit = ~alu_out[7];
    wire [7:0] Q_shifted = {out_Q[6:0], q_bit}; // Q se shifteaza si absoarbe q_bit

    // ====================================================
    // 4. RETEAUA DE MULTIPLEXOARE SPRE REGISTRE
    // ====================================================
    wire update_A_en = calc_en | correct_en; // Cand salvam date noi in A?
    
    // Logica pentru A
    wire [7:0] a_mux_calc;
    mux2to1_8bit MUX_A_CALC (.d0(out_A), .d1(alu_out), .sel(update_A_en), .y(a_mux_calc));
    mux2to1_8bit MUX_A_INIT (.d0(a_mux_calc), .d1(8'b0), .sel(init), .y(in_A)); // A se face 0 la init

    // Logica pentru Q
    wire [7:0] q_mux_calc;
    mux2to1_8bit MUX_Q_CALC (.d0(out_Q), .d1(Q_shifted), .sel(calc_en), .y(q_mux_calc));
    mux2to1_8bit MUX_Q_INIT (.d0(q_mux_calc), .d1(Dividend), .sel(init), .y(in_Q)); // Q primeste Dividendul

    // Logica pentru M
    mux2to1_8bit MUX_M_INIT (.d0(out_M), .d1(Divisor), .sel(init), .y(in_M));

    // ====================================================
    // 5. BANCUL DE REGISTRE (Structurale din D-FF)
    // ====================================================
    reg8bit REG_A (.clk(clk), .rst(rst), .d(in_A), .q(out_A));
    reg8bit REG_M (.clk(clk), .rst(rst), .d(in_M), .q(out_M));
    reg8bit REG_Q (.clk(clk), .rst(rst), .d(in_Q), .q(out_Q));

    // ====================================================
    // IESIRI
    // ====================================================
    assign a_sign = out_A[7];
    assign Quotient = out_Q;
    assign Remainder = out_A;

endmodule
