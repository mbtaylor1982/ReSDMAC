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
  input E61, E60, E2, E3, E5, E7, E12, E8,
  input E55, E18, E19, E48, E21, E31, E34, E45,
  input E50_d_E52_d, E9_d, E25_d, E28_d, E30_d,
  input DSACKa,
  input STERM1,
  inout E51_s_E54_sd, E46_s_E59_s, E36_s_E47_s, 
  input E33_sd_E38_s, E39_s, E40_s_E41_s, 
  input E42_s, E43_s_E49_sd, E37_s_E44_s,
  input E23_sd, DSACKb,
  input E51_s_E54_sd, E43_s_E49_sd,
  input E57_s, E46_s_E59_s,
  input STERM2_,
  
  output cpudff4
);

reg cpudff4_q;
wire cpudff4_d;

assign p4a = (~(~(~E61 & ~E60 & ~E2 & ~E3 & ~E5 & ~E7 & ~E12 & ~E8) | ~(~E55 & ~E18 & ~E19 & ~E48 & ~E21 & ~E31 & ~E34 & ~E45)) & ~(~(~E50_d_E52_d & ~E9_d & ~E25_d & ~E28_d & ~E30_d) & ) DSACKa);
assign p4b = (~(~STERM1_ & (~(~E51_s_E54_sd & ~E46_s_E59_s & #E36_s_E47_s) | ~(E33_sd_E38_s & ~E39_s & ~E40_s_E41_s) | ~(~E42_s & ~E43_s_E49_sd & ~E37_s_E44_s))));
assign p4c = (~((~(~(E23_sd & DSACKb) & ~(~DSACKb & (E51_s_E54_sd | E43_s_E49_sd))) | (E57_s | E46_s_E59_s))& STERM2_));

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