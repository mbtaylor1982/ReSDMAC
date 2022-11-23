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

reg [2:0] COUNT;
wire clk;

always @(posedge clk or negedge RST_FIFO_) begin
    if (RST_FIFO_ == 1'b0)
    begin
        COUNT <= 3'b000;
        FIFOEMPTY <= 1'b1;
        FIFOFULL <= 1'b0;
    end
    else if (INCFIFO)
    begin
      if (COUNT == 3'b111) 
        FIFOFULL <= 1'b1;
      else
      begin
        COUNT <=  COUNT +1;
        FIFOEMPTY <= 1'b0;
      end
    end 
    else if (DECFIFO)
    begin
        if (COUNT == 3'b000) 
            FIFOEMPTY <= 1'b1;
        else
        begin
            COUNT <=  COUNT -1;
            FIFOFULL <= 1'b0;
        end
    end 
end

assign clk = (INCFIFO | DECFIFO);

endmodule