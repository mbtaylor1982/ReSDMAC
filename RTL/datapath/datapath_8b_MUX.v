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
module datapath_8b_MUX( 
    input [7:0] A,
    input [7:0] B,
    input [7:0] C,
    input [7:0] D,
    input [7:0] E,
    input [7:0] F,

    input [5:0] S,

    output reg [7:0] Z
    
);

always @(A,B,C,D,E,F,S) begin

    case (S)
        6'b000001 : Z = A;
        6'b000010 : Z = B;
        6'b000100 : Z = C;
        6'b001000 : Z = D;
        6'b010000 : Z = E;
        6'b100000 : Z = F;
        default : Z = 8'b00000000; 
    endcase
    
end

endmodule
