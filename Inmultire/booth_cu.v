module booth_cu (
    input clk, 
    input rst, 
    input start,
    input q0,            // Primeste bitul Q[0] din Datapath
    input qm1,           // Primeste bitul Q[-1] din Datapath
    output reg init,     // Trimite comanda: Incarca valorile initiale
    output reg shift_en, // Trimite comanda: Shifteaza la dreapta
    output reg [1:0] alu_sel, // Trimite comanda ALU: 00=Pastreaza, 01=Adunare, 10=Scadere
    output reg ready     // Anunta ALU_Top ca a terminat inmultirea
);
    // Registrele pentru starea curenta si numaratorul pasilor
    reg [1:0] state, next_state;
    reg [3:0] count, next_count;

    // Numele starilor (pentru a citi codul mai usor)
    localparam IDLE = 2'd0, CALC = 2'd1, DONE = 2'd2;

    // ====================================================
    // 1. BLOCUL SECVEN?IAL (Memoria St?rilor - D-Flip-Flops)
    // ====================================================
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            count <= 4'd0;
        end else begin
            state <= next_state;
            count <= next_count;
        end
    end

    // ====================================================
    // 2. BLOCUL COMBINA?IONAL (Logica de Decizie)
    // ====================================================
    always @(*) begin
        // Valori implicite (ca sa prevenim crearea de memorii nedorite - "latch-uri")
        next_state = state;
        next_count = count;
        init = 1'b0;
        shift_en = 1'b0;
        alu_sel = 2'b00;
        ready = 1'b0;

        case(state)
            IDLE: begin
                if (start) begin
                    init = 1'b1;         // Spunem Datapath-ului: "Incarca M_in si Q_in"
                    next_count = 4'd8;   // Setam numaratorul pentru 8 biti
                    next_state = CALC;   // Trecem la stadiul de calcul
                end
            end

            CALC: begin
                if (count > 0) begin
                    shift_en = 1'b1; // In fiecare din cei 8 pasi vom shifta
                    
                    // Aici este algoritmul lui Booth pur: ce operatie matematica facem?
                    case ({q0, qm1})
                        2'b01: alu_sel = 2'b01; // Aduna M la A
                        2'b10: alu_sel = 2'b10; // Scade M din A
                        default: alu_sel = 2'b00; // 00 sau 11: Nu facem nimic matematic, doar shiftam
                    endcase

                    next_count = count - 1; // Scadem pasul curent
                end else begin
                    // Daca am ajuns la 0, s-au terminat cei 8 pasi
                    next_state = DONE;
                end
            end

            DONE: begin
                ready = 1'b1;      // Ridicam steagul "ready" pt ALU_top
                next_state = IDLE; // Ne intoarcem sa asteptam o noua inmultire
            end
            
            default: next_state = IDLE;
        endcase
    end
endmodule
