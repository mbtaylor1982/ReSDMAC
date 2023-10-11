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
  input DSACK,
  input STERM_,
  input [62:0]E,

  output cpudff4_d
);

assign cpudff4_d =
  E[2] |
  E[3] |
  E[5] |
  E[7] |
  E[8] |
  E[12] |
  E[18] |
  E[19] |
  E[21] |
  E[31] |
  E[34] |
  E[45] |
  E[48] |
  E[55] |
  E[60] |
  E[61] |
  (E[9] & DSACK) |
  (E[50] & DSACK) |
  (E[25] & DSACK) |
  (E[28] & DSACK) |
  (E[30] & DSACK) |
  (E[51] & ~STERM_) |
  (E[46] & ~STERM_) |
  (E[36] & ~STERM_) |
  (E[33] & ~STERM_) |
  (E[39] & ~STERM_) |
  (E[40] & ~STERM_) |
  (E[42] & ~STERM_) |
  (E[43] & ~STERM_) |
  (E[37] & ~STERM_) |
  (E[57] & STERM_) |
  (E[46] & STERM_) |
  (E[23] & DSACK & STERM_) |
  (E[51] & ~DSACK & STERM_) |
  (E[43] & ~DSACK & STERM_);

endmodule