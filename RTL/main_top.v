/*

AMIGA SDMAC Replacement for A3000/T
Copyright 2021 Mike Taylor

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
`include "io_port.v"

module main_top(
    input SCLK,         //CPUCLKB
    input AS,
    input DS,
    input RW,
    input RST, 
    input CS,
    input SIZ1,         // Indicates a 16 bit transfer is true. 

    input [6:2] ADDR,   //CPU address Bus
    
    inout [31:0] DATA,   // CPU side data bus 32bit wide

    output [1:0] DSACK,

    output DMAEN,
    
    input DREQ,
    input IORDY,
    input SINTREQ,

    output IOR,
    output IOW,

    output CSS,
    output CSX0,
    output CSX1,
    
    output DACK,

    inout [15:0] PD_PORT//Peripheral Device port
    
);
reg [31:0] DATA_OUT;
wire [31:0] DATA_IN;

assign DATA = CS ? 32'hz : DATA_OUT;
assign DATA_IN = DATA;

wire [7:0] int_addr;
assign int_addr = {1'b0, ADDR[6:2], 2'b00};

addr_decoder DECODER(
    .ADDR (int_addr),
    .CS (CS),
    .CSS (CSS),
    .CSX0 (CSX0),
    .CSX1 (CSX1)
);

wire DATA_PORT_ACTIVE;
assign DATA_PORT_ACTIVE = CSS & CSX0 & CSX1;

// 16/8 bit port for SCSI WD33C93A IC.
io_port D_PORT(
    .ENA (DATA_PORT_ACTIVE),
    .RW (RW),
    .SIZ1 (SIZ1),
    .DATA_IN (DATA_IN),
    .IOR (IOR), 
    .IOW (IOW),
    .DATA_OUT (DATA_OUT),
    .P_DATA (PD_PORT)
);

endmodule



