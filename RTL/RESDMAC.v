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
//`include "RTL/registers.v"
//`include "RTL/io_port.v"

module RESDMAC(
    output _INT,        //Connected to INT2 needs to be Open Collector output.

    output SIZ1,         //Indicates a 16 bit transfer is true. 

    input R_W,          //Read Write from CPU
    input _AS,          //Address Strobe
    input _DS,          //Data Strobe 

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

wire [1:0] _DSACK_IO;
wire [1:0] _DSACK_REG;

wire _REGEN;
wire _PORTEN;


// 16/8 bit port for SCSI WD33C93A IC.
io_port D_PORT(
    .CLK (SCLK),
    .ADDR (ADDR),
    ._CS (_PORTEN),
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
    ._IOW (_IOW),
    ._DSACK(_DSACK_IO)
);


registers int_reg(
    .CLK (SCLK),
    .ADDR (ADDR),
    ._CS (_REGEN),
    ._AS (_AS),
    ._DS (_DS),
    ._RST (_RST),
    .R_W (R_W),
    .DIN (DATA_IN),
    .DOUT (RDATA_OUT),
    ._DSACK(_DSACK_REG)
);


assign _REGEN = (_CS || (ADDR[5:2] == 4'b0011) || ADDR[6]);
assign _PORTEN = (_CS || !ADDR[6]);

assign DATA_OUT =  _REGEN ?  32'hzzzzzzzz : RDATA_OUT;
assign DATA_OUT =  _PORTEN ? 32'hzzzzzzzz : PDATA_OUT;

assign DATA_IN = DATA;

assign DATA = ((_REGEN & _PORTEN) | !R_W) ? 32'hzzzzzzzz : DATA_OUT;
assign _DSACK = (_REGEN & _PORTEN) ? 2'bzz : (_DSACK_REG & _DSACK_IO);

assign _DMAEN = 1'b1;
assign _INT = 1'bz;
assign SIZ1 = 1'bz;
assign _STERM = 1'bz;

assign _BR = 1'bz;
assign _BGACK = 1'bz;

//assign _LED_WR = (R_W | _REGEN | _PORTEN);
//assign _LED_RD = (!R_W | _REGEN | _PORTEN);
//assign _LED_DMA = (_DS | _REGEN | _PORTEN);

assign _DACK = 1'bz;

endmodule



