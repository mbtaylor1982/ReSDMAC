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
    input DSACK, nDSACK,
    input STERM_, nSTERM_,
    input [62:0]E,
    input [62:0]nE,

    output cpudff1_d
);
  wire p1a, p1b, p1c;

  assign p1a = 
  (
    (DSACK & (E[25] | E[50] | E[6])) |
    (nDSACK & E[50]) | 
    E[12] |
    E[26] |
    E[53] |
    E[27] |
    E[32] |
    E[48] |
    E[55] |
    E[56] |
    E[58] |
    E[60] |
    E[62]
  );
  
  assign p1b = (nSTERM_ & (E[43] | E[46] | E[51]));

  assign p1c = 
  (
    STERM_ &
    (
      (E[36] | E[37] | E[40] | E[46] | E[57]) |
      (DSACK & E[23]) |
      (nDSACK &  (E[24]| E[29] | E[33] | E[43] | E[51]))
       
    ) 
  );

  assign cpudff1_d = ((p1a | p1b | p1c));

endmodule
