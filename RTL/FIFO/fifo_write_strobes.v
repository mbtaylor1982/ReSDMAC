
module fifo_write_strobes(
    input [1:0] PTR,
    input LHWORD,
    input LLWORD,
    input LBYTE_,

    output UUWS,
    output UMWS,
    output LMWS,
    output LLWS
);
wire BO0, BO1;

assign BO0 = PTR[0];
assign BO1 = PTR[1];

assign UUWS = (!BO1 & !BO0 & !LBYTE_) | LHWORD; // B0
assign UMWS = (!BO1 & BO0  & !LBYTE_) | LHWORD; // B1
assign LMWS = (BO1  & !BO0 & !LBYTE_) | LLWORD; // B2
assign LLWS = (BO1  & BO0  & !LBYTE_) | LLWORD; // B3

endmodule