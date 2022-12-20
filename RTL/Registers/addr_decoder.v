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
module addr_decoder(
  input [7:0] ADDR, // CPU address Bus
  input DMAC_,      // SDMAC Chip Select !SCSI from Fat Garry.
  input AS_,        // CPU Address Strobe.
  input RW,         // CPU Read Write Control Line.
  input DMADIR,     // DMADIR from bit from Control Register.
  
  output h_0C,
  output WDREGREQ,

  output CONTR_RD_,
  output CONTR_WR,
  output ISTR_RD_,
  output ACR_WR, 
  //output DAWR_WR,
  output WTC_RD_,
  
  output ST_DMA,
  output SP_DMA,
  output CLR_INT,
  output FLUSH_
);

//wire h_00;
wire h_04;
wire h_08;
//wire h_0C;
wire h_10;
wire h_14;
wire h_18;
wire h_1C;
wire h_3C;

wire ADDR_VALID;
assign ADDR_VALID = ~(DMAC_ | AS_);

//assign h_00 = ADDR_VALID & (ADDR == 8'h00);
assign h_04 = ADDR_VALID & (ADDR == 8'h04);
assign h_08 = ADDR_VALID & (ADDR == 8'h08);
assign h_0C = ADDR_VALID & (ADDR == 8'h0C);
assign h_10 = ADDR_VALID & (ADDR == 8'h10);
assign h_14 = ADDR_VALID & (ADDR == 8'h14);
assign h_18 = ADDR_VALID & (ADDR == 8'h18);
assign h_1C = ADDR_VALID & (ADDR == 8'h1C);
assign h_3C = ADDR_VALID & (ADDR == 8'h3C);

assign WDREGREQ = ADDR_VALID & (ADDR >= 8'h40);

//Register Read and Write Strobes
//assign DAWR_WR    = ~(h_00 & RW);
assign WTC_RD_    = ~(h_04 & RW);
assign CONTR_RD_  = ~(h_08 & RW);
assign ISTR_RD_   = ~(h_1C & RW);

assign CONTR_WR   = (h_08 & ~RW);
assign ACR_WR     = (h_0C & ~RW);


//action strobes
assign ST_DMA   = h_10;
assign SP_DMA   = h_3C;
assign CLR_INT  = h_18;
assign FLUSH_   = ~(DMADIR & h_14);

endmodule
