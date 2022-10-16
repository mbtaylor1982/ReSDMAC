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

/*
// 
// Copyright (C) 2022  mike
// This file is part of RE-SDMAC <https://github.com/chiditarod/dogtag>.
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

/*
// 
// Copyright (C) 2022  mike
// This file is part of dogtag <https://github.com/chiditarod/dogtag>.
// 
// RESDMAC is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// RESDMAC is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with dogtag.  If not, see <http://www.gnu.org/licenses/>.
 */

/*
// This is a license template.
// 
// Some variables:
// - File: addr_decoder.v [the file the license is inserted to]
// - Path: /home/mike/EAGLE/projects/SDMAC-Replacement/RTL/tmp/addr_decoder.v [the path to the file]
// - CurrentYear: 2022 [the current year]
// - CurrentMonth: 9 [the current month]
// - CurrentDay: 0 [the current day]
// - CreationYear: 2022 [the year the file was created]
// - CreationMonth: 9 [the month the file was created]
// - CreationDay: 0 [the day the file was created]
// - Date: Sun Oct 16 2022 [the current date]
// - Username: mike [the name of the current user logged in]
// - CopyrightYear: 2022 [the year that should be used for copyright notices]
// 
// Note: You can use environment variables with: %(#ENVIRONMENT_VAR).
 */

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
                    _CSX1);

input [7:0] ADDR;    // CPU address Bus
input _CS;           // SDMAC Chip Select !SCSI from Fat Garry.
input _AS;           // CPU Address Strobe.

output _CSS;         // Port 0 chip select (SCSI WD33C93A)
output _CSX0;        // Port 1A and 1B chip select (XT/ ATA)
output _CSX1;        // Port 2 chip select (XT)

reg [3:0] SELECT;

always @(ADDR) begin
    case (ADDR)     
      //PORT 0
      8'h40 : SELECT <= 4'b0111; // $40
      8'h44 : SELECT <= 4'b0111; // $44
      8'h48 : SELECT <= 4'b0111; // $48
      8'h4C : SELECT <= 4'b0111; // $4C
      
      //PORT 1A
      8'h50 : SELECT <= 4'b1011; // $50
      8'h54 : SELECT <= 4'b1011; // $54
      8'h58 : SELECT <= 4'b1011; // $58
      8'h53 : SELECT <= 4'b1011; // $5C
      
      //PORT 2
      8'h60 : SELECT <= 4'b1101; // $60
      8'h64 : SELECT <= 4'b1101; // $64
      8'h68 : SELECT <= 4'b1101; // $68
      8'h6C : SELECT <= 4'b1101; // $6C

      //PORT 1B
      8'h70 : SELECT <= 4'b1110; // $70
      8'h74 : SELECT <= 4'b1110; // $74
      8'h78 : SELECT <= 4'b1110; // $78
      8'h7C : SELECT <= 4'b1110; // $7C
      
      default  : SELECT <= 4'b1111; 
    endcase
end

wire _ADDR_VALID;
assign _ADDR_VALID = _CS || _AS;

assign _CSS     = SELECT[3]  || _ADDR_VALID;
assign _CSX0    = (SELECT[0] && SELECT[2])  || _ADDR_VALID; 
assign _CSX1    = SELECT[1]  || _ADDR_VALID;

endmodule
