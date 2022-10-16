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

module FIFO(
    input LLWORD,
    input LHWORD,
    input LBYTE_,
    input h_0C,
    input ACR_WR,
    input RST_FIFO_,
    input MID25,
    input [31:0] ID,

    output FIFOFULL,
    output FIFOEMPTY,
    input INCFIFO,
    input DECFIFO,
    input INCBO,
    output BOEQ0,
    output BOEQ3,
    output BO0,
    output BO1,
    input INCNO,
    input INCNI,

    output [31:0] OD
);

reg [2:0] NextOutPtr  = 3'b000;
reg [2:0] NextInPtr  = 3'b000;
reg [1:0] BytePrt  = 2'b00;

wire [7:0] NI;
wire [7:0] NO;


always @(posedge INCNI, negedge RST_FIFO_) begin
    if (! RST_FIFO_)
        NextInPtr <= 3'b000;
    else
        NextInPtr <= NextInPtr + 1;     
end

always @(posedge INCNO, negedge RST_FIFO_) begin
    if (! RST_FIFO_)
        NextOutPtr <= 3'b000;
    else
        NextOutPtr <= NextOutPtr + 1;     
end

decoder3to8 nid(
    .Data_in  (NextInPtr),
    .Data_out (NI)
);

decoder3to8 nod(
    .Data_in  (NextOutPtr),
    .Data_out (NO)
);

endmodule