 /*
// 
// Copyright (C) 2022  Mike Taylor
// This file is part of RE-SDMAC <https://github.com/mbtaylor1982/RE-SDMAC>.
// 
// RE-SDMAC is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// RE-SDMAC is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with dogtag.  If not, see <http://www.gnu.org/licenses/>.
 */

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

assign CYCLE_ACTIVE = ~(AS_| DMAC_ | WDREGREQ | h_0C);

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

// the "macro" to dump signals
`ifdef COCOTB_SIM
initial begin
  $dumpfile ("registers_term.vcd");
  $dumpvars (0, registers_term);
  #1;
end
`endif

endmodule