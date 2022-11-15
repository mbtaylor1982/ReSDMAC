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
`include "RTL/FIFO/fifo_write_strobes.v"
`include "RTL/FIFO/fifo_full_empty_ctr.v"

module fifo(
    
    input LLWORD,       //Load Lower Word strobe from CPU sm
    input LHWORD,       //Load Higher Word strobe from CPU sm
    
    input LBYTE_,       //Load Byte strobe from SCSI SM = !(DACK.o & RE.o)

    input h_0C,         //Address Decode for $0C ACR register
    input ACR_WR,       //indicate write to ACR?
    input RST_FIFO_,    //Reset FIFO
    input MID25,        //think this may be checking A1 in the ACR to see if this was a 16 or 32 bit transfer

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

    output [31:0] OD    //FIFO Data Output
);

fifo_write_strobes u_fifo_write_strobes(
    .BO0    (BO0    ),
    .BO1    (BO1    ),
    .LHWORD (LHWORD ),
    .LLWORD (LLWORD ),
    .LBYTE_ (LBYTE_ ),
    .UUWS   (UUWS   ),
    .UMWS   (UMWS   ),
    .LMWS   (LMWS   ),
    .LLWS   (LLWS   )
);

fifo__full_empty_ctr u_fifo__full_empty_ctr(
    .INCFIFO   (INCFIFO   ),
    .DECFIFO   (DECFIFO   ),
    .RST_FIFO_ (RST_FIFO_ ),
    .FIFOEMPTY (FIFOEMPTY ),
    .FIFOFULL  (FIFOFULL  )
);

reg [31:0] buffer [7:0]; //32 byte FIFO buffer (8 x 32 bit long words)

reg [2:0] ReadPtr;
reg [2:0] WritePtr;
reg [1:0] BytePtr;

wire UUWS;
wire UMWS;
wire LMWS;
wire LLWS;
wire MUXZ;

//NEXT IN POINTER
always @(posedge INCNI, negedge RST_FIFO_) begin
    if (RST_FIFO_ == 1'b0)
        WritePtr <= 3'b000;
    else
        WritePtr <= WritePtr + 1;     
end

//NEXT OUT POINTER
always @(posedge INCNO, negedge RST_FIFO_) begin
    if (RST_FIFO_ == 1'b0)
        ReadPtr <= 3'b000;
    else
        ReadPtr <= ReadPtr + 1;     
end

//BYTE POINTER

always @(posedge ACR_WR or posedge INCBO or negedge RST_FIFO_) begin
    if (RST_FIFO_ == 1'b0) 
        BytePtr <= 2'b00;
    else begin
        if (INCBO) BytePtr <= {MUXZ, ~BytePtr[0]};
        if (ACR_WR) BytePtr[1] <= MUXZ;        
    end    
end

//WRITE DATA TO FIFO BUFFER
always @(posedge UUWS) begin
  buffer[WritePtr][31:24] <= ID[31:24];
end

always @(posedge UMWS) begin
  buffer[WritePtr][23:16] <= ID[23:16];
end

always @(posedge LMWS) begin
  buffer[WritePtr][15:8] <= ID[15:8];
end

always @(posedge LLWS) begin
  buffer[WritePtr][7:0] <= ID[7:0];
end

//BYTE COUNTER FLAGS

assign BO0 = BytePtr[0];
assign BO1 = BytePtr[1];

assign BOEQ0 = (BytePtr == 2'b00);
assign BOEQ3 = (BytePtr == 2'b11);

//ASYNCH READ ACCESS TO FIFO DATA BUFFER
assign OD = (buffer[ReadPtr]);

assign MUXZ = (h_0C)? ~MID25:(BO0^~BO1);

endmodule