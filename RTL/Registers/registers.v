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
    `include "RTL/Registers/registers_istr.v"
    `include "RTL/Registers/registers_cntr.v"
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
  input INTA_I,
  

  output [31:0] MOD,    //DATA OUT.
  output PRESET,        //Peripheral Reset.
  output reg FLUSHFIFO, //Flush FIFO.
  output ACR_WR,        //input to FIFO_byte_ptr.
  output h_0C,          //input to FIFO_byte_ptr.
  output reg A1,        //Store value of A1 written to ACR.  
  output INT_O_,        //INT_2 Output.
  output DMADIR,        //DMA Direction
  output DMAENA         //DMA Enabled.  
);

wire WDREGREQ;
wire CONTR_RD_;
wire CONTR_WR;
wire ISTR_RD_;
wire WTC_RD_;
wire INTENA;

//Action strobes
wire ST_DMA;    //Start DMA 
wire SP_DMA;    //Stop DMA 
wire CLR_INT;   //Clear Interrupts
wire FLUSH_;    //Flush FIFO

//Registers
wire [8:0] ISTR_O;  //Interrupt Status Register
wire [8:0] CNTR_O;  //Control Register

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

registers_istr u_registers_istr(
    .RESET_    (RST_      ),
    .FIFOEMPTY (FIFOEMPTY ),
    .FIFOFULL  (FIFOFULL  ),
    .CLR_INT   (CLR_INT   ),
    .ISTR_RD_  (ISTR_RD_  ),
    .INTENA    (INTENA    ),
    .INTA_I    (INTA_I    ),
    .ISTR_O    (ISTR_O    ),
    .INT_O_    (INT_O_    )
);

registers_cntr u_registers_cntr(
    .RESET_    (RST_      ),
    .CONTR_WR  (CONTR_WR  ),
    .ST_DMA    (ST_DMA    ),
    .SP_DMA    (SP_DMA    ),
    .MID       (MID[8:0]  ),
    .CNTR_O    (CNTR_O    ),
    .INTENA    (INTENA    ),
    .PRESET    (PRESET    ),
    .DMADIR    (DMADIR    ),
    .DMAENA    (DMAENA    )
);

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

//Store value of A1 loaded into ACR
always @(posedge ACR_WR or negedge RST_) begin
    if (RST_ == 1'b0) begin
        A1 <= 1'b0;
    end
    else if (ACR_WR == 1'b1) begin
      A1 <= MID[25];
    end   
end

//drive output data onto bus.
assign MOD[31:0] = CONTR_RD_    ? 32'hzzzzzzzz : {16'hzzzz, 7'bzzzzzzz, CNTR_O};
assign MOD[31:0] = ISTR_RD_     ? 32'hzzzzzzzz : {16'hzzzz, 7'bzzzzzzz, ISTR_O};
assign MOD[31:0] = WTC_RD_      ? 32'hzzzzzzzz : {24'hzzzzzz, 8'bzzzz0zz};

endmodule