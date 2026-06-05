module booth_final (
    input clk,
    input rst,
    input start,
    input [7:0] M,       // Deînmul?itul (vine din ALU_top)
    input [7:0] Q,       // Înmul?itorul (vine din ALU_top)
    output [15:0] Prod,  // Rezultatul final pe 16 bi?i
    output ready         // Semnalul care anun?? ALU c? a terminat
);

    // ====================================================
    // FIRE INTERNE (Cablurile dintre Control ?i Datapath)
    // ====================================================
    wire w_init;
    wire w_shift_en;
    wire [1:0] w_alu_sel;
    wire w_q0;
    wire w_qm1;

    // ====================================================
    // 1. INSTAN?IEREA UNIT??II DE CONTROL (Creierul)
    // ====================================================
    booth_cu CONTROL_UNIT (
        .clk(clk),
        .rst(rst),
        .start(start),
        .q0(w_q0),              // Prime?te starea de la Datapath
        .qm1(w_qm1),            // Prime?te starea de la Datapath
        .init(w_init),          // Trimite comanda de înc?rcare
        .shift_en(w_shift_en),  // Trimite comanda de shiftare
        .alu_sel(w_alu_sel),    // Trimite comanda pentru MUX-ul ALU
        .ready(ready)           // Trimite semnalul final spre exterior
    );

    // ====================================================
    // 2. INSTAN?IEREA DATAPATH-ULUI (Mu?chii Structurali)
    // ====================================================
    booth_dp DATAPATH_UNIT (
        .clk(clk),
        .rst(rst),
        .M_in(M),               // Date externe de la utilizator
        .Q_in(Q),               // Date externe de la utilizator
        .init(w_init),          // Execut? comanda de înc?rcare
        .shift_en(w_shift_en),  // Execut? comanda de shiftare
        .alu_sel(w_alu_sel),    // Execut? adunarea/sc?derea
        .q0(w_q0),              // Raporteaz? bitul 0 înapoi la Control
        .qm1(w_qm1),            // Raporteaz? bitul -1 înapoi la Control
        .Prod(Prod)             // Scoate produsul final spre exterior
    );

endmodule
