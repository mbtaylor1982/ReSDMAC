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
module datapath_input (
    inout [31:0] DATA,
    input bBRIDGEIN,
    input bDIEH,
    input bDIEL,
    input BnDS_O_,

    output [31:0] MID,
    output [31:0] ID
);

wire [15:0] LOWER_INPUT_DATA;
wire [15:0] UPPDER_INTPUT_DATA;

wire [15:0] LOWER_OUTPUT_DATA;
wire [15:0] UPPDER_OUTPUT_DATA;

reg [15:0] UD_LATCH;

always @(posedge BnDS_O_) begin
     if (BnDS_O_ == 1'b1)
        UD_LATCH <= UPPDER_INTPUT_DATA;   
end

assign LOWER_INPUT_DATA = DATA[15:0];
assign UPPDER_INTPUT_DATA = DATA[31:16];

assign UPPDER_OUTPUT_DATA = bDIEH ? LOWER_INPUT_DATA : 16'hzzz;
assign LOWER_OUTPUT_DATA = bDIEL ? LOWER_INPUT_DATA : 16'hzzz;
assign LOWER_OUTPUT_DATA = bBRIDGEIN ? UD_LATCH : 16'hzzz;

assign ID = {UPPDER_OUTPUT_DATA, LOWER_OUTPUT_DATA};
assign MID = DATA;

endmodule
