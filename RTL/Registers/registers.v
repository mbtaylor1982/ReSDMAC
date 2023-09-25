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
    `include "addr_decoder.v"
    `include "registers_istr.v"
    `include "registers_cntr.v"
    `include "registers_term.v"
`endif

module registers(
  input [7:0] ADDR,     // CPU address Bus
  input DMAC_,          // SDMAC Chip Select !SCSI from Fat Garry.
  input AS_,            // CPU Address Strobe.
  input RW,             // CPU Read Write Control Line.
  input CLK,            // System Clock
  input [31:0] MID,     // DATA IN
  input STOPFLUSH,      //
  input RST_,           // System Reset
  input FIFOEMPTY,      // FIFO Emtpty Flag
  input FIFOFULL,       // FIFO Full Flag
  input INTA_I,         //

  output [31:0] REG_OD,     //DATA OUT.
  output PRESET,            //Peripheral Reset.
  output reg FLUSHFIFO,     //Flush FIFO.
  output ACR_WR,            //input to FIFO_byte_ptr.
  output h_0C,              //input to FIFO_byte_ptr.
  output reg A1,            //Store value of A1 written to ACR.
  output INT_O_,            //INT_2 Output.
  output DMADIR,            //DMA Direction
  output DMAENA,            //DMA Enabled.
  output REG_DSK_,          //Register Cycle Term.
  output WDREGREQ           //SCSI IC Cycle Term.
);

wire CONTR_RD_;
wire CONTR_WR;
wire ISTR_RD_;
wire WTC_RD_;
wire INTENA;
wire SSPBDAT_RD_;
wire SSPBDAT_WR;

//Action strobes
wire ST_DMA;    //Start DMA 
wire SP_DMA;    //Stop DMA 
wire CLR_INT;   //Clear Interrupts
wire FLUSH_;    //Flush FIFO

//Registers
wire [8:0] ISTR_O;  //Interrupt Status Register
wire [8:0] CNTR_O;  //Control Register
reg [31:0] SSPBDAT;  //Fake Synchronous Serial Peripheral Bus Data Register (used to test SDMAC rev 4 in the test toll by CDH)

wire [31:0] WTC;
wire [31:0] CNTR;
wire [31:0] ISTR;


//Address Decoding and Strobes
addr_decoder u_addr_decoder(
    .ADDR       (ADDR      ),
    .DMAC_      (DMAC_     ),
    .AS_        (AS_       ),
    .RW         (RW        ),
    .DMADIR     (DMADIR    ),
    .h_0C       (h_0C      ),
    .WDREGREQ   (WDREGREQ  ),
    .WTC_RD_    (WTC_RD_   ), 
    .CONTR_RD_  (CONTR_RD_ ),
    .CONTR_WR   (CONTR_WR  ),
    .ISTR_RD_   (ISTR_RD_  ),
    .ACR_WR     (ACR_WR    ),
    .ST_DMA     (ST_DMA    ),
    .SP_DMA     (SP_DMA    ),
    .CLR_INT    (CLR_INT   ),
    .FLUSH_     (FLUSH_    ),
    .SSPBDAT_WR (SSPBDAT_WR),
    .SSPBDAT_RD_ (SSPBDAT_RD_)
);

//Interupt Status Register
registers_istr u_registers_istr(
    .RESET_    (RST_      ),
    .CLK       (CLK       ),
    .FIFOEMPTY (FIFOEMPTY ),
    .FIFOFULL  (FIFOFULL  ),
    .CLR_INT   (CLR_INT   ),
    .ISTR_RD_  (ISTR_RD_  ),
    .INTENA    (INTENA    ),
    .INTA_I    (INTA_I    ),
    .ISTR_O    (ISTR_O    ),
    .INT_O_    (INT_O_    )
);

//Control Register
registers_cntr u_registers_cntr(
    .RESET_    (RST_      ),
    .CLK       (CLK       ),
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

//DSACK timing.
registers_term u_registers_term(
    .CLK      (CLK      ),
    .AS_      (AS_      ),
    .DMAC_    (DMAC_    ),
    .WDREGREQ (WDREGREQ ),
    .h_0C     (h_0C     ),
    .REG_DSK_ (REG_DSK_ )
);

//FIFOFLUSH control
wire CLR_FLUSHFIFO;
assign CLR_FLUSHFIFO = ~STOPFLUSH;

always @(negedge CLK or negedge RST_) begin
    if (~RST_)
        FLUSHFIFO <= 1'b0;
    else if (~FLUSH_)
        FLUSHFIFO <= 1'b1;
	 else	if (~CLR_FLUSHFIFO)
		FLUSHFIFO <= 1'b0;
end

//Store value of A1 loaded into ACR
always @(negedge CLK or negedge RST_) begin
    if (RST_ == 1'b0)
        A1 <= 1'b0;
    else if (ACR_WR)
        A1 <= MID[25];
end

//Fake SSPBDAT register (only used for testing read and write cycles)
always @(negedge CLK or negedge RST_) begin
    if (RST_ == 1'b0)
        SSPBDAT <= 32'b0;
    else if (SSPBDAT_WR)
        SSPBDAT <= MID[31:0];
end

//drive output data onto bus.
assign WTC  = WTC_RD_   ? 32'h00000000  : {32'h00000004};
assign ISTR = ISTR_RD_  ? (WTC)  : {13'h0, ISTR_O};
assign CNTR = CONTR_RD_ ? (ISTR) : {23'h0, CNTR_O};

assign REG_OD = SSPBDAT_RD_ ? CNTR : SSPBDAT;

endmodule