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
    `include "scsi_sm_inputs.v"
    `include "scsi_sm_outputs.v"
`endif

module SCSI_SM_INTERNALS1(   

    input CLK,              //CLK
    input nRESET,           //Active low reset
                  
    input BOEQ3,            //Asserted when transfering Byte 3                
    input CCPUREQ,          //Request CPU access to SCSI registers.
    input CDREQ_,           //Data transfer request from SCSI IC.
    input CDSACK_,          //DSACK 
    input DMADIR,           //Control Direction Of DMA transfer.
    input FIFOEMPTY,        //FIFOFULL flag
    input FIFOFULL,         //FIFOEMPTY flag
    input RDFIFO_o,         
    input RIFIFO_o,
    input RW,               //CPU RW signal

    output CPU2S,       //Indicate CPU to SCSI Transfer
    output DACK,        //SCSI IC Data request Acknowledge
    output F2S,         //Indicate FIFO to SCSI Transfer
    output INCBO,       //Increment FIFO Byte Pointer
    output INCNI,       //Increment FIFO Next In Pointer
    output INCNO,       //Increement FIFO Next Out Pointer
    output RDFIFO,      //Read Longword from FIFO
    output RE,          //Read indicator to SCSI IC
    output RIFIFO,      //Write Longword to FIFO
    output S2CPU,       //Indicate SCSI to CPU Transfer
    output S2F,         //Indicate SCSI to FIFO Transfer
    output SCSI_CS,     //Chip Select for SCSI IC
    output WE,          //Write indicator to SCSI IC
    output SET_DSACK
    
);

reg [4:0] STATE;

wire [27:0] E;
wire [4:0] NEXT_STATE;

scsi_sm_inputs u_scsi_sm_inputs(
    .BOEQ3      (BOEQ3      ),
    .CCPUREQ    (CCPUREQ    ),
    .CDREQ_     (CDREQ_     ),
    .CDSACK_    (CDSACK_    ),
    .DMADIR     (DMADIR     ),
    .E          (E          ),
    .FIFOEMPTY  (FIFOEMPTY  ),
    .FIFOFULL   (FIFOFULL   ),
    .RDFIFO_o   (RDFIFO_o   ),
    .RIFIFO_o   (RIFIFO_o   ),
    .RW         (RW         ),
    .STATE      (STATE      )
);

scsi_sm_outputs u_scsi_sm_outputs(
    .CPU2S      (CPU2S      ),
    .DACK       (DACK       ),
    .E          (E          ),
    .F2S        (F2S        ),
    .INCBO      (INCBO      ),
    .INCNI      (INCNI      ),
    .INCNO      (INCNO      ),
    .NEXT_STATE (NEXT_STATE ), 
    .RE         (RE         ),
    .S2CPU      (S2CPU      ),
    .S2F        (S2F        ),
    .SCSI_CS    (SCSI_CS    ),
    .SET_DSACK  (SET_DSACK  ),
    .WE         (WE         )
);

assign RDFIFO = E[3];
assign RIFIFO = E[4];

//State Machine
always @(posedge CLK or negedge nRESET) begin
    if (nRESET == 1'b0)
        STATE <= 5'b00000;
    else
        STATE <= NEXT_STATE;
end



endmodule 