module booth_final (
    input clk,
    input rst,
    input start,
    input [7:0] M,       // Deînmultitul (vine din ALU_top)
    input [7:0] Q,       // Înmultitorul (vine din ALU_top)
    output [15:0] Prod,  // Rezultatul final
    output ready         // Semnalul care anunta ALU ca a terminat
);

    
    wire w_init;
    wire w_shift_en;
    wire [1:0] w_alu_sel;
    wire w_q0;
    wire w_qm1;

    
    booth_cu CONTROL_UNIT (
        .clk(clk),
        .rst(rst),
        .start(start),
        .q0(w_q0),              // Primeste starea de la Datapath
        .qm1(w_qm1),            // Primeste starea de la Datapath
        .init(w_init),          // Trimite comanda de încarcare
        .shift_en(w_shift_en),  // Trimite comanda de shiftare
        .alu_sel(w_alu_sel),    // Trimite comanda pentru MUX-ul ALU
        .ready(ready)           // Trimite semnalul final spre exterior
    );

   
    booth_dp DATAPATH_UNIT (
        .clk(clk),
        .rst(rst),
        .M_in(M),               // Date externe de la utilizator
        .Q_in(Q),               // Date externe de la utilizator
        .init(w_init),          // Executa comanda de încarcare
        .shift_en(w_shift_en),  // Executa comanda de shiftare
        .alu_sel(w_alu_sel),    // Executa adunarea/scaderea
        .q0(w_q0),              // Raporteaza bitul 0 înapoi la Control
        .qm1(w_qm1),            // Raporteaza bitul -1 înapoi la Control
        .Prod(Prod)             // Scoate produsul final spre exterior
    );

endmodule
