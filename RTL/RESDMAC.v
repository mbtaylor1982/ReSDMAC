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
module RESDMAC(
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
    input _BERR,        //Bus Error 

    input [6:2] ADDR,   //CPU address Bus, bits are actually [6:2]
    input A12,          // additional address input to allow this to co-exist with A4000 IDE card.
    
    // Bus Mastering/Arbitration.

    output  _BR,        //Bus Request
    input   _BG,        //Bus Grant
    inout  _BGACK,     //Bus Grant Acknoledge
  

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

wire LBYTE_;
wire RE_o;
wire DACK_o;
wire BOEQ3;

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

SCSI_SM ssm(
    //.DSACK_    (DSACK_    ),
    //.SET_DSACK (SET_DSACK ),
    .CPUREQ    (CPUREQ    ),
    .RW        (R_W),
    //.DMADIR    (DMADIR    ),
    //.RDFIFO_o  (RDFIFO_o  ),
    //.RDFIFO_d  (RDFIFO_d  ),
    //.RIFIFO_o  (RIFIFO_o  ),
    //.RIFIFO_d  (RIFIFO_d  ),
    .RESET_    (_RST),
    .BOEQ3     (BOEQ3     ),
    .CPUCLK    (SCLK),
    .RE_o      (RE_o      ),
    //.WE_o      (WE_o      ),
    //.SCSI_CS_o (SCSI_CS_o ),
    .DACK_o    (DACK_o    )//,
    //.DREQ_     (DREQ_     ),
    //.INCBO_o   (INCBO_o   ),
    //.INCNO_o   (INCNO_o   ),
    //.INCNI_o   (INCNI_o   ),
    //.FIFOFULL  (FIFOFULL  ),
    //.FIFOEMPTY (FIFOEMPTY ),
    //.S2F_o     (S2F_o     ),
    //.F2S_o     (F2S_o     ),
    //.S2CPU_o   (S2CPU_o   ),
    //.PU2S_o    (PU2S_o    )
);

CPU_SM csm(
    //.PAS         (PAS         ),
    //.PDS         (PDS         ),
    //.BGACK       (BGACK       ),
    //.BREQ        (BREQ        ),
    //.aBGRANT_    (aBGRANT_    ),
    //.SIZE1       (SIZE1       ),
    .aRESET_     (_RST     ),
    //.STERM_      (STERM_      ),
    //.DSACK0_     (DSACK0_     ),
    //.DSACK1_     (DSACK1_     ),
    //.DSACK       (DSACK       ),
    //.aCYCLEDONE_ (aCYCLEDONE_ ),
    .CLK         (SCLK         )//,
    //.DMADIR      (DMADIR      ),
    //.A1          (A1          ),
    //.F2CPUL      (F2CPUL      ),
    //.F2CPUH      (F2CPUH      ),
    //.BRIDGEIN    (BRIDGEIN    ),
    //.BRIDGEOUT   (BRIDGEOUT   ),
    //.DIEH        (DIEH        ),
    //.DIEL        (DIEL        ),
    //.LASTWORD    (LASTWORD    ),
    //.BOEQ3       (BOEQ3       ),
    //.FIFOFULL    (FIFOFULL    ),
    //.FIFOEMPTY   (FIFOEMPTY   ),
    //.RDFIFO_     (RDFIFO_     ),
    //.DECFIFO     (DECFIFO     ),
    //.RIFIFO_     (RIFIFO_     ),
    //.INCFIFO     (INCFIFO     ),
    //.INCNO       (INCNO       ),
    //.INCNI       (INCNI       ),
    //.aDREQ_      (aDREQ_      ),
    //.aFLUSHFIFO  (aFLUSHFIFO  ),
    //.STOPFLUSH   (STOPFLUSH   ),
    //.aDMAENA     (aDMAENA     ),
    //.PLLW        (PLLW        ),
    //.PLHW        (PLHW        )
);

FIFO int_fifo(
    //.LLWORD    (LLWORD    ),
    //.LHWORD    (LHWORD    ),
    .LBYTE_    (LBYTE_    ),
    //.h_0C      (h_0C      ),
    //.ACR_WR    (ACR_WR    ),
    //.RST_FIFO_ (RST_FIFO_ ),
    //.MID25     (MID25     ),
    //.ID        (ID        ),
    //.FIFOFULL  (FIFOFULL  ),
    //.FIFOEMPTY (FIFOEMPTY ),
    //.INCFIFO   (INCFIFO   ),
    //.DECFIFO   (DECFIFO   ),
    //.INCBO     (INCBO     ),
    //.BOEQ0     (BOEQ0     ),
    .BOEQ3     (BOEQ3     )//,
    //.BO0       (BO0       ),
    //.BO1       (BO1       ),
    //.INCNO     (INCNO     ),
    //.INCNI     (INCNI     ),
    //.OD        (OD        )
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


assign _BR = 1'bz;
assign _BGACK = 1'bz;

//assign _LED_WR = (R_W | _REGEN | _PORTEN);
//assign _LED_RD = (!R_W | _REGEN | _PORTEN);
//assign _LED_DMA = (_DS | _REGEN | _PORTEN);

assign _DACK = 1'bz;

assign LBYTE_ = ~(RE_o & DACK_o);

endmodule



