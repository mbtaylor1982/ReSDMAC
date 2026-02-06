//ReSDMAC © 2024 by Michael Taylor is licensed under Creative Commons Attribution-ShareAlike 4.0 International. To view a copy of this license, visit https://creativecommons.org/licenses/by-sa/4.0/

`include "../phase_defs.vh"

module registers_term #(
    parameter WAIT_CYCLES = 1
)(
    input CLK100,         // 100MHz main clock
    input [1:0] phase,    // Phase counter value
    input AS_,
    input DMAC_,
    input WDREGREQ,
    input h_0C,
    input h_28,

    output reg REG_DSK_
);

localparam COUNTER_WIDTH = $clog2(WAIT_CYCLES + 1);

reg [COUNTER_WIDTH-1:0] term_counter;

wire CYCLE_ACTIVE;

`ifdef COCOTB_SIM
  assign CYCLE_ACTIVE = ~(AS_| DMAC_ | WDREGREQ | h_28);
`else
  assign CYCLE_ACTIVE = ~(AS_| DMAC_ | WDREGREQ | h_0C | h_28 );
`endif

always @(posedge CLK100 or posedge AS_) begin
  if (AS_) begin
    term_counter <= {COUNTER_WIDTH{1'b0}};
    REG_DSK_ <= 1'b1;
  end
  else if (CYCLE_ACTIVE && (phase == `PHASE_1)) begin
    if (term_counter == WAIT_CYCLES[COUNTER_WIDTH-1:0])
      REG_DSK_ <= 1'b0;
    else
      term_counter <= term_counter + 1'b1;
  end
end

endmodule