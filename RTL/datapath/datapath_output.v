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
module datapath_output (
    input [31:0] OD,
    input BRIDGEOUT,
    input DOEH_,
    input DOEL_,
    input F2CPUL,
    input F2CPUH,
    input LOD1_F2CPU,
    input LOD2_F2CPU,  
    input S2CPU,
    
    inout [31:0] DATA,
    inout [31:0] MOD
);

wire [15:0] LOWER_INPUT_DATA;
wire [15:0] UPPDER_INPUT_DATA;

wire [15:0] LOWER_OUTPUT_DATA;
wire [15:0] UPPDER_OUTPUT_DATA;

reg [15:0] LD_LATCH;
reg [15:0] UD_LATCH;


always @(posedge LOD1_F2CPU) begin
    if (LOD1_F2CPU == 1'b1)
        LD_LATCH <= LOWER_INPUT_DATA;
end

always @(posedge LOD2_F2CPU) begin
    if (LOD2_F2CPU == 1'b1)
        UD_LATCH <= UPPDER_INPUT_DATA;
end

assign LOWER_INPUT_DATA = OD[15:0];
assign UPPDER_INPUT_DATA = OD[31:16];

assign LOWER_OUTPUT_DATA = F2CPUL ? LD_LATCH : 16'hzzzz;
assign UPPER_OUTPUT_DATA = F2CPUH ? UD_LATCH : 16'hzzzz;
assign UPPER_OUTPUT_DATA = BRIDGEOUT ? LD_LATCH : 16'hzzzz;

assign MOD = {UPPER_OUTPUT_DATA, LOWER_OUTPUT_DATA};

assign DATA[15:0] = DOEL_ ? 16'hzzzz : LOWER_OUTPUT_DATA;
assign DATA[31:16] = DOEH_ ? 16'hzzzz : UPPER_OUTPUT_DATA;
assign DATA = S2CPU ? MOD : 16'hzzzz;


endmodule