module srt2_ctrl (
    input clk,
    input rst,
    input start,
    input a_sign,           // Semnul lui A primit de la Datapath
    output reg init,
    output reg calc_en,     // Comanda pt a face Shift + Calc
    output reg correct_en,  // Comanda pt pasul final de corectie
    output reg [1:0] alu_sel, // 01=Aduna, 10=Scade, 00=Nimic
    output reg ready
);
    reg [1:0] state, next_state;
    reg [3:0] count, next_count;

    localparam IDLE = 2'd0, CALC = 2'd1, CORRECT = 2'd2, DONE = 2'd3;

    always @(posedge clk or posedge rst) begin
        if (rst) begin state <= IDLE; count <= 4'd0; end
        else begin state <= next_state; count <= next_count; end
    end

    always @(*) begin
        init = 0; calc_en = 0; correct_en = 0; alu_sel = 2'b00; ready = 0;
        next_state = state; next_count = count;

        case(state)
            IDLE: begin
                if (start) begin
                    init = 1'b1;
                    next_count = 4'd8; // Avem de calculat 8 biti
                    next_state = CALC;
                end
            end

            CALC: begin
                if (count > 0) begin
                    calc_en = 1'b1; // Dam comanda de shiftare
                    
                    
                    if (a_sign == 1'b1) 
                        alu_sel = 2'b01; // A e negativ -> ADUNA
                    else                
                        alu_sel = 2'b10; // A e pozitiv -> SCADE

                    next_count = count - 1;
                end else begin
                    // Dupa 8 pasi, verificam daca restul e negativ
                    if (a_sign == 1'b1) next_state = CORRECT;
                    else                next_state = DONE;
                end
            end

            CORRECT: begin
                correct_en = 1'b1;
                alu_sel = 2'b01; // Pt a repara un rest negativ, adunam M
                next_state = DONE;
            end

            DONE: begin
                ready = 1'b1;
                next_state = IDLE;
            end
            
            default: next_state = IDLE;
        endcase
    end
endmodule
