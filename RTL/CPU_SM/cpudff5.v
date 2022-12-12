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
  input E26, E5, E4, E27, E8, E11,
  input E32, E13, E14, E15, E22, E60,
  input E61, E62, E48, E53, E58,
  input E30_d, E9_d, E28_d, 
  input DSACK,
  input STERM_,
  input E36_s_E47_s, E33_sd_E38_s, E39_s, E40_s_E41_s, E42_s, E37_s_E44_s,
  input E23_sd, 
  input E43_s_E49_sd,
  input E57_s,
  
  output cpudff5_d
);

wire p5a, p5b, p5c;

assign p5a = (~(~(~E26  & ~E5 & ~E4 & ~E27 & ~E8 & ~E11) | ~(~E32  & ~E13 & ~E14 & ~E15 & ~E22 & ~E60) | ~(~E61 & ~E62 & ~E48 & ~E53 & ~E58)) & ~(~(~E30_d & ~E9_d & ~E28_d) & DSACK));
assign p5b = (~(~STERM_& ~(~E36_s_E47_s & ~E33_sd_E38_s & ~E39_s & ~E40_s_E41_s & ~E42_s & ~E37_s_E44_s)));
assign p5c = (~(~(~(~(E23_sd & DSACK) & ~(~DSACK & E43_s_E49_sd) ) | E57_s)& STERM_));

assign cpudff5_d = (~(p5a & p5b & p5c));

endmodule