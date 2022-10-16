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
// - File: addr_decoder_tb.v [the file the license is inserted to]
// - Path: /home/mike/EAGLE/projects/SDMAC-Replacement/RTL/tmp/addr_decoder_tb.v [the path to the file]
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

`timescale 1ns/100ps

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

`include "addr_decoder.v"

module addr_decoder_tb; 

//inputs
reg [7:0] ADDR; 
reg _CS; 
reg _AS;

//Outputs
wire _CSS;
wire _CSX0;
wire _CSX1;

addr_decoder dut(
    .ADDR (ADDR),
    ._CS (_CS),
    ._AS (_AS),
    ._CSS (_CSS),
    ._CSX0 (_CSX0),
    ._CSX1 (_CSX1)   
);
     
    initial begin
        $dumpfile("addr_decoder_tb.vcd");
        $dumpvars(0, addr_decoder_tb);
        
        //initial condistions
        _CS = 1; _AS=0; ADDR = 8'h00;           #20

        //SASR Register (Long Word)
        _CS = 1;                         #20
        ADDR = 8'h40;                   #20
        _CS = 0;                         #20
        //SASR Register (Byte)
        _CS = 1;                         #20
        ADDR = 8'h41;                   #20
        _CS = 0;                         #20
        //SCMD Register (Byte)
        _CS = 1;                         #20
        ADDR = 8'h43;                   #20
        _CS = 0;                         #20

        //
        _CS = 1;                         #20
        ADDR = 8'h4C;                   #20
        _CS = 0;                         #20

        //port1a
        _CS = 1;                         #20
        ADDR = 8'h50;                   #20
        _CS = 0;                         #20

        //port2
        _CS = 1;                         #20
        ADDR = 8'h60;                   #20
        _CS = 0;                         #20

        //port1b
        _CS = 1;                         #20
        ADDR = 8'h70;                   #20
        _CS = 0;                         #20
        _CS = 1;                         #20

 

        //_AS n=1
        _CS = 1; _AS=1; ADDR = 8'h00;           #20

        //SASR Register (Long Word)
        _CS = 1;                         #20
        ADDR = 8'h40;                   #20
        _CS = 0;                         #20
        //SASR Register (Byte)
        _CS = 1;                         #20
        ADDR = 8'h41;                   #20
        _CS = 0;                         #20
        //SCMD Register (Byte)
        _CS = 1;                         #20
        ADDR = 8'h43;                   #20
        _CS = 0;                         #20

        //
        _CS = 1;                         #20
        ADDR = 8'h4C;                   #20
        _CS = 0;                         #20

        //port1a
        _CS = 1;                         #20
        ADDR = 8'h50;                   #20
        _CS = 0;                         #20

        //port2
        _CS = 1;                         #20
        ADDR = 8'h60;                   #20
        _CS = 0;                         #20

        //port1b
        _CS = 1;                         #20
        ADDR = 8'h70;                   #20
        _CS = 0;                         #20
        _CS = 1;                         #20
        
        $finish;
    end
    
    
endmodule