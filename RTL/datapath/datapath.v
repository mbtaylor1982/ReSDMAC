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
    `include "RTL/datapath/datapath_scsi.v"
    `include "RTL/datapath/datapath_input.v"
    `include "RTL/datapath/datapath_output .v"
`endif

module datapath (
    inout [31:0] DATA_IO, 
    inout [7:0] PD,

    input [31:0] OD,    
    inout [31:0] MOD,

    input PAS,
    input nDS_,
    input nDMAC_,
    input RW,
    input nOWN_,
    input DMADIR,
    
    input BRIDGEIN,
    input BRIDGEOUT,
    
    input DIEH,    
    input DIEL,

    
    input LS2CPU,
    input S2CPU,
    
    input S2F,

    input F2S,
    input CPU2S,

    input BO0,
    input BO1,
    input A3,
  

    output [31:0] MID,
    output [31:0] ID
);

wire LOD1_F2CPU;
wire LOD2_F2CPU;
wire DOEL_;
wire DOEH_;
wire bBRIDGEIN;
wire bDIEH;
wire bDIEL;

datapath_input u_datapath_input(
    .DATA      (DATA_IO   ),
    .bBRIDGEIN (bBRIDGEIN ),
    .bDIEH     (bDIEH     ),
    .bDIEL     (bDIEL     ),
    .BnDS_O_   (BnDS_O_   ),
    .MID       (MID       ),
    .ID        (ID        )
);

datapath_output u_datapath_output(
    .OD         (OD         ),
    .BRIDGEOUT  (BRIDGEOUT  ),
    .DOEH_      (DOEH_      ),
    .DOEL_      (DOEL_      ),
    .F2CPUL     (F2CPUL     ),
    .F2CPUH     (F2CPUH     ),
    .LOD1_F2CPU (LOD1_F2CPU ),
    .LOD2_F2CPU (LOD2_F2CPU ),
    .S2CPU      (S2CPU      ),
    .DATA       (DATA_IO    ),
    .MOD        (MOD        )
);

datapath_scsi u_datapath_scsi(
    .SCSI_DATA (SCSI_DATA ),
    .ID        (ID        ),
    .OD        (OD        ),
    .CPU2S     (CPU2S     ),
    .S2CPU     (S2CPU     ),
    .S2F       (S2F       ),
    .F2S       (F2S       ),
    .A3        (A3        ),
    .BO0       (BO0       ),
    .BO1       (BO1       ),
    .LS2CPU    (LS2CPU    ),
    .MOD       (MOD       )
);

assign LOD1_F2CPU = PAS;
assign LOD2_F2CPU = PAS;

assign DOEL_ = ~((nDS_ & nDMAC_ & RW) | (nOWN_ & DMADIR));
assign DOEH_ = DOEL_;

assign bBRIDGEIN = BRIDGEIN;
assign bDIEL = ~(DIEL|CPU2S);

endmodule