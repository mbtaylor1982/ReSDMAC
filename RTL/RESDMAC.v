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

module RESDMAC(
    output _INT,        //Connected to INT2 needs to be Open Collector output.

    output SIZ1,         //Indicates a 16 bit transfer is true. 

    inout R_W,          //Read Write from CPU
    inout _AS,          //Address Strobe
    inout _DS,          //Data Strobe 

    output [1:0] _DSACK, //Dynamic size and DATA ack.
    
    inout [31:0] DATA,   // CPU side data bus 32bit wide

    output _STERM,       //static/synchronous data ack.
    
    input SCLK,         //CPUCLKB
    input _CS,           //_SCSI from Fat Garry
    input _RST,         //System Reset
    input _BERR,        //Bus Error 

    input [6:2] ADDR,   //CPU address Bus
    input A12,          // additional address input to allow this to co-exist with A4000 IDE card.
    
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
    inout [15:0] PD_PORT,
    
    //Diagnostic LEDS
    output _LED_RD, //Indicated read from SDMAC or peripherial port.
    output _LED_WR, //Indicate write to SDMAC or peripherial port.
    output _LED_DMA  //Indicate DMA cycle/ busmaster.
    

);
wire [31:0] DATA_OUT;
wire [31:0] PDATA_OUT;
wire [31:0] RDATA_OUT;
wire [31:0] DATA_IN;

wire REG_TERM;

//wire [7:0] int_addr;
//assign int_addr = {1'b0, ADDR[6:2], 2'b00};


addr_decoder DECODER(
    .ADDR ({1'b0,ADDR,2'b0}),
    ._CS (_CS),
    ._AS (_AS),
    ._CSS (_CSS),
    ._CSX0 (_CSX0),
    ._CSX1 (_CSX1)
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
    .DATA_OUT (PDATA_OUT),
    .P_DATA (PD_PORT)
);

registers int_reg(
    .CLK (CLK)
    .ADDR ({1'b0,ADDR,2'b0}),
    ._CS (_CS),
    ._AS (_AS),
    ._DS (_DS),
    ._RST (_RST),
    .R_W (R_W),
    .DIN (DATA_IN),
    .DOUT (RDATA_OUT),
    .STERM (REG_TERM)
);

assign DATA_OUT = _DATA_PORT_ACTIVE ? RDATA_OUT : PDATA_OUT;
assign DATA = _CS ? 32'hz : DATA_OUT;
assign DATA_IN = DATA;

assign STERM = _CS ? 1'bz : REG_TERM;

endmodule



