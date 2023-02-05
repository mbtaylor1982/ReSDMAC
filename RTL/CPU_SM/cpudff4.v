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
  input DSACK, nDSACK,
  input STERM_, nSTERM_,
  input [62:0]E,
  input [62:0]nE,
   
  output cpudff4_d
);
wire p4a, p4b, p4c;

assign p4a = 
(
  ~(
    ~(nE[61] & nE[60] & nE[2] & nE[3] & nE[5] & nE[7] & nE[12] & nE[8]) | 
    ~(nE[55] & nE[18] & nE[19] & nE[48] & nE[21] & nE[31] & nE[34] & nE[45])
  ) & 
  ~(
    ~(nE[50] & nE[9] & nE[25] & nE[28] & nE[30]) 
    & DSACK
  )
);

assign p4b = 
(
  ~(nSTERM_ & 
      (
        ~(nE[51] & nE[46] & nE[36]) | 
        ~(nE[33] & nE[39] & nE[40]) | 
        ~(nE[42] & nE[43] & nE[37])
      )
  )
);

assign p4c = 
(
  ~(
    (
      ~(
        ~(E[23] & DSACK) & 
        ~(nDSACK & 
          (E[51] | E[43])
        )
      ) | 
      (E[57] | E[46])
    )& 
    STERM_
  )
);

assign cpudff4_d = (~(p4a & p4b & p4c));

endmodule