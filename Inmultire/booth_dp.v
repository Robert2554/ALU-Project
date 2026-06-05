module booth_dp (
    input clk, 
    input rst,
    input [7:0] M_in, 
    input [7:0] Q_in,
    input init,           
    input shift_en,       
    input [1:0] alu_sel,  
    output q0,            
    output qm1,           
    output [15:0] Prod    
);
    
    
    wire [7:0] out_A, out_M, out_Q;
    wire out_Qm1;

    
    wire [7:0] in_A, in_M, in_Q;
    wire in_Qm1;

    // Fire de la ALU si Shiftere
    wire [7:0] w_add, w_sub, alu_out;
    wire [7:0] a_logic_shift, q_logic_shift;

    // 1. UNITATILE DE CALCUL (ALU Structural)
    adder8bit U_ADD (.a(out_A), .b(out_M), .cin(1'b0), .sum(w_add), .cout());
    subtractor8bit U_SUB (.a(out_A), .b(out_M), .diff(w_sub), .bout());

    // Alegem intre A (pastreaza), Aduna, Scade
    mux4to1_8bit MUX_ALU (
        .d0(out_A), .d1(w_add), .d2(w_sub), .d3(8'b0),
        .sel(alu_sel), .y(alu_out)
    );

    // 2. SHIFTERELE
    shr8bit SHR_A (.a(alu_out), .sa(3'd1), .out(a_logic_shift));
    wire [7:0] a_arith_shifted = {alu_out[7], a_logic_shift[6:0]}; // Pastreaza semnul

    shr8bit SHR_Q (.a(out_Q), .sa(3'd1), .out(q_logic_shift));
    wire [7:0] q_shifted = {alu_out[0], q_logic_shift[6:0]}; // Intra bit din A
    
    wire qm1_shifted = out_Q[0]; // Intra bit din Q

    // 3. RETEAUA DE MULTIPLEXOARE (Ce bagam in registre?)
    wire [7:0] a_mux_shift_out, q_mux_shift_out;
    wire qm1_mux_shift_out;

    // --- MUX-urile de SHIFTARE (Aleg intre 'stai pe loc' si 'shifteaza') ---
    mux2to1_8bit MUX_A_SHIFT (.d0(out_A), .d1(a_arith_shifted), .sel(shift_en), .y(a_mux_shift_out));
    mux2to1_8bit MUX_Q_SHIFT (.d0(out_Q), .d1(q_shifted),       .sel(shift_en), .y(q_mux_shift_out));
    mux2to1_1bit MUX_QM1_SHIFT(.d0(out_Qm1),.d1(qm1_shifted),    .sel(shift_en), .y(qm1_mux_shift_out));

    // --- MUX-urile de INIT (Aleg intre 'valoarea de la shift/hold' si 'reset/incarcare initiala') ---
    mux2to1_8bit MUX_A_INIT  (.d0(a_mux_shift_out),   .d1(8'b0), .sel(init), .y(in_A));
    mux2to1_8bit MUX_Q_INIT  (.d0(q_mux_shift_out),   .d1(Q_in), .sel(init), .y(in_Q));
    mux2to1_1bit MUX_QM1_INIT(.d0(qm1_mux_shift_out), .d1(1'b0), .sel(init), .y(in_Qm1));

    mux2to1_8bit MUX_M_INIT  (.d0(out_M), .d1(M_in), .sel(init), .y(in_M));

    reg8bit REG_A   (.clk(clk), .rst(rst), .d(in_A),   .q(out_A));
    reg8bit REG_M   (.clk(clk), .rst(rst), .d(in_M),   .q(out_M));
    reg8bit REG_Q   (.clk(clk), .rst(rst), .d(in_Q),   .q(out_Q));
    reg1bit REG_QM1 (.clk(clk), .rst(rst), .d(in_Qm1), .q(out_Qm1));

    assign q0 = out_Q[0];
    assign qm1 = out_Qm1;
    assign Prod = {out_A, out_Q}; // Produsul final

endmodule
