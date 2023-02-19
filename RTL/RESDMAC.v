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
    `include "RTL/PLL.v"
`endif

module RESDMAC(
    output tri1 _INT,        //Connected to INT2 needs to be Open Collector output.

    output tri1 SIZ1,         //Indicates a 16 bit transfer is true. 

    inout tri1 R_W_IO,          //Read Write from CPU
    inout tri1 _AS_IO,          //Address Strobe
    inout tri1 _DS_IO,          //Data Strobe 
    inout tri1 [1:0] _DSACK_IO,        //Dynamic size and DATA ack.
    
    inout tri1 [31:0] DATA_IO,   // CPU side data bus 32bit wide

    input tri1 _STERM,       //static/synchronous data ack.
    
    input SCLK,         //CPUCLKB
    input _CS,           //_SCSI from Fat Garry
    input _RST,         //System Reset
    input tri1 _BERR,        //Bus Error 

    input [6:2] ADDR,   //CPU address Bus, bits are actually [6:2]
    //input A12,          // additional address input to allow this to co-exist with A4000 IDE card.
    
    // Bus Mastering/Arbitration.

    output   _BR,        //Bus Request
    input    _BG,        //Bus Grant
    inout   tri1 _BGACK_IO,  //Bus Grant Acknoledge

    output _DMAEN,      //Low =  Enable Address Generator in Ramsey
    
    // Peripheral port Control signals
    input tri1 _DREQ,
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
    inout tri1 [15:0] PD_PORT,
    
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
reg [31:0] DATA_O;
reg LLW;
reg LHW;

wire [31:0] MID;
wire [31:0] MOD;

wire [31:0] ID;
wire [31:0] OD;

wire _AS;
wire n_AS;
assign #2.5 n_AS = ~_AS_IO; 
assign #2.5 _AS = ~n_AS;

wire _DS;
wire n_DS;
assign #2.5 n_DS = ~_DS_IO;
assign #2.5 _DS = ~n_DS;

wire R_W;
wire nR_W;
assign #2.5 nR_W = ~R_W_IO;
assign #2.5 R_W = ~nR_W;

wire [31:0] DATA;
assign DATA = DATA_IO;

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

wire DSACK_CPU_SM;

wire QnCPUCLK, nCLK, BCLK, BBCLK;
wire PLLLOCKED;

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
wire A3;
wire DSK0_IN_;
wire DSK1_IN_;
tri1 _BGACK_I;
wire BnDS_O_;

registers u_registers(
    .ADDR      ({1'b0, ADDR, 2'b00}),
    .DMAC_     (_CS       ),
    .AS_       (_AS       ),
    .RW        (R_W       ),
    .nCPUCLK   (nCLK      ),
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
    .iSTERM_       (_STERM      ),
    .DSACK0_       (DSK0_IN_    ),
    .DSACK1_       (DSK1_IN_    ),
    .nCLK          (nCLK        ), 
    .BCLK          (BCLK        ), 
    .BBCLK         (BBCLK       ), 
    .DMADIR        (DMADIR      ),
    .A1            (A1          ),
    .F2CPUL        (F2CPUL      ),
    .F2CPUH        (F2CPUH      ),
    .BRIDGEIN      (BRIDGEIN    ),
    .BRIDGEOUT     (BRIDGEOUT   ),
    .DIEH          (DIEH        ),
    .DIEL          (DIEL        ),
    .BOEQ0         (BOEQ0       ),
    .BOEQ3         (BOEQ3       ),
    .FIFOFULL      (FIFOFULL    ),
    .FIFOEMPTY     (FIFOEMPTY   ),
    .RDFIFO_       (~RDFIFO_o    ),
    .DECFIFO       (DECFIFO     ),
    .RIFIFO_       (~RIFIFO_o    ),
    .INCFIFO       (INCFIFO     ),
    .INCNO         (INCNO_CPU   ),
    .INCNI         (INCNI_CPU   ),
    .aDREQ_        (DREQ_       ),
    .aFLUSHFIFO    (FLUSHFIFO   ),
    .STOPFLUSH     (STOPFLUSH   ),
    .aDMAENA       (DMAENA      ),
    .PLLW          (PLLW        ),
    .PLHW          (PLHW        ),
    .AS_           (_AS         ),
    .nAS_          (n_AS        ),
    .BGACK_I_      (_BGACK_I    )

);

SCSI_SM u_SCSI_SM(
    .CPUREQ    (WDREGREQ    ),
    .RW        (R_W         ),
    .DMADIR    (DMADIR      ),
    .INCFIFO   (INCFIFO     ),
    .DECFIFO   (DECFIFO     ),
    .RESET_    (_RST        ),
    .BOEQ3     (BOEQ3       ),
    .nCLK      (nCLK        ), 
    .BCLK      (BCLK        ), 
    .BBCLK     (BBCLK       ), 
    .DREQ_     (DREQ_       ),
    .FIFOFULL  (FIFOFULL    ),
    .FIFOEMPTY (FIFOEMPTY   ),
    .nAS_      (n_AS        ),
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
    .DATA_IO   (DATA_IO     ),
    .PD        (PD_PORT[7:0]),
    .OD        (OD          ),
    .MOD       (MOD         ),
    .PAS       (PAS         ),
    .nDS_      (n_DS        ),
    .nDMAC_    (~_CS        ),
    .RW        (R_W         ),
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
    .BnDS_O_   (BnDS_O_     )
);

PLL u_PLL (
        .rst         (~_RST    ),
        .CPUCLK_I    (SCLK     ),
        .nCLK        (nCLK     ),
        .BCLK        (BCLK     ),
        .BBCLK       (BBCLK    ),
        .QnCPUCLK    (QnCPUCLK ),
        .locked      (PLLLOCKED)
    );


always @(posedge QnCPUCLK) begin
    AS_O_   <= ~PAS;    
    DS_O_   <= ~PDS; 
    LLW     <= PLLW;
    LHW     <= PLHW;
end

assign OWN_ = ~CPUSM_BGACK;
assign _BGACK_I =  _BGACK_IO;

//System Outputs
assign  R_W_IO = OWN_ ? 1'bz : ~DMADIR;
assign _AS_IO = OWN_ ? 1'bz : AS_O_;
assign _DS_IO = OWN_ ? 1'bz : DS_O_;
//assign DATA_IO = OWN_ ? 32'bz : DATA_O;
assign _DMAEN = OWN_;
assign _BR = BREQ ?  1'b0 : 1'bz;
assign SIZ1 = OWN_ ? 1'b0 : SIZE1_CPUSM;
assign _DSACK_IO = (REG_DSK_ & LS2CPU) ? 2'bzz : 2'b00;
assign _BGACK_IO = OWN_ ? 1'bz : 1'b0;

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
assign INCNO = (INCNO_CPU | INCNO_SCSI);
assign INCNI = (INCNI_CPU | INCNI_SCSI);

assign DSK0_IN_ = _BERR & _DSACK_IO[0];
assign DSK1_IN_ = _BERR & _DSACK_IO[1];

assign A3 = ADDR[3];
assign DATA_OE_ = (_AS | _CS | H_0C) & _BGACK_IO;
assign PDATA_OE_ = (_DACK | ~_CSS);

assign #5 BnDS_O_ = ~DS_O_;

endmodule


