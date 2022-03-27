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

//`include "RTL/io_port.v"
module io_port_w_tb; 

//inputs
reg CLK;
reg [7:0] ADDR;
reg _CS;
reg _AS;
reg _DS;
reg R_W;                   
reg _RST;
reg [31:0] DATA_IN;       
reg [15:0] P_DATA_TX;

//Outputs
wire _CSS;
wire _CSX0;
wire _CSX1;
wire _IOR;                 //False on Read
wire _IOW;                 //False on Write
wire [31:0] DATA_OUT;     // CPU data output.
wire [15:0] P_DATA_RX;

//DATA PORT
wire  [15:0] P_DATA;        //Peripheral Data bus

assign P_DATA = R_W ? P_DATA_TX : 16'hzzzz;
assign P_DATA_RX = P_DATA;

io_port dut(
    .CLK (CLK),
    .ADDR (ADDR[6:2]),
    ._CS (_CS),
    ._AS (_AS),
    ._DS (_DS),
    .R_W (R_W),
    ._RST (_RST),
    .DATA_IN (DATA_IN),
    .DATA_OUT (DATA_OUT),
    ._CSS (_CSS),
    ._CSX0 (_CSX0),
    ._CSX1 (_CSX1),
    .P_DATA (P_DATA),
    ._IOR (_IOR),
    ._IOW (_IOW)
);
    initial CLK = 1'b0;
    always #20 CLK = ~CLK;

    initial begin
        $dumpfile("io_port_write_tb.vcd");
        $dumpvars(0, io_port_tb);
        
        //initial condistions s0
        _RST <= 1'b1;
        _AS <= 1'b1;
        _DS <= 1'b1;
        _CS <= 1'b1;
        R_W <= 1'b1;
        ADDR <= 8'h0; 
        DATA_IN <= 32'h0;
        #20;
        _RST <= 1'b0;
        #20;
        _RST <= 1'b1;
        #20 //s0
        ADDR <= 8'h40;   
        _CS <= 1'b0;
        R_W <= 1'b0;
        #20;//s1
        _AS <= 1'b0;
        #20; //s2
        DATA_IN <= 32'haa55ff40;
        #20; //s3
        _DS <= 1'b0;
        #20; //s4
        #20 //s5
        _AS <= 1'b1;
        _DS <= 1'b1;
        #20
        ADDR <= 8'h0;
        _CS <= 1'b1;
        DATA_IN <= 32'h0;
        R_W <= 1'b1;
        #20;

        //initial condistions s0
        _RST <= 1'b1;
        _AS <= 1'b1;
        _DS <= 1'b1;
        _CS <= 1'b1;
        R_W <= 1'b1;
        ADDR <= 8'h0; 
        DATA_IN <= 32'h0;
        #20;
        _RST <= 1'b0;
        #20;
        _RST <= 1'b1;
        #20
        ADDR <= 8'h50;   
        _CS <= 1'b0;
        R_W <= 1'b0;
        #20;//s1
        _AS <= 1'b0;
        #20; //s2
        DATA_IN <= 32'haa55ff50;
        #20; //s3
        _DS <= 1'b0;
        #20; //s4
        #20 //s5
        _AS <= 1'b1;
        _DS <= 1'b1;
        #20
        ADDR <= 8'h0;
        _CS <= 1'b1;
        DATA_IN <= 32'h0;
        R_W <= 1'b1;
        #20;

        //initial condistions s0
        _RST <= 1'b1;
        _AS <= 1'b1;
        _DS <= 1'b1;
        _CS <= 1'b1;
        R_W <= 1'b1;
        ADDR <= 8'h0; 
        DATA_IN <= 32'h0;
        #20;
        _RST <= 1'b0;
        #20;
        _RST <= 1'b1;
        #20
        ADDR <= 8'h60;   
        _CS <= 1'b0;
        R_W <= 1'b0;
        #20;//s1
        _AS <= 1'b0;
        #20; //s2
        DATA_IN <= 32'haa55ff60;
        #20; //s3
        _DS <= 1'b0;
        #20; //s4
        #20 //s5
        _AS <= 1'b1;
        _DS <= 1'b1;
        #20
        ADDR <= 8'h0;
        _CS <= 1'b1;
        DATA_IN <= 32'h0;
        R_W <= 1'b1;
        #20;

        //initial condistions s0
        _RST <= 1'b1;
        _AS <= 1'b1;
        _DS <= 1'b1;
        _CS <= 1'b1;
        R_W <= 1'b1;
        ADDR <= 8'h0; 
        DATA_IN <= 32'h0;
        #20;
        _RST <= 1'b0;
        #20;
        _RST <= 1'b1;
        #20
        ADDR <= 8'h70;   
        _CS <= 1'b0;
        R_W <= 1'b0;
        #20;//s1
        _AS <= 1'b0;
        #20; //s2
        DATA_IN <= 32'haa55ff70;
        #20; //s3
        _DS <= 1'b0;
        #20; //s4
        #20 //s5
        _AS <= 1'b1;
        _DS <= 1'b1;
        #20
        ADDR <= 8'h0;
        _CS <= 1'b1;
        DATA_IN <= 32'h0;
        R_W <= 1'b1;
        #20;
        $finish;
    end
    
    
endmodule