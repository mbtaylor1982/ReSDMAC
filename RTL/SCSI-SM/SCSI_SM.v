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
    
    output SET_DSACK,
    
    input CPUREQ,
    input RW,
    input DMADIR,
    
    input RDFIFO_o,
    output RDFIFO_d,
    
    input RIFIFO_o,
    output RIFIFO_d,
    
    input RESET_,
    input BOEQ3,
    input CPUCLK,
    
    output RE_o,
    output WE_o,
    output SCSI_CS_o,
    output DACK_o,
    
    input DREQ_,
    
    output INCBO_o,
    output INCNO_o,
    output INCNI_o,
    
    input FIFOFULL,
    input FIFOEMPTY,
    
    output S2F_o,
    output F2S_o,
    output S2CPU_o,
    output PU2S_o
);

localparam S0 = 5'b00000;
localparam S1 = 5'b00001;
localparam S2 = 5'b00010;
localparam S3 = 5'b00011;
localparam S4 = 5'b00100;
localparam S5 = 5'b00101;
localparam S6 = 5'b00110;
localparam S7 = 5'b00111;
localparam S8 = 5'b01000;
localparam S9 = 5'b01001;
localparam S10 = 5'b01010;
localparam S11 = 5'b01011;
localparam S12 = 5'b01100;
localparam S13 = 5'b01101;
localparam S14 = 5'b01110;
localparam S15 = 5'b01111;
localparam S16 = 5'b10000;
localparam S17 = 5'b10001;
localparam S18 = 5'b10010;
localparam S19 = 5'b10011;
localparam S20 = 5'b10100;
localparam S21 = 5'b10101;
localparam S22 = 5'b10110;
localparam S23 = 5'b10111;
localparam S24 = 5'b11000;
localparam S25 = 5'b11001;
localparam S26 = 5'b11010;
localparam S27 = 5'b11011;
localparam S28 = 5'b11100;
localparam S29 = 5'b11101;
localparam S30 = 5'b11110;
localparam S31 = 5'b11111;

reg [5:0] state = S0;

reg CCPUREQ;
reg CDREQ_;
reg CDSACK_;
reg CRESET_;

wire nRW;
wire nDMADIR;
wire nFIFOFULL;
wire nCCPUREQ;
wire nCDREQ_;
wire nCDSACK_;

wire nCLK; // CPUCLK Inverted
wire BCLK; // CPUCLK inverted 4 times for delay.
wire BBCLK; // CPUCLK Inverted 6 time for delay.


//clocked reset
always @(posedge  nCLK) begin
    CRESET_ <= RESET_;

    if(RESET_ == 1'b0) begin     
        CDSACK_ <= 1'b0;
    end
end

//clocked inputs.
always @(posedge  BBCLK) begin
    CCPUREQ <= CPUREQ;
    CDREQ_ <= DREQ_;
    CDSACK_ <= DSACK_; 
end

//Clocked outputs.
always @(posedge BCLK) begin
    
end

//State Machine
always @(posedge BCLK, negedge CRESET_) begin
    if(CRESET_ == 1'b0) 
        begin
            state <= 5'b00000;
        end
    else
        begin
            
        end
end

assign nCLK = !CPUCLK;
assign BCLK = CPUCLK; // may need to change this to add delays
assign BBCLK = CPUCLK; // may need to change this to add delays

assign nRW = !RW;
assign nDMADIR = !DMADIR;
assign nFIFOFULL = !FIFOFULL;
assign nCCPUREQ = !CCPUREQ;
assign nCDREQ_ = !CDREQ_;
assign nCDSACK_ = !CDSACK_;

endmodule







