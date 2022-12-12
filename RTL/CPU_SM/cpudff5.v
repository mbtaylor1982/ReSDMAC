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
module cpudff5 (
  input BCLK,
  input CCRESET_,
  
  output cpudff5
);

reg cpudff5_q;
wire cpudff5_d;

assign p5a = ;
assign p5b = ;
assign p5c = ;

assign cpudff5_d = (~(p5a & p5b & p5c));
assign cpudff5 = ~cpudff5_q;

always @(posedge BCLK or negedge CCRESET_) begin
    if (CCRESET_ == 1'b0) begin
        cpudff5_q <= 1'b0;
    end
    else begin
        if (BCLK == 1'b1) begin
            cpudff5_q <= cpudff5_d;
        end
    end
end

endmodule