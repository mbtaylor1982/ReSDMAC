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

`timescale 1ns/100ps

`include "RTL/registers.v"
module registers_tb; 

//inputs
reg CLK;
reg [7:0] ADDR;
reg _CS;
reg _AS;
reg _DS;
reg R_W;                   
reg _RST;
reg [31:0] DATA_IN;  

wire [31:0] DATA_OUT;
wire [1:0] _DSACK_REG;

registers dut(
    .CLK (CLK),
    .ADDR (ADDR[6:2]),
    ._CS (_CS),
    ._AS (_AS),
    ._DS (_DS),
    ._RST (_RST),
    .R_W (R_W),
    .DIN (DATA_IN),
    .DOUT (DATA_OUT),
    ._DSACK(_DSACK_REG)
);
    
    initial CLK = 1'b0;
    always #20 CLK = ~CLK;

    initial begin
        $dumpfile("registers_tb.vcd");
        $dumpvars(0, registers_tb);
        
        //initial condistions s0
        _RST = 1'b1;
        _AS = 1'b1;
        _DS = 1'b1;
        _CS = 1'b1;
        R_W = 1'b1;
        ADDR = 8'h0; 
        DATA_IN = 32'h0;
        #10;
        _RST = 1'b0;
        #10;
        _RST = 1'b1;
        #10
        ADDR = 8'h04;   
        _CS = 1'b0;
        R_W = 1'b0;
        #10;//s1
        _AS = 1'b0;
        #10; //s2
        DATA_IN = 32'h00AAAAAA;
        #10; //s3
        _DS = 1'b0;
        #10; //s4
        #10 //s5
        _AS = 1'b1;
        _DS = 1'b1;
        #10
        ADDR = 8'h0;
        _CS = 1'b1;
        DATA_IN = 32'h0;
        #10;
        $finish;
    end
    
    
endmodule