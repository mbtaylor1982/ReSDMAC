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
  `include "RTL/datapath/datapath_24dec.v"
`endif

module datapath_scsi (
    inout [7:0] SCSI_DATA,
    inout [31:0] ID,

    input [31:0] OD,
    input CPU2S,
    input S2CPU,
    input S2F,
    input F2S,
    input A3,
    input BO0,
    input BO1,
    input LS2CPU,

    output [31:0] MOD
);

wire F2S_UUD;
wire F2S_UMD;
wire F2S_LMD;
wire F2S_LLD;

datapath_24dec u_datapath_24dec(
    .A  (BO0     ),
    .B  (BO1     ),
    .G  (~F2S    ),
    .Z0 (F2S_UUD ),
    .Z1 (F2S_UMD ),
    .Z2 (F2S_LMD ),
    .Z3 (F2S_LLD )
);

wire SCSI_OUT;
wire SCSI_IN;

wire [7:0] SCSI_DATA_RX;
wire [7:0] SCSI_DATA_TX;

reg [7:0] SCSI_DATA_LATCHED;
    
always @(posedge LS2CPU) begin
    SCSI_DATA_LATCHED <= SCSI_DATA_RX;
end

assign SCSI_OUT = (F2S | CPU2S);
assign SCSI_IN  = (S2F | S2CPU);

assign SCSI_DATA_RX = SCSI_IN ? SCSI_DATA : 8'hzz;
assign SCSI_DATA = SCSI_OUT ? SCSI_DATA_TX : 8'hzz;

assign SCSI_DATA_TX = F2S_LLD ? OD[7:0] : 8'hzz;
assign SCSI_DATA_TX = F2S_LMD ? OD[15:8] : 8'hzz;
assign SCSI_DATA_TX = F2S_UMD ? OD[23:16] : 8'hzz;
assign SCSI_DATA_TX = F2S_UUD ? OD[31:24] : 8'hzz;

assign SCSI_DATA_TX = (CPU2S & A3) ? ID[23:16] : 8'hzz;
assign SCSI_DATA_TX = (CPU2S & ~A3) ? ID[7:0] : 8'hzz;

assign MOD = S2CPU ? {SCSI_DATA_LATCHED, 8'hzz , SCSI_DATA_LATCHED, 8'hzz}: 32'hzzzzzzzz;
assign ID = S2F ? {SCSI_DATA_RX, SCSI_DATA_RX, SCSI_DATA_RX, SCSI_DATA_RX}: 32'hzzzzzzzz;

endmodule