/*

AMIGA SDMAC Replacement Project  A3000
Copyright 2022 Mike Taylor

This program is free software: you can redistribute it and/or modifyA
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

module ctrl_reg(DIN,
                _ENA,
                _DS,
                R_W,
                _RST,
                DOUT,
                TCEN,
                PREST,
                PDMD,
                INTEN,
                DDIR,
                IO_DX);

input [5:0] DIN;
input _ENA;     
input _RST;     
input  _DS;
input R_W;

output reg [5:0] DOUT;   
output TCEN;
output PREST;
output PDMD;
output INTEN;
output DDIR;
output IO_DX;


always @(negedge _DS or negedge _RST) begin
    if (!_RST)
    begin
        DOUT <= 5'b00000;    
    end else if (!_ENA && !R_W)
        DOUT <= DIN;
end

assign TCEN     = DOUT[0];
assign PREST    = DOUT[1];
assign PDMD     = DOUT[2];
assign INTEN    = DOUT[3];
assign DDIR     = DOUT[4];
assign IO_DX    = DOUT[5];

endmodule
