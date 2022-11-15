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
module fifo__full_empty_ctr(
    input INCFIFO,
    input DECFIFO,
    input RST_FIFO_,
    

    output reg FIFOEMPTY,
    output reg FIFOFULL
);

reg [2:0] Count;

wire NOT_FULL;
wire NOT_EMPTY;

assign NOT_FULL = FIFOFULL & DECFIFO;
assign NOT_EMPTY = FIFOEMPTY & INCFIFO;


always @(posedge INCFIFO or posedge DECFIFO) begin
    if (INCFIFO & (Count != 3'b111)) Count <=  Count +1;
    if (DECFIFO & (Count != 3'b000)) Count <=  Count -1;
    FIFOFULL <= (Count == 3'b111);
    FIFOEMPTY <= (Count == 3'b000);          
end

always @(posedge NOT_FULL or posedge NOT_EMPTY or negedge RST_FIFO_) begin
    if (RST_FIFO_ == 1'b0)
    begin
        Count <= 3'b000;
        FIFOEMPTY <= 1'b1;
        FIFOFULL <= 1'b0;
    end
    else begin
        if (NOT_FULL) FIFOFULL <= 1'b0;
        if (NOT_EMPTY) FIFOEMPTY <= 1'b0;
    end
end


endmodule