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
`include "ctrl_reg.v"

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
    input _CS,           //_SCSI from Fat Garry
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
wire [31:0] DATA_OUT;
reg [31:0] DATA_IN;

//Registers
reg [1:0] DAWR;     //Data Acknowledge Width
reg [23:0] WTC;     //Word Transfer Count
//reg [7:0] CNTR;     //Control Register (See ctrl_reg.v)
reg ST_DMA;         //Start DMA 
reg FLUSH;          //Flush FIFO
reg CLR_INT;        //Clear Interrupts
reg [31:0] ISTR;    //Interrupt Status Register
reg SP_DMS;         //Stop DMA 


wire [7:0] int_addr;
assign int_addr = {1'b0, ADDR[6:2], 2'b00};


wire _DAWR_EN;
wire _WTC_EN;
wire _CTR_EN;
wire _ST_DMA_EN;
wire _FLUSH_EN;
wire _CLR_INT_EN;
wire _ISTR_EN;
wire _SP_DMA_EN;

addr_decoder DECODER(
    .ADDR (ADDR[6:2]),
    ._CS (_CS),
    ._CSS (_CSS),
    ._CSX0 (_CSX0),
    ._CSX1 (_CSX1),
    ._DAWR (_DAWR_EN),
    ._WTC (_WTC_EN),
    ._CNTR (_CTR_EN),
    ._ST_DMA (_ST_DMA_EN),
    ._FLUSH  (_FLUSH_EN),
    ._CLR_INT (_CLR_INT_EN),
    ._ISTR (_ISTR_EN),
    ._SP_DMA (_SP_DMA_EN)
);

wire _DATA_PORT_ACTIVE;
assign _DATA_PORT_ACTIVE = _CSS && _CSX0 && _CSX1;


// 16/8 bit port for SCSI WD33C93A IC.
io_port D_PORT(
    ._ENA (_DATA_PORT_ACTIVE),
    .R_W (R_W),
    .DATA_IN (DATA_IN),
    ._IOR (_IOR), 
    ._IOW (_IOW),
    .DATA_OUT (DATA_OUT),
    .P_DATA (PD_PORT)
);

ctrl_reg CNTR(
    .DIN (DATA[5:0]),
    ._ENA (_CTR_EN),
    ._DS (_DS),
    .R_W (R_W),
    ._RST (_RST),
    .DOUT (DOUT[5:0])
);

wire [5:0] DOUT;

//assign DATA_OUT = DATA_PORT_ACTIVE ? 32'hz,   
assign DATA = _CS ? 32'hz : DATA_OUT;
//assign DATA_IN = DATA;

endmodule



