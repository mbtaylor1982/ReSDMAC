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
    inout [31:0] DATA,  
    
    input [31:0] OD,
    input [31:0] MOD,
    input BRIDGEOUT,
    input DOEH_,
    input DOEL_,
    input F2CPUL,
    input F2CPUH,
    input S2CPU,
    input PAS     
);

wire LOD1_F2CPU;
wire LOD2_F2CPU;

wire [15:0] LOWER_INPUT_DATA;
wire [15:0] UPPER_INPUT_DATA;

wire [15:0] LOWER_OUTPUT_DATA;
wire [15:0] UPPER_OUTPUT_DATA;

reg [15:0] LD_LATCH;
reg [15:0] UD_LATCH;


always @(posedge LOD1_F2CPU) begin
    LD_LATCH <= LOWER_INPUT_DATA;
end

always @(posedge LOD2_F2CPU) begin
    UD_LATCH <= UPPER_INPUT_DATA;
end

assign LOD1_F2CPU = PAS;
assign LOD2_F2CPU = PAS;

assign LOWER_INPUT_DATA = OD[15:0];
assign UPPER_INPUT_DATA = OD[31:16];

assign LOWER_OUTPUT_DATA = F2CPUL ? LD_LATCH : MOD[15:0];
assign UPPER_OUTPUT_DATA = F2CPUH ? (BRIDGEOUT ? 16'hzzzz : UD_LATCH) : (BRIDGEOUT ? LD_LATCH : MOD[31:16]); 

assign DATA[15:0] = DOEL_ ? 16'hzzzz : LOWER_OUTPUT_DATA;
assign DATA[31:16] = DOEH_ ? 16'hzzzz : UPPER_OUTPUT_DATA;
assign DATA = S2CPU ? MOD : 32'hzzzzzzzz;


endmodule