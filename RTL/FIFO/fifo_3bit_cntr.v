
module fifo_3bit_cntr(
    input CLK,
    input ClKEN,
    input RST_,

    output reg [2:0] COUNT
);

always @(posedge CLK or negedge RST_) begin
    if (RST_ == 1'b0)
        COUNT <= 3'b000;
    else if(ClKEN)
      COUNT <= COUNT + 1'b1;
end

// the "macro" to dump signals
`ifdef COCOTB_SIM1
initial begin
  $dumpfile ("fifo_3bit_cntr.vcd");
  $dumpvars (0, fifo_3bit_cntr);
  #1;
end
`endif

endmodule