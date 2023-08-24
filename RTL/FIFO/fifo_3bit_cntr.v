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
module fifo_3bit_cntr(
    input CLK,
    input ClKEN,
    input RST_,    

    output reg [2:0] COUNT    
);

always @(posedge CLK or negedge RST_) begin
    if (RST_ == 1'b0)
        COUNT <= 3'b000;
    else if(ClKEN) 
      COUNT <= COUNT + 1'b1;
end

endmodule