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

module registers_istr(
  input RESET_,
  input CLK,
  input FIFOEMPTY,
  input FIFOFULL,
  input CLR_INT,
  input ISTR_RD_,
  input INTENA,
  input INTA_I,
  
  
  output [8:0] ISTR_O,
  output INT_O_
);

reg INT_F;
reg INTS;
reg E_INT;
reg INT_P;
reg FF;
reg FE;

wire CLR_INT_;
assign CLR_INT_ = ~(CLR_INT | ~RESET_);

wire INT;
assign INT = (INTENA & INTA_I);


always @(posedge CLK or negedge CLR_INT_) begin
  if (CLR_INT_ == 1'b0) begin
    INT_F   <= 1'b0;
    INTS    <= 1'b0;
    E_INT   <= 1'b0;
    INT_P   <= 1'b0;
    FF      <= 1'b0;
    FE      <= 1'b1;    
  end
  else if (~ISTR_RD_) begin
    INT_F   <= INTA_I;
    INTS    <= INTA_I;
    E_INT   <= INTA_I;
    INT_P   <= INT;
    FF      <= FIFOFULL;
    FE      <= FIFOEMPTY;
  end
end

assign ISTR_O = {1'b0, INT_F, INTS, E_INT, INT_P , 1'b0, 1'b0, FF, FE};
assign INT_O_ = INT ? 1'b0 : 1'b1;

endmodule