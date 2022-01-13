/*

AMIGA SDMAC Replacement Project  A3000
Copyright 2022 Mike Taylor

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

*/

module io_port(_ENA,
                R_W,
                DATA_IN,
                P_DATA,
                _IOR,
                _IOW,
                DATA_OUT);

input _ENA;                  // Port Enable
input R_W;                   // Read Write Control
input [31:0] DATA_IN;       // CPU data input

inout [15:0] P_DATA;        //Peripheral Data bus

output _IOR;                 //False on Read
output _IOW;                 //False on Write

output [31:0] DATA_OUT;     // CPU data output.

assign _IOR = !R_W;
assign _IOW = R_W;

assign P_DATA = _ENA ? 16'hzzzz : DATA_IN[15:0]; 
assign DATA_OUT = {P_DATA, P_DATA};
endmodule

