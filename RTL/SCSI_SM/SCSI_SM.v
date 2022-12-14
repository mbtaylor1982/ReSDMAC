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
    `include "RTL/SCSI_SM/scsi_sm_inputs.v"
    `include "RTL/SCSI_SM/scsi_sm_outputs.v"
`endif

module SCSI_SM
(   input CPUREQ,
    input RW,
    input DMADIR,   
    input INCFIFO,
    input DECFIFO, 
    input RESET_,
    input BOEQ3,
    input CPUCLK,
    input DREQ_,
    input FIFOFULL,
    input FIFOEMPTY,
    input nAS_,

    output reg RDFIFO_o,
    output reg RIFIFO_o,
    output reg RE_o,
    output reg WE_o,
    output reg SCSI_CS_o,
    output reg DACK_o,
    output reg INCBO_o,
    output reg INCNO_o,
    output reg INCNI_o,
    output reg S2F_o,
    output reg F2S_o,
    output reg S2CPU_o,
    output reg CPU2S_o,
    output wire LS2CPU,
    output wire LBYTE_
);

localparam INITIAL_STATE = 5'b00000;

reg [4:0] STATE;

//Clocked inputs
reg CCPUREQ;
reg CDREQ_;
reg CDSACK_;
reg CRESET_;

wire DSACK_;
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

reg RDFIFO_d;
reg RIFIFO_d;
reg nLS2CPU;

wire RDRST_;
wire RIRST_;

wire nRW;
wire nDMADIR;
wire nFIFOFULL;
wire nCCPUREQ;
wire nCDREQ_;
wire nCDSACK_;

wire nCLK; // CPUCLK Inverted
wire BCLK; // CPUCLK Inverted 4 times for delay.
wire BBCLK; // CPUCLK Inverted 6 time for delay.

wire [27:0] E;
wire [4:0] NEXT_STATE;

scsi_sm_inputs u_scsi_sm_inputs(
    .STATE      (STATE),
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
    .E          (E          )
);

scsi_sm_outputs u_scsi_sm_outputs(
    .E          (E          ),
    .NEXT_STATE (NEXT_STATE ), 
    .DACK       (DACK       ),
    .INCBO      (INCBO      ),
    .INCNI      (INCNI      ),
    .INCNO      (INCNO      ),
    .RE         (RE         ),
    .WE         (WE         ),
    .SCSI_CS    (SCSI_CS    ),
    .SET_DSACK  (SET_DSACK  ),
    .S2F        (S2F        ),
    .F2S        (F2S        ),
    .S2CPU      (S2CPU      ),
    .CPU2S      (CPU2S      )
);

//clocked reset
always @(posedge  nCLK) begin
    CRESET_ <= RESET_;
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
    SCSI_CS_o <= ~SCSI_CS;
    DACK_o <= DACK;
    INCBO_o <= INCBO;
    INCNO_o <= INCNO;
    INCNI_o <= INCNI;
    S2F_o <= S2F;
    F2S_o <= F2S;
    S2CPU_o <= S2CPU;
    CPU2S_o <= CPU2S;   
    RDFIFO_d <= E[3];
    RIFIFO_d <=  E[4];
end

//State Machine
always @(posedge BCLK or negedge CRESET_) begin
    if (CRESET_ == 1'b0)
        STATE <= INITIAL_STATE;
    else
        STATE <= NEXT_STATE;
end

always @(posedge RDFIFO_d or negedge RDRST_) begin
    if (RDRST_ == 1'b0) 
        RDFIFO_o <= 1'b0;
    else
        RDFIFO_o <= 1'b1;
end

always @(posedge RIFIFO_d or negedge RIRST_) begin
    if (RIRST_ == 1'b0) 
        RIFIFO_o <= 1'b0;
    else
        RIFIFO_o <= 1'b1;
end

always @(posedge SET_DSACK or negedge nAS_) begin
    if (nAS_ == 1'b0)
        nLS2CPU <= 1'b0;
    else
        nLS2CPU <= 1'b1;
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
assign LS2CPU = ~nLS2CPU;
assign DSACK_ = LS2CPU;
assign LBYTE_ = ~(DACK_o & RE_o);

assign RDRST_ = ~(~RESET_ | DECFIFO);
assign RIRST_ = ~(~RESET_ | INCFIFO);

endmodule







