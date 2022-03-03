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

`include "io_port.v"

module io_port_tb; 

//inputs
reg _ENA;                  
reg R_W;                   
reg [31:0] DATA_IN;       
 

reg [15:0] P_DATA_TX;
wire [15:0] P_DATA_RX;
//Outputs
wire _IOR;                 //False on Read
wire _IOW;                 //False on Write

wire [31:0] DATA_OUT;     // CPU data output.

//DATA PORT
wire  [15:0] P_DATA;        //Peripheral Data bus

assign P_DATA = R_W ? P_DATA_TX : 16'hzzzz;
assign P_DATA_RX = P_DATA;

io_port dut(
    ._ENA (_ENA),
    .R_W (R_W),
    .DATA_IN (DATA_IN),
    ._IOR (_IOR), 
    ._IOW (_IOW),
    .DATA_OUT (DATA_OUT),
    .P_DATA (P_DATA)
);
     
    initial begin
        $dumpfile("io_port_tb.vcd");
        $dumpvars(0, io_port_tb);
        
        //initial condistions
        R_W = 1; _ENA = 1; DATA_IN = 32'h0000_0000;      #20

        // test P_DATA output 8 bit
        R_W = 0 ;                       #20
        _ENA = 1;                       #20
        DATA_IN = 32'h0000_00AA;        #20
        _ENA = 0;                       #20

        // test P_DATA output 16 bit
                 
        R_W = 0;                        #20
        _ENA = 1;                       #20
        DATA_IN = 32'h0000_AAAA;        #20
        DATA_IN = 32'h0000_0000;        #20
        _ENA = 0;                       #20
   
        
        // test P_DATA input 8 bit
        _ENA = 0;  R_W = 1;             #20      
        _ENA = 1;                       #20
        P_DATA_TX = 16'h0055;           #20
        _ENA = 0;                       #20
       
       // test P_DATA input 16 bit
        R_W = 1;                        #20      
        _ENA = 1;                       #20
        P_DATA_TX = 16'h5555;           #20
        _ENA = 0;                       #20

      
        #40000 $finish;
    end
    
    
endmodule