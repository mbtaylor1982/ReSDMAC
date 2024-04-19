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
  `include "mux2.v"
`endif
module fifo_byte_ptr(
    input CLK,
    input INCBO,
    input MID25, //MID25 is used to set the MSB of the BytePtr depending on if it is a transfer to odd or even address
    input ACR_WR,
    input H_0C,
    input RST_FIFO_,

    output [1:0] PTR
);


wire A;
wire Z;
reg B;
reg S;
reg BO0;
reg BO1;

    MUX2 u_MUX2 (
        .A  (A),  // input A,
        .B  (B),  // input B,
        .S  (S),  // select,
        .Z  (Z)   // output,
    );

assign A = ~(BO1 ^ BO0);
assign PTR = {BO1, BO0};

//added to eliminate glitches in the signals B and S.
always @(posedge CLK or negedge RST_FIFO_) begin
    if (~RST_FIFO_) begin
        B <= 1'b0;
        S <= 1'b0;
    end
    else begin
        B <= ~MID25;
        S <= H_0C;
    end
end

always @(posedge CLK or negedge RST_FIFO_) begin
    if (~RST_FIFO_) begin
        BO0 <= 1'b0;
        BO1 <= 1'b0;
    end
    else begin
        if (INCBO) begin
            BO0 <= ~BO0;
            BO1 <= Z;
        end
        if (ACR_WR)
            BO1 <= Z;
    end
end

endmodule