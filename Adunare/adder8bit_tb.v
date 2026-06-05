module adder8bit_tb;

   
    reg [7:0] a;
    reg [7:0] b;
    reg cin;
    
    wire [7:0] sum;
    wire cout;

    // -----------------------------------------------------------
    // 2. INSTAN?IEREA MODULULUI (Conectarea firelor la placa de baz?)
    // (UUT = Unit Under Test)
    // -----------------------------------------------------------
    adder8bit uut (
        .a(a),    // '.a' mic (din modul), 'A' mare (din TB)
        .b(b),    // '.b' mic
        .cin(cin),// '.cin' mic
        .sum(sum),// '.sum' mic
        .cout(cout)
    );

   
    initial begin
        
        a = 8'd0; b = 8'd0; cin = 1'b0;
        #10;


        a = 8'd16; b = 8'd10; cin = 1'b0;
        #10;

        a = 8'd50; b = 8'd50; cin = 1'b1;
        #10;

        a = 8'd255; b = 8'd1; cin = 1'b0;
        #10;

        a = 8'd100; b = 8'd23; cin = 1'b1;
        #10;

    end

endmodule
