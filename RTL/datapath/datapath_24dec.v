module datapath_24dec ( 
    input A,
    input B,
    input En,

    output D0,
    output D1,
    output D2,
    output D3
);

assign D0 = ~A & ~B & En;
assign D1 = ~A & B & En;
assign D2 = A & ~B & En;
assign D3 = A & B & En;

endmodule
