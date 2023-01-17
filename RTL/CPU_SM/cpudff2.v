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
  input E1, E11, E16, E17,
  input E26, E27, E31, E32,
  input E35, E55, E58, E61,
  input E25_d,E50_d_E52_d,
  input DSACK,
  input STERM_,
  input E43_s_E49_sd, E46_s_E59_s, E51_s_E54_sd,
  input E23_sd, 
  input E33_sd_E38_s, E29_sd,
  input E36_s_E47_s, E57_s, E40_s_E41_s,
    
  output cpudff2_d
);
wire p2a, p2b, p2c;

assign p2a = 
(
  ~( 
    ~(~E1 & ~E11 & ~E16 & ~E17) | 
    ~(~E26 & ~E27 & ~E31 & ~E32) | 
    ~(~E35 & ~E55 & ~E58 & ~E61) 
  ) & 
  ~(~(~E25_d & ~E50_d_E52_d) & DSACK)
);

assign p2b = 
~(
  ~STERM_ & 
  ~(~E43_s_E49_sd & ~E46_s_E59_s & ~E51_s_E54_sd)
);

assign p2c = 
~(
  (
    ~(
      ~(E23_sd & DSACK) & 
      ~(
        ~DSACK & 
        (E33_sd_E38_s|E43_s_E49_sd|E51_s_E54_sd|E29_sd)
      )
    )|
    (E36_s_E47_s|E57_s|E46_s_E59_s|E40_s_E41_s)
  ) & 
  STERM_
);

assign cpudff2_d = (~(p2a & p2b & p2c));

endmodule