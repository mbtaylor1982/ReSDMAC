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
  input DSACK, STERM_,
  input [62:0]E,
  input [62:0]nE,

  output cpudff3_d
);
wire p3a, p3b, p3c;

assign p3a = 
(
  ~( 
    ~(
      ~(nE[4] & nE[10] & nE[21] & nE[27]) | 
      ~(nE[34] & nE[32] & nE[35]) | 
      ~(nE[56] & nE[62] & nE[45])
    ) & 
    ~(
      ~(
        (nE[20] & nE[28] & nE[30]) & 
        DSACK
      )
    ) & 
    ~(E[50] & ~DSACK)
  )
);

assign p3b = 
(
  ~(
    ~STERM_ & 
    ~(nE[36] & nE[33] & nE[39] & nE[40] & nE[42] & nE[37])
  )
);

assign p3c = 
(
  ~(STERM_ & 
    ( 
      ~(
        ~(E[23] & DSACK) & 
        ~(~DSACK & 
          (E[33] | E[51])
        ) 
      ) | 
      (E[36] | E[46])
    )
  )
);

assign cpudff3_d = (~(p3a & p3b & p3c));

endmodule