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

    input [6:2] ADDR,   //CPU address Bus, bits are actually [6:2]
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

wire DATA_PORT_ACTIVE;
assign DATA_PORT_ACTIVE = ADDR[4];

// 16/8 bit port for SCSI WD33C93A IC.
io_port D_PORT(
    .CLK (CLK),
    .ADDR (ADDR),
    ._CS (_CS),
    ._AS (_AS),
    ._DS (_DS),
    .R_W (R_W),
    ._RST (_RST),
    .DATA_IN (DATA_IN),
    .DATA_OUT (PDATA_OUT),
    ._CSS (_CSS),
    ._CSX0 (_CSX0),
    ._CSX1 (_CSX1),
    .P_DATA (PD_PORT),
    ._IOR (_IOR), 
    ._IOW (_IOW)
);

registers int_reg(
    .CLK (CLK),
    .ADDR (ADDR),
    ._CS (_CS),
    ._AS (_AS),
    ._DS (_DS),
    ._RST (_RST),
    .R_W (R_W),
    .DIN (DATA_IN),
    .DOUT (RDATA_OUT),
    .TERM (REG_TERM)
);

assign DATA_OUT = DATA_PORT_ACTIVE ?  PDATA_OUT: RDATA_OUT;
assign DATA = _CS ? 32'hz : DATA_OUT;
assign DATA_IN = DATA;

assign _DSACK = REG_TERM ? 2'bzz : 2'b00;

assign _DMAEN = 1'b1;
assign _INT = 1'bz;
assign SIZ1 = 1'bz;
assign _STERM = 1'bz;

assign _BR = 1'bz;
assign _BGACK = 1'bz;

assign _LED_WR = (R_W || _CS);
assign _LED_RD = (!R_W || _CS);


endmodule



