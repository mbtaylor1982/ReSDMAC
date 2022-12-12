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
module cpudff4 (
  input BCLK,
  input CCRESET_,
  
  output cpudff4
);

reg cpudff4_q;
wire cpudff4_d;

assign p4a = ;
assign p4b = ;
assign p4c = ;

assign cpudff4_d = (~(p4a & p4b & p4c));
assign cpudff4 = ~cpudff4_q;

always @(posedge BCLK or negedge CCRESET_) begin
    if (CCRESET_ == 1'b0) begin
        cpudff4_q <= 1'b0;
    end
    else begin
        if (BCLK == 1'b1) begin
            cpudff4_q <= cpudff4_d;
        end
    end
end

endmodule