module reg1bit (
    input clk,
    input rst,
    input d,
    output q
);
    dff ff0 (.clk(clk), .rst(rst), .d(d), .q(q));
endmodule
