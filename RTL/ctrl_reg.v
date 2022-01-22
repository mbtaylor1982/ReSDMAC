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

output  [5:0] DOUT;   
output TCEN;
output PREST;
output PDMD;
output INTEN;
output DDIR;
output IO_DX;

reg [5:0] CTRL_REGISTER = 5'b00000;
reg [5:0] data_out      = 5'b00000;


always @(negedge _DS or negedge _RST) begin
    if (_RST == 1'b0)
    begin
        CTRL_REGISTER   <= 5'b00000;
        data_out        <= 5'b00000;
    end 
    else 
    if (_ENA == 1'b0) 
    begin
        case (R_W) 
            1'b0    : CTRL_REGISTER <= DIN;
            1'b1    : data_out      <= CTRL_REGISTER;
            default : data_out      <= 5'b00000;
        endcase
    end
end

assign TCEN     = CTRL_REGISTER[0];
assign PREST    = CTRL_REGISTER[1];
assign PDMD     = CTRL_REGISTER[2];
assign INTEN    = CTRL_REGISTER[3];
assign DDIR     = CTRL_REGISTER[4];
assign IO_DX    = CTRL_REGISTER[5];

assign DOUT = data_out;

endmodule
