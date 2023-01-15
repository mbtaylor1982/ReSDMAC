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
    `include "RTL/datapath/datapath.v"
`endif

module RESDMAC(
    output _INT,        //Connected to INT2 needs to be Open Collector output.

    output SIZ1,         //Indicates a 16 bit transfer is true. 

    inout R_W_IO,          //Read Write from CPU
    inout _AS_IO,          //Address Strobe
    inout _DS_IO,          //Data Strobe 

    output [1:0] _DSACK_O, //Dynamic size and DATA ack.
    input [1:0] _DSACK_I, //Dynamic size and DATA ack.
    
    inout [31:0] DATA,   // CPU side data bus 32bit wide

    input _STERM,       //static/synchronous data ack.
    
    input SCLK,         //CPUCLKB
    input _CS,           //_SCSI from Fat Garry
    input _RST,         //System Reset
    input _BERR,        //Bus Error 

    input [6:2] ADDR,   //CPU address Bus, bits are actually [6:2]
    //input A12,          // additional address input to allow this to co-exist with A4000 IDE card.
    
    // Bus Mastering/Arbitration.

    output  _BR,        //Bus Request
    input   _BG,        //Bus Grant
    output  _BGACK_O,     //Bus Grant Acknoledge
    input  _BGACK_I,

    output _DMAEN,      //Low =  Enable Address Generator in Ramsey
    
    // Peripheral port Control signals
    input _DREQ,
    output _DACK,
    //input _IORDY,

    input INTA,         //Interupt from WD33c93A (SCSI)
    //input INTB,         //Spare Interupt pin.

    output _IOR,        //Active Low read strobe
    output _IOW,        //Ative Low Write strobe

    output _CSS,        //Port 0 CS      
    //output _CSX0,       //Port 1A & Port1B CS 
    //output _CSX1,       //Port2 CS 

    // Peripheral Device port
    inout [7:0] PD_PORT,
    
    //Diagnostic LEDS
    output _LED_RD,     //Indicated read from SDMAC or peripherial port.
    output _LED_WR,     //Indicate write to SDMAC or peripherial port.
    output _LED_DMA,    //Indicate DMA cycle/busmaster.
	 
    output OWN_,        //Active low signal to show SDMAC is bus master, This can be used to set direction on level shifters for control signals.
    output DATA_OE_,    //Active low ouput enable for DBUS level shifters.
    output PDATA_OE_    //Active low ouput enable for Peripheral BUS level shifters.
);

reg AS_O_;
reg DS_O_;
reg LLW;
reg LHW;
reg [1:0] DSACK_LATCHED_;

wire [31:0] MID;
wire [31:0] MOD;

wire [31:0] ID;
wire [31:0] OD;

wire _AS;
assign _AS = _AS_IO; 

wire _DS;
assign _DS = _DS_IO;

wire R_W;
assign R_W = R_W_IO;

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
//wire OWN_;
wire LEFTOVERS;
wire nSCLK;
wire aCYCLEDONE_;
wire nAS_;
wire DSACK_CPU_SM;


wire STOPFLUSH;
wire FIFOEMPTY;
wire FIFOFULL;
wire FLUSHFIFO;
wire ACR_WR;
wire H_0C;
wire A1;
wire DMADIR;
wire DMAENA;
wire REG_DSK_;
wire WDREGREQ;
wire PAS;
wire PDS;
wire CPUSM_BGACK;
wire BREQ;
wire SIZE1_CPUSM;
wire F2CPUL;
wire F2CPUH;
wire BRIDGEIN;
wire BRIDGEOUT;
wire DIEH;
wire DIEL;
wire RDFIFO_o;
wire DECFIFO;
wire RIFIFO_o;
wire INCFIFO;
wire INCNO_CPU;
wire INCNI_CPU;
wire PLLW;
wire PLHW;
wire INCBO;
wire INCNO_SCSI;
wire INCNI_SCSI;
wire S2F;
wire F2S;
wire S2CPU;
wire CPU2S;
wire BOEQ0;
wire BO0;
wire BO1;
wire RW;
wire A3;
wire DSK0_IN_;
wire DSK1_IN_;


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

CPU_SM u_CPU_SM(
    .PAS           (PAS         ),
    .PDS           (PDS         ),
    .BGACK         (CPUSM_BGACK ),
    .BREQ          (BREQ        ),
    .aBGRANT_      (_BG         ),
    .SIZE1         (SIZE1_CPUSM ),
    .aRESET_       (_RST        ),
    .STERM_        (_STERM      ),
    .DSACK0_       (DSK0_IN_    ),
    .DSACK1_       (DSK1_IN_    ),
    .DSACK         (DSACK_CPU_SM),
    .aCYCLEDONE_   (aCYCLEDONE_ ),
    .CLK           (SCLK        ),
    .DMADIR        (DMADIR      ),
    .A1            (A1          ),
    .F2CPUL        (F2CPUL      ),
    .F2CPUH        (F2CPUH      ),
    .BRIDGEIN      (BRIDGEIN    ),
    .BRIDGEOUT     (BRIDGEOUT   ),
    .DIEH          (DIEH        ),
    .DIEL          (DIEL        ),
    .LASTWORD      (LEFTOVERS   ),
    .BOEQ3         (BOEQ3       ),
    .FIFOFULL      (FIFOFULL    ),
    .FIFOEMPTY     (FIFOEMPTY   ),
    .RDFIFO_       (RDFIFO_o    ),
    .DECFIFO       (DECFIFO     ),
    .RIFIFO_       (RIFIFO_o    ),
    .INCFIFO       (INCFIFO     ),
    .INCNO         (INCNO_CPU   ),
    .INCNI         (INCNI_CPU   ),
    .aDREQ_        (DREQ_       ),
    .aFLUSHFIFO    (FLUSHFIFO   ),
    .STOPFLUSH     (STOPFLUSH   ),
    .aDMAENA       (DMAENA      ),
    .PLLW          (PLLW        ),
    .PLHW          (PLHW        )
);

SCSI_SM u_SCSI_SM(
    .CPUREQ    (WDREGREQ    ),
    .RW        (R_W         ),
    .DMADIR    (DMADIR      ),
    .INCFIFO   (INCFIFO     ),
    .DECFIFO   (DECFIFO     ),
    .RESET_    (_RST        ),
    .BOEQ3     (BOEQ3       ),
    .CPUCLK    (SCLK        ),
    .DREQ_     (DREQ_       ),
    .FIFOFULL  (FIFOFULL    ),
    .FIFOEMPTY (FIFOEMPTY   ),
    .nAS_      (nAS_        ),
    .RDFIFO_o  (RDFIFO_o    ),
    .RIFIFO_o  (RIFIFO_o    ),
    .RE_o      (RE          ),
    .WE_o      (WE          ),
    .SCSI_CS_o (SCSI_CS     ),
    .DACK_o    (DACK_o      ),
    .INCBO_o   (INCBO       ),
    .INCNO_o   (INCNO_SCSI  ),
    .INCNI_o   (INCNI_SCSI  ),
    .S2F_o     (S2F         ),
    .F2S_o     (F2S         ),
    .S2CPU_o   (S2CPU       ),
    .CPU2S_o   (CPU2S       ),
    .LS2CPU    (LS2CPU      ),
    .LBYTE_    (LBYTE_      )
);

fifo int_fifo(
    .LLWORD      (LLW       ),
    .LHWORD      (LHW       ),
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
    .BOEQ0       (BOEQ0     ),
    .BOEQ3       (BOEQ3     ),
    .BO0         (BO0       ),
    .BO1         (BO1       ),
    .INCNO       (INCNO     ),
    .INCNI       (INCNI     ),
    .OD          (OD        )
);

datapath u_datapath(
    .DATA_IO   (DATA        ),
    .PD        (PD_PORT     ),
    .OD        (OD          ),
    .MOD       (MOD         ),
    .PAS       (PAS         ),
    .nDS_      (~_DS        ),
    .nDMAC_    (~_CS        ),
    .RW        (RW          ),
    .nOWN_     (~OWN_       ),
    .DMADIR    (DMADIR      ),
    .BRIDGEIN  (BRIDGEIN    ),
    .BRIDGEOUT (BRIDGEOUT   ),
    .DIEH      (DIEH        ),
    .DIEL      (DIEL        ),
    .LS2CPU    (LS2CPU      ),
    .S2CPU     (S2CPU       ),
    .S2F       (S2F         ),
    .F2S       (F2S         ),
    .CPU2S     (CPU2S       ),
    .BO0       (BO0         ),
    .BO1       (BO1         ),
    .A3        (A3          ),
    .MID       (MID         ),
    .ID        (ID          ),
    .F2CPUL    (F2CPUL      ),
    .F2CPUH    (F2CPUH      ),
    .BnDS_O_   (~PDS        )
);

always @(posedge nSCLK) begin
    AS_O_ <= PAS;    
end

always @(posedge nSCLK) begin
    DS_O_ <= PDS;    
end

always @(posedge nSCLK) begin
    LLW <= PLLW;    
end

always @(posedge nSCLK) begin
    LHW <= PLHW;    
end

always @(posedge nSCLK or negedge nAS_) begin
    if (nAS_ == 1'b0)
        DSACK_LATCHED_ <= 2'b11;
    else 
        DSACK_LATCHED_ <= {DSK1_IN_, DSK0_IN_};
end

assign nSCLK  = ~SCLK;
assign nAS_ = ~_AS;
assign OWN_ = ~CPUSM_BGACK;

//System Outputs
assign R_W_IO = OWN_ ? 1'bz : ~DMADIR;
assign _AS_IO = OWN_ ? 1'bz : AS_O_;
assign _DS_IO = OWN_ ? 1'bz : DS_O_;
assign _DMAEN = OWN_;
assign _BGACK_O = OWN_ ? 1'bz : 1'b0;
assign _BR = BREQ ?  1'b0 : 1'bz;
assign SIZ1 = OWN_ ? 1'bz : SIZE1_CPUSM;
assign _DSACK_O = (REG_DSK_ & LS2CPU) ? 2'b11 : 2'b00;

//SCSI outputs
assign _IOR = ~(PRESET | RE);
assign _IOW = ~(PRESET | WE);
assign _CSS = ~ SCSI_CS;
assign _DACK = ~ DACK_o;

//Diagnostic LEDs
assign _LED_WR = OWN_ ? (R_W | _AS | _CS) : DMADIR;
assign _LED_RD = OWN_ ? (~R_W | _AS | _CS): ~DMADIR;
assign _LED_DMA = OWN_; 

//internal connections
assign DREQ_ = (~DMAENA | _DREQ);
assign LEFTOVERS = (~BOEQ0 & FLUSHFIFO & FIFOEMPTY);
assign INCNO = (INCNO_CPU | INCNO_SCSI);
assign INCNI = (INCNI_CPU | INCNI_SCSI);
assign aCYCLEDONE_ = ~(_BGACK_I & _AS & DSK0_IN_ & DSK1_IN_ & _STERM);

assign DSACK_CPU_SM = ~(DSACK_LATCHED_[0] & DSACK_LATCHED_[1]);
assign DSK0_IN_ = _BERR & _DSACK_I[0];
assign DSK1_IN_ = _BERR & _DSACK_I[1];

//assign PD_PORT[15:8]  = 8'bzzzzzzzz;
//assign _CSX0 = 1'bz;
//assign _CSX1 = 1'bz;
assign A3 = ADDR[3];
assign DATA_OE_ = (_AS | _CS | H_0C);
assign PDATA_OE_ = (~_DACK & _CSS);



endmodule



