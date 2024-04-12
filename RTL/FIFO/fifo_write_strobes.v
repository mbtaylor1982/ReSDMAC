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
assign LLWS = (BO0  & BO1  & !LBYTE_) | LLWORD; // B3

endmodule