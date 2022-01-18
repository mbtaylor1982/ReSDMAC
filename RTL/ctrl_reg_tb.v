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

`include "ctrl_reg.v"

module ctrl_reg_tb; 

//inputs
reg [5:0] DIN; 
reg _ENA; 
reg _DS;
reg R_W;
reg _RST;

//Outputs
wire [5:0] DOUT;
wire TCEN;
wire PREST;
wire PDMD;
wire INTEN;
wire DDIR;
wire IO_DX;

ctrl_reg dut(
    .DIN (DIN),
    ._ENA (_ENA),
    ._DS (_DS),
    .R_W (R_W),
    ._RST (_RST),
    .DOUT (DOUT),    
    .TCEN (TCEN),
    .PREST (PREST),
    .PDMD (PDMD),
    .INTEN (INTEN),
    .DDIR (DDIR),
    .IO_DX (IO_DX)
);
    initial begin
        _DS = 1; 
        _RST = 1; 
        _ENA = 1; 
        R_W = 1;

    end 
     
    always  
        #20  _DS =  ! _DS; 
     
    initial  begin
        $dumpfile("ctrl_reg_tb.vcd");
        $dumpvars(0, ctrl_reg_tb);
    end 
     
    initial  begin
        $display("\ttime,\t_DS,\t_RST,\t_ENA"); 
        $monitor("\t%d,\t%b,\t%b,\t%b",$time, _DS,_RST,_ENA); 
    end 
     
    initial begin
        #10 _RST = 0;
        #10 _RST = 1;
        #70 R_W = 0; 
        #10 _ENA = 0;
        #40 DIN = 5'b10101;
        #10 DIN = 5'bxxxxx;
        #10 _ENA = 1;

        #10 _RST = 0;
        #10 _RST = 1;
        #70 R_W = 1; 
        #10 _ENA = 0;
        #40 DIN = 5'b10101;
        #10 DIN = 5'bxxxxx;
        #80  $finish;
    end
    
   
    
endmodule