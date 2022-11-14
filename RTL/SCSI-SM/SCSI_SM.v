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

module SCSI_SM(
    input DSACK_,
    input CPUREQ,
    input RW,
    input DMADIR,    
    input RDFIFO_o,
    input RIFIFO_o,
    input RESET_,
    input BOEQ3,
    input CPUCLK,
    input DREQ_,
    input FIFOFULL,
    input FIFOEMPTY,

    output SET_DSACK,
    output RDFIFO_d,
    output RIFIFO_d,
    output RE_o,
    output WE_o,
    output SCSI_CS_o,
    output DACK_o,
    output INCBO_o,
    output INCNO_o,
    output INCNI_o,
    output S2F_o,
    output F2S_o,
    output S2CPU_o,
    output PU2S_o
);

scsi_sm_inputs u_scsi_sm_inputs(
    .scsidff1_q (scsidff1_q ),
    .scsidff2_q (scsidff2_q ),
    .scsidff3_q (scsidff3_q ),
    .scsidff4_q (scsidff4_q ),
    .scsidff5_q (scsidff5_q ),
    .BOEQ3      (BOEQ3      ),
    .CCPUREQ    (CCPUREQ    ),
    .CDREQ_     (CDREQ_     ),
    .CDSACK_    (CDSACK_    ),
    .DMADIR     (DMADIR     ),
    .FIFOEMPTY  (FIFOEMPTY  ),
    .FIFOFULL   (FIFOFULL   ),
    .RDFIFO_o   (RDFIFO_o   ),
    .RIFIFO_o   (RIFIFO_o   ),
    .RW         (RW         ),
    .E0_        (E0_        ),
    .E1_        (E1_        ),
    .E2_        (E2_        ),
    .E3_        (E3_        ),
    .E4_        (E4_        ),
    .E5_        (E5_        ),
    .E6_        (E6_        ),
    .E7_        (E7_        ),
    .E8_        (E8_        ),
    .E9_        (E9_        ),
    .E10_       (E10_       ),
    .E11_       (E11_       ),
    .E12_       (E12_       ),
    .E13_       (E13_       ),
    .E14_       (E14_       ),
    .E15_       (E15_       ),
    .E16_       (E16_       ),
    .E17_       (E17_       ),
    .E18_       (E18_       ),
    .E19_       (E19_       ),
    .E20_       (E20_       ),
    .E21_       (E21_       ),
    .E22_       (E22_       ),
    .E23_       (E23_       ),
    .E24_       (E24_       ),
    .E25_       (E25_       ),
    .E26_       (E26_       ),
    .E27_       (E27_       )
);

scsi_sm_outputs u_scsi_sm_outputs(
    .E0_        (E0_        ),
    .E1_        (E1_        ),
    .E2_        (E2_        ),
    .E3_        (E3_        ),
    .E4_        (E4_        ),
    .E5_        (E5_        ),
    .E6_        (E6_        ),
    .E7_        (E7_        ),
    .E8_        (E8_        ),
    .E10_       (E10_       ),
    .E9_        (E9_        ),
    .E11_       (E11_       ),
    .E12_       (E12_       ),
    .E13_       (E13_       ),
    .E14_       (E14_       ),
    .E15_       (E15_       ),
    .E16_       (E16_       ),
    .E17_       (E17_       ),
    .E18_       (E18_       ),
    .E19_       (E19_       ),
    .E20_       (E20_       ),
    .E21_       (E21_       ),
    .E22_       (E22_       ),
    .E23_       (E23_       ),
    .E24_       (E24_       ),
    .E25_       (E25_       ),
    .E26_       (E26_       ),
    .E27_       (E27_       ),
    .scsidff1_d (scsidff1_d ),
    .scsidff2_d (scsidff2_d ),
    .scsidff3_d (scsidff3_d ),
    .scsidff4_d (scsidff4_d ),
    .scsidff5_d (scsidff5_d ),
    .DACK       (DACK       ),
    .INCBO      (INCBO      ),
    .INCNI      (INCNI      ),
    .INCNO      (INCNO      ),
    .RE         (RE         ),
    .WE         (WE         ),
    .SCSI_CS    (SCSI_CS    ),
    .SET_DSACK  (SET_DSACK  ),
    .RIFIFO_d   (RIFIFO_d   ),
    .RDFIFO_d   (RDFIFO_d   ),
    .S2F        (S2F        ),
    .F2S        (F2S        ),
    .S2CPU      (S2CPU      ),
    .CPU2S      (CPU2S      )
);



reg [5:0] state;

//Clocked inputs
reg CCPUREQ;
reg CDREQ_;
reg CDSACK_;
reg CRESET_;

//Clocked Outputs
reg RE_o;
reg WE_o;
reg SCSI_CS_o;
reg DACK_o;
reg INCBO_o;
reg INCNO_o;
reg INCNI_o;
reg S2F_o;
reg F2S_o;
reg S2CPU_o;
reg CPU2S_o;


wire RE;
wire WE;
wire SCSI_CS;
wire DACK;
wire INCBO;
wire INCNO;
wire INCNI;
wire S2F;
wire F2S;
wire S2CPU;
wire CPU2S;

wire nRW;
wire nDMADIR;
wire nFIFOFULL;
wire nCCPUREQ;
wire nCDREQ_;
wire nCDSACK_;

wire nCLK; // CPUCLK Inverted
wire BCLK; // CPUCLK inverted 4 times for delay.
wire BBCLK; // CPUCLK Inverted 6 time for delay.

wire E0_;
wire E1_;
wire E2_;
wire E3_;
wire E4_;
wire E5_;
wire E6_;
wire E7_;
wire E8_;
wire E9_;
wire E10_;
wire E11_;
wire E12_;
wire E13_;
wire E14_;
wire E15_;
wire E16_;
wire E17_;
wire E18_;
wire E19_;
wire E20_;
wire E21_;
wire E22_;
wire E23_;
wire E24_;
wire E25_;
wire E26_;
wire E27_;

wire scsidff1_d;
wire scsidff2_d;
wire scsidff3_d;
wire scsidff4_d;
wire scsidff5_d;

wire scsidff1_q;
wire scsidff2_q;
wire scsidff3_q;
wire scsidff4_q;
wire scsidff5_q;

//clocked reset
always @(posedge  nCLK) begin
    CRESET_ <= RESET_;

    if(RESET_ == 1'b0) begin     
        CDSACK_ <= 1'b0;
    end
end

//clocked inputs.
always @(posedge  BBCLK or negedge CRESET_) begin
    if (CRESET_ == 1'b0) 
        CDSACK_ <= 1'b0;
    else 
    begin
        CCPUREQ <= CPUREQ;
        CDREQ_ <= DREQ_;
        CDSACK_ <= DSACK_;   
    end
end

//Clocked outputs.
always @(posedge BCLK) begin
    RE_o <= RE;
    WE_o <= WE;
    SCSI_CS_o <= SCSI_CS;
    DACK_o <= DACK;
    INCBO_o <= INCBO;
    INCNO_o <= INCNO;
    INCNI_o <= INCNI;
    S2F_o <= S2F;
    F2S_o <= F2S;
    S2CPU_o <= S2CPU;
    CPU2S_o <= CPU2S;    
end

//State Machine
always @(posedge BCLK or negedge CRESET_) begin
    if (CRESET_ == 1'b0) 
        state <= 5'b00000;
    else
        state <= {scsidff5_d, scsidff4_d, scsidff3_d, scsidff2_d, scsidff1_d};
end

assign nCLK = ~CPUCLK;
assign BCLK = CPUCLK; // may need to change this to add delays
assign BBCLK = CPUCLK; // may need to change this to add delays

assign nRW = ~RW;
assign nDMADIR = ~DMADIR;
assign nFIFOFULL = ~FIFOFULL;
assign nCCPUREQ = ~CCPUREQ;
assign nCDREQ_ = ~CDREQ_;
assign nCDSACK_ = ~CDSACK_;

assign scsidff1_q = state[0];
assign scsidff2_q = state[1];
assign scsidff3_q = state[2];
assign scsidff4_q = state[3];
assign scsidff5_q = state[4];

endmodule







