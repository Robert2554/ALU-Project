module mux2to1_1bit (
    input d0, 
    input d1, 
    input sel, 
    output y
);
    assign y = sel ? d1 : d0;
endmodule
