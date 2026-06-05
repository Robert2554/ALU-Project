module alu_top (
    input clk,
    input rst,
    input start,              
    input [3:0] sel,          // Selectorul operatiei (0 pana la 8)
    input [7:0] A,            
    input [7:0] B,            
    output reg [7:0] Result,  // Iesirea pe 8 biti (Cerinta principala)
    output reg [7:0] Result_High, // Partea inalta (Rest DIV sau Top MUL)
    output reg Z,             // Flag: Zero
    output reg N,             // Flag: Negative
    output reg V,             // Flag: Overflow
    output reg ready          // Anunta cand rezultatul secvential e gata
);

    // ====================================================
    // CODIFICAREA OPERATIILOR (Maparea instructiunilor)
    // ====================================================
    localparam OP_ADD = 4'd0;
    localparam OP_SUB = 4'd1;
    localparam OP_MUL = 4'd2;
    localparam OP_DIV = 4'd3;
    localparam OP_AND = 4'd4;
    localparam OP_OR  = 4'd5;
    localparam OP_XOR = 4'd6;
    localparam OP_SHL = 4'd7;
    localparam OP_SHR = 4'd8;

    // ====================================================
    // FIRE INTERNE PENTRU REZULTATELE TUTUROR MODULELOR
    // ====================================================
    wire [7:0] w_add, w_sub, w_and, w_or, w_xor, w_shl, w_shr;
    wire w_add_cout, w_sub_bout;
    
    wire [15:0] w_mul;
    wire w_mul_ready;
    
    wire [7:0] w_div_q, w_div_r;
    wire w_div_ready;

    // ====================================================
    // INSTANTIEREA MODULELOR TALE STRUCTURALE (Din screenshot)
    // ====================================================
    // 1. Aritmetice
    adder8bit      U_ADD (.a(A), .b(B), .cin(1'b0), .sum(w_add), .cout(w_add_cout));
    subtractor8bit U_SUB (.a(A), .b(B), .diff(w_sub), .bout(w_sub_bout));
    
    // 2. Logice (Instantiem modulele tale xor8bit, or8bit, and8bit)
    and8bit U_AND (.a(A), .b(B), .out(w_and));
    or8bit  U_OR  (.a(A), .b(B), .out(w_or));
    xor8bit U_XOR (.a(A), .b(B), .out(w_xor));

    // 3. Shiftere (Shiftam A cu B pozitii)
    shl8bit U_SHL (.a(A), .sa(B[2:0]), .out(w_shl)); // Daca nu ai compilat shl8bit inca, sa o faci!
    shr8bit U_SHR (.a(A), .sa(B[2:0]), .out(w_shr));

    // 4. Inmultitorul Booth (Secvential)
    reg mul_start;
    booth_final U_MUL (
        .clk(clk), .rst(rst), .start(mul_start),
        .M(A), .Q(B), .Prod(w_mul), .ready(w_mul_ready)
    );

    // 5. Impartitorul SRT-2 (Secvential)
    reg div_start;
    srt2_final U_DIV (
        .clk(clk), .rst(rst), .start(div_start),
        .Dividend(A), .Divisor(B),
        .Quotient(w_div_q), .Remainder(w_div_r), .ready(w_div_ready)
    );

    // ====================================================
    // MASINA DE STARI (FSM) PENTRU CONTROLUL GLOBAL
    // ====================================================
    reg [1:0] state;
    localparam IDLE = 2'd0, WAIT_MUL = 2'd1, WAIT_DIV = 2'd2, DONE = 2'd3;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            ready <= 1'b0;
            Result <= 8'b0; Result_High <= 8'b0;
            Z <= 1'b0; N <= 1'b0; V <= 1'b0;
            mul_start <= 1'b0; div_start <= 1'b0;
        end else begin
            // Pulsoare implicite pentru semnalele de start
            mul_start <= 1'b0;
            div_start <= 1'b0;

            case(state)
                IDLE: begin
                    ready <= 1'b0;
                    if (start) begin
                        case (sel)
                            OP_MUL: begin
                                mul_start <= 1'b1; // Dam trezirea la inmultitor
                                state <= WAIT_MUL;
                            end
                            OP_DIV: begin
                                div_start <= 1'b1; // Dam trezirea la impartitor
                                state <= WAIT_DIV;
                            end
                            default: begin
                                // Pt ADD, SUB, AND, OR, XOR, SHL, SHR -> e gata instant (module combinationale)
                                state <= DONE;
                            end
                        endcase
                    end
                end

                WAIT_MUL: begin
                    // Stam aici blocati pana cand Booth ridica steagul
                    if (w_mul_ready) state <= DONE;
                end

                WAIT_DIV: begin
                    // Stam aici blocati pana cand SRT-2 ridica steagul
                    if (w_div_ready) state <= DONE;
                end

                DONE: begin
                    ready <= 1'b1; 
                    
                    // --- MUX GLOBAL PENTRU SELECTAREA REZULTATULUI ---
                    case (sel)
                        OP_ADD: Result <= w_add;
                        OP_SUB: Result <= w_sub;
                        OP_MUL: begin 
                                Result <= w_mul[7:0];       // Primii 8 biti
                                Result_High <= w_mul[15:8]; // Ultimii 8 biti
                                end
                        OP_DIV: begin 
                                Result <= w_div_q;          // Catul
                                Result_High <= w_div_r;     // Restul
                                end
                        OP_AND: Result <= w_and; // Legat la modulul tau and8bit
                        OP_OR:  Result <= w_or;  // Legat la modulul tau or8bit
                        OP_XOR: Result <= w_xor; // Legat la modulul tau xor8bit
                        OP_SHL: Result <= w_shl; // Legat la modulul tau shl8bit
                        OP_SHR: Result <= w_shr; // Legat la modulul tau shr8bit
                        default:Result <= 8'b0;
                    endcase

                    // --- CALCULAREA FLAG-URILOR DE STATUS ---
                    // Z (Zero) - valabil pentru orice operatie
                    if (Result == 8'b0) Z <= 1'b1;
                    else                Z <= 1'b0;
                    
                    // N (Negative) - se uita la bitul de semn al rezultatului
                    N <= Result[7];
                    
                    // V (Overflow Aritmetic) - doar pt Adunare/Scadere in Complement fata de 2
                    if (sel == OP_ADD) begin
                        V <= (~A[7] & ~B[7] & w_add[7]) | (A[7] & B[7] & ~w_add[7]);
                    end 
                    else if (sel == OP_SUB) begin
                        V <= (~A[7] & B[7] & w_sub[7]) | (A[7] & ~B[7] & ~w_sub[7]);
                    end 
                    else begin
                        V <= 1'b0; 
                    end

                    // Ne intoarcem sa asteptam noua instructiune
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule
