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
    input nCPUCLK,
    input AS_,
    input DMAC_,
    input WDREGREQ,
    input h_0C, 

    output reg REG_DSK_
);

reg [2:0] TERM_COUNTER;

wire CYCLE_ACTIVE;
wire CYCLE_TERM;
wire CYCLE_END;

assign CYCLE_ACTIVE = ~(AS_| DMAC_);
assign CYCLE_TERM = (TERM_COUNTER == 3'd4);
assign CYCLE_END = ~(AS_| WDREGREQ | h_0C);

always@(posedge nCPUCLK or posedge AS_) begin
  if (AS_ == 1'b1)
    TERM_COUNTER <= 3'b000;
  else if (CYCLE_ACTIVE == 1'b1)
    TERM_COUNTER <=  TERM_COUNTER +1;
end

always @(posedge CYCLE_TERM or negedge CYCLE_END) begin
  if (CYCLE_END == 1'b0) 
    REG_DSK_ <= 1'b1;  
  else
    REG_DSK_ <= 1'b0;  
end

endmodule