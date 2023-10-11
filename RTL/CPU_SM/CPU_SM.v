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

  `include "cpudff1.v"
  `include "cpudff2.v"
  `include "cpudff3.v"
  `include "cpudff4.v"
  `include "cpudff5.v"
  `include "CPU_SM_inputs.v"  
  `include "CPU_SM_output.v"  
`endif

module CPU_SM(
    input A1,
    input aBGRANT_,   
    input aDMAENA,
    input aDREQ_,
    input aFLUSHFIFO,
    input aRESET_,
    input BOEQ0,
    input BOEQ3,
    input CLK,
    input CLK45,             //CPUCLK pahse shifted 45 deg
    input CLK90,             //CPUCLK pahse shifted 90 deg.
    input CLK135,            //CPUCLK pahse shifted 135 deg.    
    input DMADIR,
    input DSACK0_,   
    input DSACK1_,
    input FIFOEMPTY,
    input FIFOFULL,
    input RDFIFO_,
    input RIFIFO_,    
    input iSTERM_,
    input AS_,
    input BGACK_I_,

    output reg BGACK,
    output reg BREQ,
    output reg BRIDGEIN,
    output reg BRIDGEOUT,
    output reg DECFIFO,
    output reg DIEH,
    output reg DIEL,
    output reg F2CPUH,
    output reg F2CPUL,
    output reg INCFIFO,
    output reg INCNI,
    output reg INCNO,
    output reg PAS,
    output reg PDS,
    output reg PLHW,
    output reg PLLW,
    output reg SIZE1,
    output reg STOPFLUSH
);

reg [4:0] STATE;
wire [4:0] NEXT_STATE;

//clocked inputs
reg BGRANT_;
reg CCRESET_;
reg DMAENA;
reg DREQ_;
reg [1:0] DSACK_LATCHED_;
reg FLUSHFIFO;
reg nCYCLEDONE;

wire aCYCLEDONE_;
wire BGACK_d;
wire BRIDGEOUT_d;

wire cpudff1_d;
wire cpudff2_d;
wire cpudff3_d;
wire cpudff4_d;
wire cpudff5_d;

wire CYCLEDONE;

wire DECFIFO_d;
wire DIEH_d;
wire DIEL_d;
wire iDSACK;
wire DSACK; 

wire [62:0] E;
wire [62:0] nE;


wire F2CPUH_d;
wire F2CPUL_d;
wire INCFIFO_d;
wire INCNO_d;
wire nBREQ_d;
wire nBRIDGEIN_d;
wire nDSACK;
wire nINCNI_d;
wire nSTOPFLUSH_d;
wire PAS_d;
wire PDS_d;
wire PLHW_d;
wire PLLW_d;
wire SIZE1_d;
wire nSTERM_;
wire STERM_;
wire LASTWORD;

CPU_SM_inputs u_CPU_SM_inputs(
    .A1           (A1           ),
    .BGRANT_      (BGRANT_      ),
    .BOEQ3        (BOEQ3        ),
    .CYCLEDONE    (CYCLEDONE    ),
    .DMADIR       (DMADIR       ),
    .DMAENA       (DMAENA       ),
    .DREQ_        (DREQ_        ),
    .DSACK0_      (DSACK0_      ),
    .DSACK1_      (DSACK1_      ),
    .FIFOEMPTY    (FIFOEMPTY    ),
    .FIFOFULL     (FIFOFULL     ),
    .FLUSHFIFO    (FLUSHFIFO    ),
    .LASTWORD     (LASTWORD     ),
    .STATE        (STATE        ),
    .nE           (nE),
    .E            (E)
);
cpudff1 u_cpudff1(
    .DSACK        (DSACK        ),
    .STERM_       (STERM_       ),
    .E            (E            ),
    .cpudff1_d    (cpudff1_d    )
);

cpudff2 u_cpudff2(
    .DSACK        (DSACK        ),
    .STERM_       (STERM_       ),
    .E            (E            ),
    .cpudff2_d    (cpudff2_d    )
);

cpudff3 u_cpudff3(
    .DSACK        (DSACK        ),
    .STERM_       (STERM_       ),
    .E            (E            ),
    .cpudff3_d    (cpudff3_d    )
);

cpudff4 u_cpudff4(
    .DSACK        (DSACK        ),
    .STERM_       (STERM_       ),
    .E            (E            ),
    .cpudff4_d    (cpudff4_d    )
);

cpudff5 u_cpudff5(
    .DSACK        (DSACK        ),
    .STERM_       (STERM_       ),
    .E            (E            ),
    .cpudff5_d    (cpudff5_d    )
);
CPU_SM_outputs u_CPU_SM_outputs(
    .DSACK        (DSACK        ),
    .nDSACK       (nDSACK       ),
    .STERM_       (STERM_       ),
    .nSTERM_      (nSTERM_      ),
    .nE           (nE           ),
    .E            (E            ),
    .RDFIFO_      (RDFIFO_      ),
    .RIFIFO_      (RIFIFO_      ),
    .BGRANT_      (BGRANT_      ),
    .CYCLEDONE    (CYCLEDONE    ),
    .STATE        (STATE        ),
    .nINCNI_d     (nINCNI_d     ),
    .nBREQ_d      (nBREQ_d      ),
    .SIZE1_d      (SIZE1_d      ),
    .PAS_d        (PAS_d        ),
    .PDS_d        (PDS_d        ),
    .F2CPUL_d     (F2CPUL_d     ),
    .F2CPUH_d     (F2CPUH_d     ),
    .BRIDGEOUT_d  (BRIDGEOUT_d  ),
    .PLLW_d       (PLLW_d       ),
    .PLHW_d       (PLHW_d       ),
    .INCFIFO_d    (INCFIFO_d    ),
    .DECFIFO_d    (DECFIFO_d    ),
    .INCNO_d      (INCNO_d      ),
    .nSTOPFLUSH_d (nSTOPFLUSH_d ),
    .DIEH_d       (DIEH_d       ),
    .DIEL_d       (DIEL_d       ),
    .nBRIDGEIN_d  (nBRIDGEIN_d  ),
    .BGACK_d      (BGACK_d      )
);

//clocked reset
always @(negedge CLK) begin
    CCRESET_ <= aRESET_;
end

//clocked inputs.
always @(posedge  CLK135 or negedge CCRESET_) begin
    if (CCRESET_ == 1'b0) begin
        BGRANT_     <= 1'b1;
        DMAENA      <= 1'b0;
        DREQ_       <= 1'b1;
        FLUSHFIFO   <= 1'b0;
        nCYCLEDONE  <= 1'b1;
    end
    else begin
        BGRANT_     <= aBGRANT_;
        DMAENA      <= aDMAENA;
        DREQ_       <= aDREQ_;
        FLUSHFIFO   <= aFLUSHFIFO;
        nCYCLEDONE  <= aCYCLEDONE_;
    end
end

//clocked outputs
always @(posedge CLK90 or negedge CCRESET_) begin
    if (CCRESET_ == 1'b0) begin
        BGACK       <= 1'b0;
        PAS         <= 1'b0;
        PDS         <= 1'b0;
        BREQ        <= 1'b0;
        BRIDGEIN    <= 1'b0;
        BRIDGEOUT   <= 1'b0;
        DECFIFO     <= 1'b0;
        DIEH        <= 1'b0;
        DIEL        <= 1'b0;
        F2CPUH      <= 1'b0;
        F2CPUL      <= 1'b0;
        INCFIFO     <= 1'b0;
        INCNI       <= 1'b0;
        INCNO       <= 1'b0;
        PLHW        <= 1'b0;
        PLLW        <= 1'b0;
        SIZE1       <= 1'b0;
        STOPFLUSH   <= 1'b0;
    end
    else begin
        BGACK       <= BGACK_d;
        BREQ        <= ~nBREQ_d;
        BRIDGEIN    <= ~nBRIDGEIN_d;
        BRIDGEOUT   <= BRIDGEOUT_d;
        DECFIFO     <= DECFIFO_d;
        DIEH        <= DIEH_d;
        DIEL        <= DIEL_d;
        F2CPUH      <= F2CPUH_d;
        F2CPUL      <= F2CPUL_d;
        INCFIFO     <= INCFIFO_d;
        INCNI       <= ~nINCNI_d;
        INCNO       <= INCNO_d;
        PAS         <= PAS_d;
        PDS         <= PDS_d;
        PLHW        <= PLHW_d;
        PLLW        <= PLLW_d;
        SIZE1       <= SIZE1_d;
        STOPFLUSH   <= ~nSTOPFLUSH_d;
    end
end

always @(posedge CLK90 or negedge CCRESET_) begin
    if (CCRESET_ == 1'b0) 
        STATE <= 5'b00000;
    else 
        STATE <= NEXT_STATE;
end

always @(negedge CLK or posedge AS_) begin
    if (AS_ == 1'b1)
        DSACK_LATCHED_ <= 2'b11;
    else 
        DSACK_LATCHED_ <= {DSACK1_, DSACK0_};
end

assign  aCYCLEDONE_ = ~(BGACK_I_ & AS_ & DSACK0_ & DSACK1_ & iSTERM_);

assign LASTWORD = (~BOEQ0 & aFLUSHFIFO & FIFOEMPTY);

assign NEXT_STATE = {cpudff5_d, cpudff4_d, cpudff3_d, cpudff2_d, cpudff1_d};


assign CYCLEDONE = ~nCYCLEDONE;
assign iDSACK = ~(DSACK_LATCHED_[0] & DSACK_LATCHED_[1]);

assign DSACK = iDSACK;
assign nDSACK = ~iDSACK;
assign STERM_ = iSTERM_;
assign nSTERM_ = ~iSTERM_;



endmodule