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
    `include "datapath_scsi.v"
    `include "datapath_input.v"
    `include "datapath_output.v"
`endif

module datapath (
    input CLK, CLK90, CLK135,
    input [31:0] DATA_I,
    
    input [15:0] PD_IN,
    output [15:0] PD_OUT,


    input [31:0] FIFO_OD,    
    input [31:0] REG_OD,

    input PAS,
    input DS_I_,
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

    input F2CPUL,
    input F2CPUH,

    input DS_O_,
  
    output [31:0] MID,
    output [31:0] FIFO_ID,
    output [31:0] DATA_O,
    output DATA_OE_,
    output PD_OE
);
wire [31:0] MOD_SCSI;
wire [31:0] MOD_TX;
wire [31:0] CPU_OD;
wire [31:0] SCSI_OD;


wire DOEL_;
wire DOEH_;
wire bBRIDGEIN;
wire bDIEH;
wire bDIEL;

datapath_input u_datapath_input(
    .CLK       (CLK90     ),
    .DATA      (DATA_I    ),
    .bBRIDGEIN (bBRIDGEIN ),
    .bDIEH     (bDIEH     ),
    .bDIEL     (bDIEL     ),
    .DS_O_     (DS_O_     ),
    .MID       (MID       ),
    .CPU_OD    (CPU_OD    )
);

datapath_output u_datapath_output(
    .CLK        (CLK135     ),
    .DATA       (DATA_O     ),
    .OD         (FIFO_OD    ),
    .MOD        (MOD_TX     ),
    .BRIDGEOUT  (BRIDGEOUT  ),
    .DOEH_      (DOEH_      ),
    .DOEL_      (DOEL_      ),
    .F2CPUL     (F2CPUL     ),
    .F2CPUH     (F2CPUH     ),
    .S2CPU      (S2CPU      ),
    .PAS        (PAS        )    
);

datapath_scsi u_datapath_scsi(
    .CLK            (CLK       ), 
    .SCSI_DATA_IN   (PD_IN     ),
    .SCSI_DATA_OUT  (PD_OUT    ),
    .SCSI_OD        (SCSI_OD   ),
    .FIFO_OD        (FIFO_OD   ),
    .CPU_OD         (CPU_OD    ),
    .CPU2S          (CPU2S     ),
    .S2CPU          (S2CPU     ),
    .S2F            (S2F       ),
    .F2S            (F2S       ),
    .A3             (A3        ),
    .BO0            (BO0       ),
    .BO1            (BO1       ),
    .LS2CPU         (LS2CPU    ),
    .MOD_SCSI       (MOD_SCSI  ),
    .SCSI_OUT       (PD_OE     )
);

assign DOEL_ = ~((~DS_I_ & nDMAC_ & RW) | (nOWN_ & DMADIR));
assign DOEH_ = DOEL_;
assign DATA_OE_ = ~DOEH_;

assign bBRIDGEIN = BRIDGEIN;
assign bDIEH = (DIEH|CPU2S);

assign bDIEL = (DIEL|CPU2S);


assign MOD_TX = S2CPU ? MOD_SCSI : REG_OD;
assign FIFO_ID = S2F ? SCSI_OD: CPU_OD;

endmodule