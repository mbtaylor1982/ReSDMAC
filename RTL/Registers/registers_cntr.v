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

module registers_cntr(
  input RESET_,
  input CLK,
  input CONTR_WR,
  input ST_DMA,
  input SP_DMA,
  input [8:0] MID,
    
  output reg [8:0] CNTR_O,
  output reg INTENA,
  output reg PRESET,
  output reg DMADIR,
  output reg DMAENA
);

always @(negedge CLK or negedge RESET_) begin
    if (RESET_ == 1'b0) begin
        DMADIR <= 1'b0;
        INTENA <= 1'b0; 
        PRESET <= 1'b0;
		    DMAENA <= 1'b0;		  
    end else if (CONTR_WR) begin
        DMADIR <= MID[1];
        INTENA <= MID[2];
        PRESET <= MID[4];
    end else if (ST_DMA)
		    DMAENA <= 1'b1;
	  else if (SP_DMA)
		    DMAENA <= 1'b0; 	
end

always @(*) begin
  CNTR_O <= {DMAENA, 1'b0, 1'b0, 1'b0, PRESET, 1'b0, INTENA, DMADIR, 1'b0};
end

endmodule