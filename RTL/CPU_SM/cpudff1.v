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
    input DSACK,
    input STERM_,
    input [62:0]E,

    output cpudff1_d
);
  assign cpudff1_d = 
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
    E[62] |
    (E[6] & DSACK) |
    (E[25] & DSACK) | 
    (E[50] & DSACK) | 
    (E[50] & ~DSACK) | 
    (E[43] & ~STERM_) | 
    (E[46] & ~STERM_) | 
    (E[51] & ~STERM_) |
    (E[36] & STERM_) | 
    (E[37] & STERM_) | 
    (E[40] & STERM_) | 
    (E[46] & STERM_) | 
    (E[57] & STERM_) |
    (E[23] & DSACK & STERM_) |
    (E[24] & ~DSACK & STERM_) | 
    (E[29] & ~DSACK & STERM_) | 
    (E[33] & ~DSACK & STERM_) | 
    (E[43] & ~DSACK & STERM_) | 
    (E[51] & ~DSACK & STERM_);

endmodule
