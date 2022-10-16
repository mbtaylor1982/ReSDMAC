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

`include "RTL/RESDMAC.v"
module RESDMAC_tb; 

//inputs
reg CLK;
reg [7:0] ADDR;
reg _CS;
reg _AS_REG;
reg _DS_REG;
reg R_W_REG;                   
reg _RST;
reg [31:0] DATA_OUT;       

//Outputs
wire _CSS;
wire _CSX0;
wire _CSX1;
wire _IOR;                 //False on Read
wire _IOW;                 //False on Write
wire _AS_WIRE;
wire _DS_WIRE;
wire R_W_WIRE;

wire [31:0] DATA_IN;     // CPU data output.
wire [31:0] DATA_PINS;     // CPU data output.

//DATA PORT
wire  [15:0] PD_PORT;        //Peripheral Data bus
reg [15:0] PD_PORT_OUT;
wire [15:0] PD_PORT_IN;

assign _AS_WIRE = _AS_REG;
assign _DS_WIRE = _DS_REG;
assign R_W_WIRE = R_W_REG;
assign DATA_IN = DATA_PINS;

assign PD_PORT_IN = PD_PORT; 
assign DATA_PINS =  (R_W_REG == 1'b0) ? DATA_OUT : 32'hZZZZZZZZ;

assign PD_PORT = R_W_REG ? PD_PORT_OUT : 16'hZZZZ;

RESDMAC dut(
    .SCLK (CLK),
    .ADDR (ADDR[6:2]),
    ._CS (_CS),
    ._AS (_AS_WIRE),
    ._DS (_DS_WIRE),
    .R_W (R_W_WIRE),
    ._RST (_RST),
    .DATA (DATA_PINS),
    ._CSS (_CSS),
    ._CSX0 (_CSX0),
    ._CSX1 (_CSX1),
    .PD_PORT (PD_PORT),
    ._IOR (_IOR),
    ._IOW (_IOW)
);
    initial CLK = 1'b0;
    always #20 CLK = ~CLK;

    initial begin
        $dumpfile("RESDMAC_tb.vcd");
        $dumpvars(0, RESDMAC_tb);
        
        //initial condistions s0
        _RST <= 1'b1;
        _AS_REG <= 1'b1;
        _DS_REG <= 1'b1;
        _CS <= 1'b1;
        R_W_REG <= 1'b1;
        ADDR <= 8'hz; 
        DATA_OUT <= 32'hz;
        #20;
        _RST <= 1'b0;
        #20;
        _RST <= 1'b1;
        #20 //s0
        ADDR <= 8'h40;   
        _CS <= 1'b0;
        R_W_REG <= 1'b0;
        #20;//s1
        _AS_REG <= 1'b0;
        #20; //s2
        DATA_OUT <= 32'haa55ff40;
        #20; //s3
        _DS_REG <= 1'b0;
        #20 //W1
        #20 //W2
        #20 //W3
        #20 //W4
        #20; //s4
        #20 //s5
        _AS_REG <= 1'b1;
        _DS_REG <= 1'b1;
        #20
        ADDR <= 8'hz;
        _CS <= 1'b1;
        DATA_OUT <= 32'hz;
        R_W_REG <= 1'b1;
        #20;

        //initial condistions s0
        _RST <= 1'b1;
        _AS_REG <= 1'b1;
        _DS_REG <= 1'b1;
        _CS <= 1'b1;
        R_W_REG <= 1'b0;
        ADDR <= 8'h0; 
        PD_PORT_OUT <= 16'hzz;
        #20;
        _RST <= 1'b0;
        #20;
        _RST <= 1'b1;
        #20
        ADDR <= 8'h40;   
        _CS <= 1'b0;
        R_W_REG <= 1'b1;
        #20;//s1
        _AS_REG <= 1'b0;
        _DS_REG <= 1'b0;
        #20; //s2
        #20; //s3        
        #20 //W1
        #20 //W2
        #20 //W3
        #20 //W4
        #20 //W5
        #20 //W6
        #20 //W7
        PD_PORT_OUT <= 16'h41;
        #20 //W8
        #20 //W9
        #20 //W10
        #20; //s4
        #20 //s5
        _AS_REG <= 1'b1;
        _DS_REG <= 1'b1;
        #20
        ADDR <= 8'h0;
        _CS <= 1'b1;
        R_W_REG <= 1'b0;
        #20;       
        PD_PORT_OUT <= 16'hzz;
        #20; 
      

        //initial condistions s0
        _RST <= 1'b1;
        _AS_REG <= 1'b1;
        _DS_REG <= 1'b1;
        _CS <= 1'b1;
        R_W_REG <= 1'b1;
        ADDR <= 8'h0; 
        DATA_OUT <= 32'h0;
        #20;
        _RST <= 1'b0;
        #20;
        _RST <= 1'b1;
        #20
        ADDR <= 8'h04;   
        _CS <= 1'b0;
        R_W_REG <= 1'b0;
        #20;//s1
        _AS_REG <= 1'b0;
        #20; //s2
        DATA_OUT <= 32'haa55ff70;
        #20; //s3
        _DS_REG <= 1'b0;
        #20; //s4
        #20 //s5
        _AS_REG <= 1'b1;
        _DS_REG <= 1'b1;
        #20
        ADDR <= 8'h0;
        _CS <= 1'b1;
        DATA_OUT <= 32'h0;
        R_W_REG <= 1'b1;
        #20;        

        //initial condistions s0
        _RST <= 1'b1;
        _AS_REG <= 1'b1;
        _DS_REG <= 1'b1;
        _CS <= 1'b1;
        R_W_REG <= 1'b1;
        ADDR <= 8'h0; 
        DATA_OUT <= 32'h0;
        #20;
        _RST <= 1'b1;
        #20;
        _RST <= 1'b1;
        #20
        ADDR <= 8'h04;   
        _CS <= 1'b0;
        R_W_REG <= 1'b1;
        #20;//s1
        _AS_REG <= 1'b0;
        #20; //s2
        //DATA_OUT <= 32'haa55ff70;
        #20; //s3
        _DS_REG <= 1'b0;
        #20; //s4
        #20 //s5
        _AS_REG <= 1'b1;
        _DS_REG <= 1'b1;
        #20;
        ADDR <= 8'h0;
        _CS <= 1'b1;
        //DATA_OUT <= 32'h0;
        R_W_REG <= 1'b1;
        #20;
        $finish;
    end
    
    
endmodule