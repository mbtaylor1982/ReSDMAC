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
module cpudff2 (
  input BCLK,
  input CCRESET_,
  input E1, E11, E16, E17,
  input E26, E27, E31, E32,
  input E35, E55, E58, E61,
  input E25_d,E50_d_E52_d,
  input DSACKa,
  input STERM1_,
  input E43_s_E49_sd, E46_s_E59_s, E51_s_E54_sd,
  input E23_sd, DSACKb,
  input E33_sd_E38_s, E29_sd,
  input E36_s_E47_s, E57_s, E40_s_E41_s,
  input STERM2_,
  
  output cpudff2
);

reg cpudff2_q;
wire cpudff2_d;

assign p2a = (!( !(!E1 & !E11 & !E16 & !E17) | !(!E26 & !E27 & !E31 & !E32) | !(!E35 & !E55 & !E58 & !E61) ) & !(!E25_d & !E50_d_E52_d & DSACKa));
assign p2b = !(!STERM1_ & !(!E43_s_E49_sd & !E46_s_E59_s & !E51_s_E54_sd));
assign p2c = !((!(!(E23_sd & DSACKb) & !(!DSACKb & (E33_sd_E38_s|E43_s_E49_sd|E51_s_E54_sd|E29_sd)))|(E36_s_E47_s|E57_s|E46_s_E59_s|E40_s_E41_s)) & STERM2_);

assign cpudff2_d = (~(p2a & p2b & p2c));
assign cpudff2 = ~cpudff2_q;

always @(posedge BCLK or negedge CCRESET_) begin
    if (CCRESET_ == 1'b0) begin
        cpudff2_q <= 1'b0;
    end
    else begin
        if (BCLK == 1'b1) begin
            cpudff2_q <= cpudff2_d;
        end
    end
end

endmodule