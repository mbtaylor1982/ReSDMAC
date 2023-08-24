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
module fifo_byte_ptr(
    input CLK,
    input INCBO,
    input MID25,
    input ACR_WR,
    input H_0C,
    input RST_FIFO_,        

    output wire [1:0] PTR    
);

wire MUXZ;
wire BO1_CLK;
reg BO0, BO1;

always @(posedge CLK or negedge RST_FIFO_) begin
    if (RST_FIFO_ == 1'b0)
        BO0 <= 1'b0;
    else if (INCBO)
        BO0 <= ~BO0;    
end

always @(posedge CLK or negedge RST_FIFO_) begin
    if (RST_FIFO_ == 1'b0)
        BO1 <= 1'b0;
    else if (BO1_CLK)
        BO1 <= MUXZ;
end

assign MUXZ = (H_0C) ? ~MID25 : (BO0 ^ ~BO1);
assign BO1_CLK = (INCBO | ACR_WR);
assign PTR = {BO1, BO0};

endmodule