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
reg CS; 

//Outputs
wire CSS;
wire CSX0;
wire CSX1;

addr_decoder dut(
    .ADDR (ADDR),
    .CS (CS),
    .CSS (CSS),
    .CSX0 (CSX0),
    .CSX1 (CSX1)
);
     
    initial begin
        $dumpfile("addr_decoder_tb.vcd");
        $dumpvars(0, addr_decoder_tb);
        
        //initial condistions
        CS = 1; ADDR = 8'h00;           #20

        //SASR Register (Long Word)
        CS = 1;                         #20
        ADDR = 8'h40;                   #20
        CS = 0;                         #20
        //SASR Register (Byte)
        CS = 1;                         #20
        ADDR = 8'h41;                   #20
        CS = 0;                         #20
        //SCMD Register (Byte)
        CS = 1;                         #20
        ADDR = 8'h43;                   #20
        CS = 0;                         #20

        //
        CS = 1;                         #20
        ADDR = 8'h4C;                   #20
        CS = 0;                         #20

        //port1a
        CS = 1;                         #20
        ADDR = 8'h50;                   #20
        CS = 0;                         #20

        //port2
        CS = 1;                         #20
        ADDR = 8'h60;                   #20
        CS = 0;                         #20

        //port1b
        CS = 1;                         #20
        ADDR = 8'h70;                   #20
        CS = 0;                         #20
        CS = 1;                         #20

        #40000 $finish;
    end
    
    
endmodule