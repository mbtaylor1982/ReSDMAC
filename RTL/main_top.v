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
    output _INT,        //Connected to INT2 needs to be Open Collector output.

    inout SIZ1,         //Indicates a 16 bit transfer is true. 
    inout R_W,          //Read Write from CPU
    inout _AS,          //Address Strobe
    inout _DS,          //Data Strobe 
    inout [1:0] _DSACK, //Dynamic size and DATA ack.
    
    inout [31:0] DATA,   // CPU side data bus 32bit wide

    input _STERM,       //static/synchronous data ack.
    input SCLK,         //CPUCLKB
    input _CS           //_SCSI from Fat Garry
    input _RST,         //System Reset
    input _BERR,        //Bus Errpr 

    input [6:2] ADDR,   //CPU address Bus
    
    // Bus Mastering/Arbitration.

    output  _BR,        //Bus Request
    input   _BG,        //Bus Grant
    output  _BGACK,     //Bus Grant Acknoledge
  

    output _DMAEN,      //Low =  Enable Address Generator in Ramsey
    
    // Peripheral port Control signals
    input _DREQ,
    output _DACK,
    input _IORDY,

    input INTA,         //Interupt from WD33c93A (SCSI)
    input INTB,         //Spare Interupt pin.

    output _IOR,        //Active Low read strobe
    output _IOW,        //Ative Low Write strobe

    output _CSS,        //Port 0 CS      
    output _CSX0,       //Port 1A & Port1B CS 
    output _CSX1,       //Port2 CS 

    // Peripheral Device port
    inout [15:0] PD_PORT
    
);
reg [31:0] DATA_OUT;
wire [31:0] DATA_IN;

//Registers
reg [1:0] DAWR;     //Data Acknowledge Width
reg [23:0] WTC;     //Word Transfer Count
reg [7:0] CNTR;     //Control Register
reg ST_DMA;         //Start DMA 
reg FLUSH;          //Flush FIFO
reg CLR_INT;        //Clear Interrupts
reg [31:0] ISTR;    //Interrupt Status Register
reg SP_DMS;         //Stop DMA 


wire [7:0] int_addr;
assign int_addr = {1'b0, ADDR[6:2], 2'b00};

addr_decoder DECODER(
    .ADDR (int_addr),
    ._CS (_CS),
    ._CSS (_CSS),
    ._CSX0 (_CSX0),
    ._CSX1 (_CSX1)
);

wire DATA_PORT_ACTIVE;
assign DATA_PORT_ACTIVE = _CSS & _CSX0 & _CSX1;


// 16/8 bit port for SCSI WD33C93A IC.
io_port D_PORT(
    .ENA (DATA_PORT_ACTIVE),
    .R_W (R_W),
    .SIZ1 (SIZ1),
    .DATA_IN (DATA_IN),
    ._IOR (_IOR), 
    ._IOW (_IOW),
    .DATA_OUT (DATA_OUT),
    .P_DATA (PD_PORT)
);

//assign DATA_OUT = DATA_PORT_ACTIVE ? 32'hz,   
assign DATA = CS ? 32'hz : DATA_OUT;
assign DATA_IN = DATA;

endmodule



