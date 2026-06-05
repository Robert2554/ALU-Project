module reg8bit (
    input clk,
    input rst,
    input [7:0] d,
    output [7:0] q
);
    dff ff0 (.clk(clk), .rst(rst), .d(d[0]), .q(q[0]));
    dff ff1 (.clk(clk), .rst(rst), .d(d[1]), .q(q[1]));
    dff ff2 (.clk(clk), .rst(rst), .d(d[2]), .q(q[2]));
    dff ff3 (.clk(clk), .rst(rst), .d(d[3]), .q(q[3]));
    dff ff4 (.clk(clk), .rst(rst), .d(d[4]), .q(q[4]));
    dff ff5 (.clk(clk), .rst(rst), .d(d[5]), .q(q[5]));
    dff ff6 (.clk(clk), .rst(rst), .d(d[6]), .q(q[6]));
    dff ff7 (.clk(clk), .rst(rst), .d(d[7]), .q(q[7]));
endmodule
