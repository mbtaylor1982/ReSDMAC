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
    `include "RTL/Registers/addr_decoder.v"
`endif

module registers(
  input [7:0] ADDR,     // CPU address Bus
  input DMAC_,          // SDMAC Chip Select !SCSI from Fat Garry.
  input AS_,            // CPU Address Strobe.
  input RW,             // CPU Read Write Control Line.
  input nCPUCLK,
  input [31:0] MID,     //DATA IN
  input STOPFLUSH,
  input RST_,
  input FIFOEMPTY,
  input FIFOFULL,
  

  output [31:0] MOD,    //DATA OUT.
  output PRESET,        //Peripheral Reset.
  output reg FLUSHFIFO, //Flush FIFO.
  output reg DMAENA,    //DMA Enabled.
  output ACR_WR,        //input to FIFO_byte_ptr.
  output h_0C,          //input to FIFO_byte_ptr.
  output reg A1         //Store value of A1 written to ACR.  
    
);

addr_decoder u_addr_decoder(
    .ADDR      (ADDR      ),
    .DMAC_     (DMAC_     ),
    .AS_       (AS_       ),
    .RW        (RW        ),
    .DMADIR    (DMADIR    ),
    .h_0C      (h_0C      ),
    .WDREGREQ  (WDREGREQ  ),
    .WTC_RD_   (WTC_RD_   ), 
    .CONTR_RD_ (CONTR_RD_ ),
    .CONTR_WR  (CONTR_WR  ),
    .ISTR_RD_  (ISTR_RD_  ),
    .ACR_WR    (ACR_WR    ),
    .ST_DMA    (ST_DMA    ),
    .SP_DMA    (SP_DMA    ),
    .CLR_INT   (CLR_INT   ),
    .FLUSH_    (FLUSH_    )
);

wire WDREGREQ;
wire CONTR_RD_;
wire CONTR_WR;
wire ISTR_RD_;
wire WTC_RD_;

//Action strobes
wire ST_DMA;    //Start DMA 
wire SP_DMA;    //Stop DMA 
wire CLR_INT;   //Clear Interrupts
wire FLUSH_;    //Flush FIFO

//Registers
//reg [1:0] DAWR;       //Data Acknowledge Width
reg [5:0] CNTR;         //Control Register
reg [8:0] ISTR;         //Interrupt Status Register

//DMA Enable Control
wire CLR_DMAENA;
assign CLR_DMAENA = (SP_DMA & RST_);

always @(negedge ST_DMA or negedge CLR_DMAENA) begin
    if (ST_DMA == 1'b0) begin
        DMAENA <= 1'b1;    
    end else if(CLR_DMAENA == 1'b0) begin
        DMAENA <= 1'b0;
    end
end

//FIFOFLUSH control
wire CLR_FLUSHFIFO;
assign CLR_FLUSHFIFO = ~(STOPFLUSH | ~RST_);

always @(negedge FLUSH_ or negedge CLR_FLUSHFIFO) begin
    if (FLUSH_ == 1'b0) begin
        FLUSHFIFO <= 1'b1;    
    end else if(CLR_FLUSHFIFO == 1'b0) begin
        FLUSHFIFO <= 1'b0;
    end
end

//Write to Control Register
always @(posedge CONTR_WR or negedge RST_) begin
    if (RST_ == 1'b0) begin
        CNTR <= 6'b000000;
    end
    else if (CONTR_WR == 1'b1) begin
      CNTR <= MID[5:0];
    end   
end

//Store value of A1 loaded into ACR
always @(posedge ACR_WR or negedge RST_) begin
    if (RST_ == 1'b0) begin
        A1 <= 1'b0;
    end
    else if (ACR_WR == 1'b1) begin
      A1 <= MID[25];
    end   
end

/*drive output data onto bus.
always @(*) begin
    if (CONTR_RD_ == 1'b0) begin
        MOD[31:0]  = {24'hzzzzzz, 2'bzz, CNTR};
    end else if (ISTR_RD_ == 1'b0) begin
        MOD[31:0]  = {16'hzzzz, 7'bzzzzzzz, ISTR};    
    end else if (WTC_RD_ == 1'b0) begin
        MOD[31:0]  = {24'hzzzzzz, 8'bzzzz0zz};
    end else begin
        MOD[31:0]  = 32'hzzzzzzzz;
    end
end
*/

//drive output data onto bus.
assign MOD[31:0] = CONTR_RD_    ? 32'hzzzzzzzz : {24'hzzzzzz, 2'bzz, CNTR};
assign MOD[31:0] = ISTR_RD_     ? 32'hzzzzzzzz : {16'hzzzz, 7'bzzzzzzz, ISTR};
assign MOD[31:0] = WTC_RD_      ? 32'hzzzzzzzz : {24'hzzzzzz, 8'bzzzz0zz};


endmodule