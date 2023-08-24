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
  `include "RTL/FIFO/fifo_write_strobes.v"
  `include "RTL/FIFO/fifo_full_empty_ctr.v"
  `include "RTL/FIFO/fifo_3bit_cntr.v"
  `include "RTL/FIFO/fifo_byte_ptr.v"
`endif

module fifo(
    
    input CLK, BCLK, BBCLK, //Clocks

    input LLWORD,       //Load Lower Word strobe from CPU sm
    input LHWORD,       //Load Higher Word strobe from CPU sm
    
    input LBYTE_,       //Load Byte strobe from SCSI SM = !(DACK.o & RE.o)

    input H_0C,         //Address Decode for $0C ACR register
    input ACR_WR,       //indicate write to ACR?
    input RST_FIFO_,    //Reset FIFO
    input MID25,        //think this may be checking A1 in the ACR to make sure BYTE PTR is initialised to the correct value.

    input [31:0] ID,    //FIFO Data Input

    output FIFOFULL,    //Signal FIFO is FULL
    output FIFOEMPTY,   //Signal FIFO is Empty

    input INCFIFO,      //Inc FIFO from CPU sm
    input DECFIFO,      //Dec FIFO from CPU sm

    input INCBO,        //Inc Byte Pointer from SCSI SM.

    output BOEQ0,       //True when BytePtr indicates 1st Byte
    output BOEQ3,       //True when BytePtr indicates 4th Byte

    output BO0,         //BytePtr Bit 0
    output BO1,         //BytePtr Bit 1

    input INCNO,        //Inc Next Out (Write Pointer)
    input INCNI,        //Inc Next In (Read Pointer)

    output  [31:0] OD    //FIFO Data Output
);

wire [2:0] WRITE_PTR;
wire [2:0] READ_PTR;
wire [1:0] BYTE_PTR;
wire UUWS;
wire UMWS;
wire LMWS;
wire LLWS;

fifo_write_strobes u_write_strobes(
    .PTR    (BYTE_PTR ),
    .LHWORD (LHWORD   ),
    .LLWORD (LLWORD   ),
    .LBYTE_ (LBYTE_   ),
    .UUWS   (UUWS     ),
    .UMWS   (UMWS     ),
    .LMWS   (LMWS     ),
    .LLWS   (LLWS     )
);

fifo__full_empty_ctr u_full_empty_ctr(
    .CLK       (BBCLK     ),
    .INCFIFO   (INCFIFO   ),
    .DECFIFO   (DECFIFO   ),
    .RST_FIFO_ (RST_FIFO_ ),
    .FIFOEMPTY (FIFOEMPTY ),
    .FIFOFULL  (FIFOFULL  )
);

//Next In Write Counter
fifo_3bit_cntr u_next_in_cntr(
    .CLK       (BBCLK     ),
    .ClKEN     (INCNI     ),
    .RST_      (RST_FIFO_ ),
    .COUNT     (WRITE_PTR )
);

//Next Out Read Counter
fifo_3bit_cntr u_next_out_cntr(
    .CLK       (BBCLK     ),
    .ClKEN     (INCNO     ),
    .RST_      (RST_FIFO_ ),
    .COUNT     (READ_PTR  )
);

//BYTE POINTER
fifo_byte_ptr u_byte_ptr(
  .CLK       (BBCLK     ),
  .INCBO     (INCBO     ),
  .MID25     (MID25     ),
  .ACR_WR    (ACR_WR    ),
  .H_0C      (H_0C      ),
  .RST_FIFO_ (RST_FIFO_ ),
  .PTR       (BYTE_PTR  )
);

assign BO0 = BYTE_PTR[0];
assign BO1 = BYTE_PTR[1];

assign BOEQ0 = (BYTE_PTR == 2'b00);
assign BOEQ3 = (BYTE_PTR == 2'b11);

//32 byte FIFO buffer (8 x 32 bit long words)
reg [31:0] BUFFER [7:0]; 

//WRITE DATA TO FIFO BUFFER
always @(negedge UUWS) begin
  if (~UUWS)
    BUFFER[WRITE_PTR][31:24] <= ID[31:24];
end

always @(negedge UMWS) begin
  if (~UMWS)
    BUFFER[WRITE_PTR][23:16] <= ID[23:16];
end

always @(negedge LMWS) begin
  if (~LMWS)
    BUFFER[WRITE_PTR][15:8] <= ID[15:8];
end

always @(negedge LLWS) begin
  if (~LLWS)
    BUFFER[WRITE_PTR][7:0] <= ID[7:0];
end

//always @(READ_PTR, BUFFER[READ_PTR]) begin
//always @(READ_PTR) begin
//  OD <= BUFFER[READ_PTR];
//end

//ASYNCH READ ACCESS TO FIFO DATA BUFFER
assign OD = (BUFFER[READ_PTR]);

endmodule