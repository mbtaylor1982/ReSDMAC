/*ReSDMAC © 2024 by Michael Taylor is licensed under Creative Commons Attribution-ShareAlike 4.0 International. To view a copy of this license, visit https://creativecommons.org/licenses/by-sa/4.0/*/

module registers_term(
    input CLK,
    input AS_,
    input DMAC_,
    input WDREGREQ,
    input h_0C,

    output reg REG_DSK_
);

reg [1:0] TERM_COUNTER;

wire CYCLE_ACTIVE;

`ifdef COCOTB_SIM
  assign CYCLE_ACTIVE = ~(AS_| DMAC_ | WDREGREQ );
`else
  assign CYCLE_ACTIVE = ~(AS_| DMAC_ | WDREGREQ | h_0C);
`endif

always @(posedge CLK or posedge AS_) begin
  if (AS_) begin
    TERM_COUNTER <= 2'd0;
    REG_DSK_ <= 1'b1;
  end
  else if (CYCLE_ACTIVE) begin
    if (TERM_COUNTER == 2'd1)
      REG_DSK_ <= 1'b0;
    //else if (TERM_COUNTER == 2'd2)
    //  REG_DSK_ <= 1'b1;
    if (TERM_COUNTER < 2'd3)
    TERM_COUNTER <= TERM_COUNTER + 1'b1;
  end
end

endmodule