//ReSDMAC © 2024 by Michael Taylor is licensed under Creative Commons Attribution-ShareAlike 4.0 International. To view a copy of this license, visit https://creativecommons.org/licenses/by-sa/4.0/

module fifo_3bit_cntr(
    input CLK,
    input ClKEN,
    input RST_,

    output reg [2:0] COUNT
);

always @(posedge CLK) begin
    if (~RST_)
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