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
module cpudff3 (
  input BCLK,
  input CCRESET_,
  input E4, E10, E21, E27,
  input E34, E32, E35,
  input E56, E62, E45,
  input E20_d, E28_d, E30_d,
  input DSACKa, 
  input E50_d_E52_d, 
  input STERM1_,
  input E36_s_E47_s, E33_sd_E38_s, E39_s, E40_s_E41_s, E42_s, E37_s_E44_s,
  input E23_sd, DSACKb,
  input E51_s_E54_sd, 
  input E46_s_E59_s,

  output cpudff3
);

reg cpudff3_q;
wire cpudff3_d;

assign p3a = (~( ~(~(~E4 & ~E10 & ~E21 & ~E27) | ~(~E34 & ~E32 & ~E35) | ~(~E56 & ~E62 & ~E45)) & ~(~(~E20_d & ~E28_d & ~E30_d) & DSACKa) & ~(E50_d_E52_d & ~DSACKa)));
assign p3b = (~(~STERM1_ & ~(~E36_s_E47_s & ~E33_sd_E38_s & ~E39_s & ~E40_s_E41_s & ~E42_s & ~E37_s_E44_s)));
assign p3c = (~(STERM1_ & ( ~(~(E23_sd & DSACKb) & ~(~DSACKb & (E33_sd_E38_s | E51_s_E54_sd)) ) | (E36_s_E47_s | E46_s_E59_s))));

assign cpudff3_d = (~(p3a & p3b & p3c));
assign cpudff32 = ~cpudff3_q;

always @(posedge BCLK or negedge CCRESET_) begin
    if (CCRESET_ == 1'b0) begin
        cpudff3_q <= 1'b0;
    end
    else begin
        if (BCLK == 1'b1) begin
            cpudff3_q <= cpudff3_d;
        end
    end
end

endmodule