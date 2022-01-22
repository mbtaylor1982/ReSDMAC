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

module addr_decoder(ADDR,
                    _CS,
                    _AS,
                    _CSS,
                    _CSX0,
                    _CSX1,
                    _DAWR,
                    _WTC,
                    _CNTR,
                    _ST_DMA,
                    _FLUSH,
                    _CLR_INT,
                    _ISTR,
                    _SP_DMA);

input [6:2] ADDR;    // CPU address Bus
input _CS;           // SDMAC Chip Select !SCSI from Fat Garry.
input _AS;           // CPU Address Strobe.

output _CSS;         // Port 0 chip select (SCSI WD33C93A)
output _CSX0;        // Port 1A and 1B chip select (XT/ ATA)
output _CSX1;        // Port 2 chip select (XT)

//Select Signals for internal registers.
output _DAWR;
output _WTC;
output _CNTR;
output _ST_DMA;
output _FLUSH;
output _CLR_INT;
output _ISTR;
output _SP_DMA;

reg [11:0] SELECT;

always @(ADDR) begin
    case (ADDR)
      5'b00000 : SELECT = 12'b011111111111; // $00 DAWR
      5'b00001 : SELECT = 12'b101111111111; // $04 WTC
      5'b00010 : SELECT = 12'b110111111111; // $08 CNTR
      //Address Conuter Register in Ramsey     $0C ACR
      5'b00100 : SELECT = 12'b111011111111; // $10 ST_DMA
      5'b00101 : SELECT = 12'b111101111111; // $14 FLUSH
      5'b00110 : SELECT = 12'b111110111111; // $18 CLR_INT
      5'b00111 : SELECT = 12'b111111011111; // $1C ISTR
      5'b01111 : SELECT = 12'b111111101111; // $3C SP_DMA
      
      //PORT 0
      5'b10000 : SELECT = 12'b111111110111; // $40
      5'b10001 : SELECT = 12'b111111110111; // $44
      5'b10010 : SELECT = 12'b111111110111; // $48
      5'b10011 : SELECT = 12'b111111110111; // $4C
      
      //PORT 1A
      5'b10100 : SELECT = 12'b111111111011; // $50
      5'b10101 : SELECT = 12'b111111111011; // $54
      5'b10110 : SELECT = 12'b111111111011; // $58
      5'b10111 : SELECT = 12'b111111111011; // $5C
      
      //PORT 2
      5'b11000 : SELECT = 12'b111111111101; // $60
      5'b11001 : SELECT = 12'b111111111101; // $64
      5'b11010 : SELECT = 12'b111111111101; // $68
      5'b11011 : SELECT = 12'b111111111101; // $6C

      //PORT 1B
      5'b11100 : SELECT = 12'b111111111110; // $70
      5'b11101 : SELECT = 12'b111111111110; // $74
      5'b11110 : SELECT = 12'b111111111110; // $78
      5'b11111 : SELECT = 12'b111111111110; // $7C
      
      default  : SELECT = 12'b111111111111; 
    endcase
end

wire _ADDR_VALID;
assign _ADDR_VALID = _CS || _AS;

assign _DAWR    = SELECT[11] || _ADDR_VALID;
assign _WTC     = SELECT[10] || _ADDR_VALID;
assign _CNTR    = SELECT[9]  || _ADDR_VALID;
assign _ST_DMA  = SELECT[8]  || _ADDR_VALID;
assign _FLUSH   = SELECT[7]  || _ADDR_VALID;
assign _CLR_INT = SELECT[6]  || _ADDR_VALID;
assign _ISTR    = SELECT[5]  || _ADDR_VALID;
assign _SP_DMA  = SELECT[4]  || _ADDR_VALID;

assign _CSS     = SELECT[3]  || _ADDR_VALID;
assign _CSX0    = (SELECT[0] && SELECT[2])  || _ADDR_VALID; 
assign _CSX1    = SELECT[1]  || _ADDR_VALID;

endmodule
