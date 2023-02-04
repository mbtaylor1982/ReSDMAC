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
  input DSACK, STERM_,
  input [62:0]E,
  input [62:0]nE,
    
  output cpudff2_d
);
wire p2a, p2b, p2c;

assign p2a = 
(
  ~( 
    ~(nE[1] & nE[11] & nE[16] & nE[17]) | 
    ~(nE[26] & nE[27] & nE[31] & nE[32]) | 
    ~(nE[35] & nE[55] & nE[58] & nE[61]) 
  ) & 
  ~(~(nE[25] & nE[50]) & DSACK)
);

assign p2b = 
~(
  ~STERM_ & 
  ~(nE[43] & nE[46] & nE[51])
);

assign p2c = 
~(
  (
    ~(
      ~(E[23] & DSACK) & 
      ~(
        ~DSACK & 
        (E[33]|E[43]|E[51]|E[29])
      )
    )|
    (E[36]|E[57]|E[46]|E[40])
  ) & 
  STERM_
);

assign cpudff2_d = (~(p2a & p2b & p2c));

endmodule