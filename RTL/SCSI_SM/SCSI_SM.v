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
(   input BOEQ3,            //Asserted when transfering Byte 3
    input CPUCLK,           //CPU CLK
    input CPUREQ,           //Request CPU access to SCSI registers.
    input DECFIFO,          //Decremt FIFO pointer
    input DMADIR,           //Control Direction Of DMA transfer.
    input DREQ_,            //Data transfer request from SCSI IC
    input FIFOEMPTY,        //FIFOFULL flag
    input FIFOFULL,         //FIFO EMPTY flag
    input INCFIFO,          //Increment FIFO pointer
    input nAS_,             //Inverted CPU Address Strobe
    input RESET_,           //System Reset
    input RW,               //CPU RW signal

    output reg CPU2S_o,     //Indicate CPU to SCSI Transfer
    output reg DACK_o,      //SCSI IC Data request Acknowledge
    output reg F2S_o,       //Indicate FIFO to SCSI Transfer
    output reg INCBO_o,     //Increment FIFO Byte Pointer
    output reg INCNI_o,     //Increment FIFO Next In Pointer
    output reg INCNO_o,     //Increement FIFO Next Out Pointer
    output reg RDFIFO_o,    //Read Longword from FIFO
    output reg RE_o,        //Read indicator to SCSI IC
    output reg RIFIFO_o,    //Write Longword to FIFO
    output reg S2CPU_o,     //Indicate SCSI to CPU Transfer
    output reg S2F_o,       //Indicate SCSI to FIFO Transfer
    output reg SCSI_CS_o,   //Chip Select for SCSI IC
    output reg WE_o,        //Write indicator to SCSI IC
    output wire LBYTE_,     //Load byte signal for FIFO
    output wire LS2CPU      //Latch SCSI to CPU DATA, Also indicates CPU Cycle Termination
);

reg [4:0] STATE;

//Clocked inputs
reg CCPUREQ;
reg CDREQ_;
reg CDSACK_;
reg CRESET_;

wire BBCLK; // CPUCLK Inverted 6 time for delay.
wire BCLK; // CPUCLK Inverted 4 times for delay.
wire CPU2S;
wire DACK;
wire DSACK_;
wire F2S;
wire INCBO;
wire INCNI;
wire INCNO;
wire nCLK; 
wire RDRST_;
wire RE;
wire RIRST_;
wire S2CPU;
wire S2F;
wire SCSI_CS;
wire SET_DSACK;
wire WE;

reg RDFIFO_d;
reg RIFIFO_d;
reg nLS2CPU;

wire [27:0] E;
wire [4:0] NEXT_STATE;

scsi_sm_inputs u_scsi_sm_inputs(
    .BOEQ3      (BOEQ3      ),
    .CCPUREQ    (CCPUREQ    ),
    .CDREQ_     (CDREQ_     ),
    .CDSACK_    (CDSACK_    ),
    .DMADIR     (DMADIR     ),
    .E          (E          ),
    .FIFOEMPTY  (FIFOEMPTY  ),
    .FIFOFULL   (FIFOFULL   ),
    .RDFIFO_o   (RDFIFO_o   ),
    .RIFIFO_o   (RIFIFO_o   ),
    .RW         (RW         ),
    .STATE      (STATE      )
);

scsi_sm_outputs u_scsi_sm_outputs(
    .CPU2S      (CPU2S      ),
    .DACK       (DACK       ),
    .E          (E          ),
    .F2S        (F2S        ),
    .INCBO      (INCBO      ),
    .INCNI      (INCNI      ),
    .INCNO      (INCNO      ),
    .NEXT_STATE (NEXT_STATE ), 
    .RE         (RE         ),
    .S2CPU      (S2CPU      ),
    .S2F        (S2F        ),
    .SCSI_CS    (SCSI_CS    ),
    .SET_DSACK  (SET_DSACK  ),
    .WE         (WE         )
);

//clocked reset
always @(posedge  nCLK) begin
    CRESET_ <= RESET_;
end

//clocked inputs.
always @(posedge  BBCLK or negedge CRESET_) begin
    if (CRESET_ == 1'b0)
    begin 
        CDSACK_ <= 1'b1;
        CCPUREQ <= 1'b0;
        CDREQ_ <= 1'b0;
    end
    else 
    begin
        CCPUREQ <= CPUREQ;
        CDREQ_ <= DREQ_;
        CDSACK_ <= DSACK_;   
    end
end

//Clocked outputs.
always @(posedge BCLK) begin
    CPU2S_o <= CPU2S;   
    DACK_o <= DACK;
    F2S_o <= F2S;
    INCBO_o <= INCBO;
    INCNI_o <= INCNI;
    INCNO_o <= INCNO;
    RDFIFO_d <= E[3];
    RE_o <= RE;
    RIFIFO_d <=  E[4];
    S2CPU_o <= S2CPU;
    S2F_o <= S2F;
    SCSI_CS_o <= ~SCSI_CS;
    WE_o <= WE;
end

//State Machine
always @(posedge BCLK or negedge CRESET_) begin
    if (CRESET_ == 1'b0)
        STATE <= 5'b00000;
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

assign LS2CPU = ~nLS2CPU;
assign DSACK_ = LS2CPU;
assign LBYTE_ = ~(DACK_o & RE_o);

assign RDRST_ = ~(~RESET_ | DECFIFO);
assign RIRST_ = ~(~RESET_ | INCFIFO);

endmodule







