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
  input DSACK, nDSACK,
  input STERM_, nSTERM_,
  input [62:0]E,
  input [62:0]nE,
  
  output cpudff5_d
);

wire p5a, p5b, p5c;

assign p5a = 
(
  ~(
    ~(nE[26] & nE[5] & nE[4] & nE[27] & nE[8] & nE[11]) | 
    ~(nE[32] & nE[13] & nE[14] & nE[15] & nE[22] & nE[60]) | 
    ~(nE[61] & nE[62] & nE[48] & nE[53] & nE[58])
  ) & 
  ~(~(nE[30] & nE[9] & nE[28]) & DSACK)
);

assign p5b = 
(
  ~(nSTERM_& 
    ~(nE[36] & nE[33] & nE[39] & nE[40] & nE[42] & nE[37])
  )
);

assign p5c = 
(
  ~(
    (
      ~(
        ~(E[23] & DSACK) & 
        ~(nDSACK & E[43]) 
      ) | 
      E[57]
    )& 
    STERM_
  )
);

assign cpudff5_d = (~(p5a & p5b & p5c));

endmodule