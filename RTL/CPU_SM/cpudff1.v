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
module cpudff1 (
  input BCLK,
  input CCRESET_,

  input DSACKa,
  input E12,
  input E25_d,
  input E26,
  input E27,
  input E32,
  input E48,
  input E50_d_E52_d,
  input E53,
  input E55,
  input E56,
  input E58,
  input E60,
  input E62,
  input E6_d,
  input E43_s_E49_sd,
  input E46_s_E59_s,
  input E51_s_E54_sd,
  input STERM1_,
  input DSACKb,
  input E23_sd,
  input E24_sd,
  input E29_sd,
  input E33_sd_E38_s,
  input E36_s_E47_s,
  input E37_s_E44_s,
  input E40_s_E41_s,
  input E57_s,

  output cpudff1
);

reg cpudff1_q;
wire cpudff1_d;

assign p1a = (~ (DSACKa & ~ (~ E25_d & ~ E50_d_E52_d & ~ E6_d)) & ~ (~ DSACKa & E50_d_E52_d) & ~ (~ (~ E12 & ~ E26 & ~ E53) | ~ (~ E27 & ~ E32 & ~ E48 & ~ E55) | ~ (~ E56 & ~ E58 & ~ E60 & ~ E62)));
assign p1b = ~ (~ (~ E43_s_E49_sd & ~ E46_s_E59_s & ~ E51_s_E54_sd) & ~ STERM1_);
assign p1c = ~ ((~ (~ (DSACKb & E23_sd) & ~ (~ DSACKb & (E24_sd | E29_sd | E33_sd_E38_s | E43_s_E49_sd | E51_s_E54_sd))) | E36_s_E47_s | E37_s_E44_s | E40_s_E41_s | E46_s_E59_s | E57_s) & STERM1_);

assign cpudff1_d = (~(p1a & p1b & p1c));
assign cpudff1 = ~cpudff1_q;


always @(posedge BCLK or negedge CCRESET_) begin
    if (CCRESET_ == 1'b0) begin
        cpudff1_q <= 1'b0;
    end
    else begin
        if (BCLK == 1'b1) begin
            cpudff1_q <= cpudff1_d;
        end
    end
end

endmodule