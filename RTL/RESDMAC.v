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
 `ifdef __ICARUS__ 
    `include "RTL/SCSI_SM/SCSI_SM.v"
    `include "RTL/FIFO/fifo.v"
    `include "RTL/CPU_SM/CPU_SM.v"
    `include "RTL/Registers/registers.v"
`endif

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

wire [31:0] MID;
wire [31:0] MOD;

wire [31:0] ID;
wire [31:0] OD;

wire LBYTE_;
wire RE_o;
wire DACK_o;
wire BOEQ3;
wire PRESET; // Peripherial Reset Sets IOR_ and IOW_ active to reset SCSI IC
wire WE;
wire RE;
wire SCSI_CS;
wire nREG_DSK_;
wire LS2CPU;
wire DREQ_;
wire nDMAENA;
wire INCNO;
wire INCNI;

registers u_registers(
    .ADDR      ({1'b0, ADDR, 2'b00}),
    .DMAC_     (_CS       ),
    .AS_       (_AS       ),
    .RW        (R_W       ),
    .nCPUCLK   (~SCLK     ),
    .MID       (MID       ),
    .STOPFLUSH (STOPFLUSH ),
    .RST_      (_RST      ),
    .FIFOEMPTY (FIFOEMPTY ),
    .FIFOFULL  (FIFOFULL  ),
    .INTA_I    (INTA      ),
    .MOD       (MOD       ),
    .PRESET    (PRESET    ),
    .FLUSHFIFO (FLUSHFIFO ),
    .ACR_WR    (ACR_WR    ),
    .h_0C      (H_0C      ),
    .A1        (A1        ),
    .INT_O_    (_INT      ),
    .DMADIR    (DMADIR    ),
    .DMAENA    (DMAENA    ),
    .REG_DSK_  (REG_DSK_  ),
    .WDREGREQ  (WDREGREQ  )
);

CPU_SM csm(
    //.PAS         (PAS         ),
    //.PDS         (PDS         ),
    //.BGACK       (BGACK       ),
    //.BREQ        (BREQ        ),
    //.aBGRANT_    (aBGRANT_    ),
    //.SIZE1       (SIZE1       ),
    .aRESET_       (_RST        ),
    //.STERM_      (STERM_      ),
    //.DSACK0_     (DSACK0_     ),
    //.DSACK1_     (DSACK1_     ),
    //.DSACK       (DSACK       ),
    //.aCYCLEDONE_ (aCYCLEDONE_ ),
    .CLK           (SCLK        ),
    .DMADIR        (DMADIR      ),
    .A1            (A1          ),
    //.F2CPUL      (F2CPUL      ),
    //.F2CPUH      (F2CPUH      ),
    //.BRIDGEIN    (BRIDGEIN    ),
    //.BRIDGEOUT   (BRIDGEOUT   ),
    //.DIEH        (DIEH        ),
    //.DIEL        (DIEL        ),
    //.LASTWORD    (LASTWORD    ),
    .BOEQ3         (BOEQ3       ),
    .FIFOFULL      (FIFOFULL    ),
    .FIFOEMPTY     (FIFOEMPTY   ),
    .RDFIFO_       (RDFIFO_o    ),
    .DECFIFO       (DECFIFO     ),
    .RIFIFO_       (RIFIFO_o    ),
    .INCFIFO       (INCFIFO     ),
    .INCNO         (INCNO_CPU   ),
    .INCNI         (INCNI_CPU   ),
    //.aDREQ_      (aDREQ_      ),
    .aFLUSHFIFO    (FLUSHFIFO   ),
    .STOPFLUSH     (STOPFLUSH   ),
    .aDMAENA       (DMAENA      )//,
    //.PLLW        (PLLW        ),
    //.PLHW        (PLHW        )
);

SCSI_SM u_SCSI_SM(
    .CPUREQ    (WDREGREQ  ),
    .RW        (R_W       ),
    .DMADIR    (DMADIR    ),
    .INCFIFO   (INCFIFO   ),
    .DECFIFO   (DECFIFO   ),
    .RESET_    (_RST      ),
    .BOEQ3     (BOEQ3     ),
    .CPUCLK    (SCLK      ),
    .DREQ_     (DREQ_     ),
    .FIFOFULL  (FIFOFULL  ),
    .FIFOEMPTY (FIFOEMPTY ),
    .nAS_      (~_AS      ),
    .RDFIFO_o  (RDFIFO_o  ),
    .RIFIFO_o  (RIFIFO_o  ),
    .RE_o      (RE        ),
    .WE_o      (WE        ),
    .SCSI_CS_o (SCSI_CS   ),
    .DACK_o    (DACK_o    ),
    .INCBO_o   (INCBO     ),
    .INCNO_o   (INCNO_SCSI  ),
    .INCNI_o   (INCNI_SCSI  ),
    //.S2F_o     (S2F_o     ),
    //.F2S_o     (F2S_o     ),
    //.S2CPU_o   (S2CPU_o   ),
    //.CPU2S_o   (CPU2S_o   ),
    .LS2CPU    (LS2CPU    ),
    .LBYTE_    (LBYTE_    )
);

fifo int_fifo(
    //.LLWORD    (LLWORD    ),
    //.LHWORD    (LHWORD    ),
    .LBYTE_      (LBYTE_    ),
    .H_0C        (H_0C      ),
    .ACR_WR      (ACR_WR    ),
    .RST_FIFO_   (_RST      ),
    .MID25       (MID[25]   ),
    .ID          (ID        ),
    .FIFOFULL    (FIFOFULL  ),
    .FIFOEMPTY   (FIFOEMPTY ),
    .INCFIFO     (INCFIFO   ),
    .DECFIFO     (DECFIFO   ),
    .INCBO       (INCBO     ),
    //.BOEQ0     (BOEQ0     ),
    .BOEQ3       (BOEQ3     ),
    //.BO0       (BO0       ),
    //.BO1       (BO1       ),
    .INCNO       (INCNO     ),
    .INCNI       (INCNI     ),
    .OD          (OD        )
);

assign INCNO = (INCNO_CPU | INCNO_SCSI);
assign INCNI = (INCNI_CPU | INCNI_SCSI);

assign _LED_WR = (R_W | _AS | _CS);
assign _LED_RD = (~R_W | _AS | _CS);
assign _LED_DMA = DMAENA;

assign _IOR = ~(PRESET | RE);
assign _IOW = ~(PRESET | WE);
assign _CSS = ~ SCSI_CS;
assign _DACK = ~ DACK_o;

assign _DSACK = (REG_DSK_ & LS2CPU) ? 2'bzz : 2'b00;
assign DREQ_ = (~DMAENA | _DREQ);

endmodule



