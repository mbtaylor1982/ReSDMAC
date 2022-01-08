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

module addr_decoder(ADDR,
                    CS,
                    CSS,
                    CSX0,
                    CSX1);

input [7:0] ADDR;   // CPU address Bus
input CS;           // SDMAC Chip Select !SCSI from Fat Garry.

output CSS;         // Port 0 chip select (SCSI WD33C93A)
output CSX0;        // Port 1A and 1B chip select (XT/ ATA)
output CSX1;        // Port 2 chip select (XT)

localparam PORT0_LOW = 8'h40;
localparam PORT0_HIGH = 8'h4C;

localparam PORT1A_LOW = 8'h50;
localparam PORT1A_HIGH = 8'h5C;

localparam PORT1B_LOW = 8'h70;
localparam PORT1B_HIGH = 8'h7C;

localparam PORT2_LOW = 8'h60;
localparam PORT2_HIGH = 8'h6C;

assign CSS  = ((ADDR >= PORT0_LOW && ADDR < PORT0_HIGH) & !CS) ? 1'b0 : 1'b1;
assign CSX0 = (((ADDR >= PORT1A_LOW && ADDR < PORT1A_HIGH) | (ADDR >= PORT1B_LOW && ADDR < PORT1B_HIGH)) & !CS) ? 1'b0 : 1'b1;
assign CSX1 = ((ADDR >= PORT2_LOW && ADDR < PORT2_HIGH) & !CS) ? 1'b0 : 1'b1;

endmodule
