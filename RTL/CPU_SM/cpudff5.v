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
  input DSACK,
  input STERM_,
  input [62:0]E,

  output cpudff5_d
);

assign cpudff5_d =
  E[5] |
  E[4] |
  E[8] |
  E[11] |
  E[26] |
  E[27] |
  E[32] |
  E[13] |
  E[14] |
  E[15] |
  E[22] |
  E[60] |
  E[61] |
  E[62] |
  E[48] |
  E[53] |
  E[58] |
  (E[9] & DSACK) |
  (E[30] & DSACK) |
  (E[28] & DSACK) |
  (E[36] & ~STERM_) |
  (E[33] & ~STERM_) |
  (E[39] & ~STERM_) |
  (E[40] & ~STERM_) |
  (E[42] & ~STERM_) |
  (E[37] & ~STERM_) |
  (E[23] & DSACK & STERM_) |
  (E[43] & ~DSACK & & STERM_) |
  (E[57] & STERM_);

endmodule