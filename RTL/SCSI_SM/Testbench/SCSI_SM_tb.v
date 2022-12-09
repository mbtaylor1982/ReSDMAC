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

`timescale 1ns/100ps

`ifdef __ICARUS__ 
    `include "RTL/SCSI_SM/SCSI_SM.v"
`endif 


module scsi_sm_tb; 
//inputs
reg nAS_;
reg CPUREQ;
reg RW;
reg DMADIR;
reg INCFIFO;
reg DECFIFO;
reg RESET_;
reg BOEQ3;
reg CPUCLK;
reg DREQ_;
reg FIFOFULL;
reg FIFOEMPTY;

//Outputs
wire LS2CPU;
wire RDFIFO_o;
wire RIFIFO_o;
wire RE_o;
wire WE_o;
wire SCSI_CS_o;
wire DACK_o;
wire INCBO_o;
wire INCNO_o;
wire INCNI_o;
wire S2F_o;
wire F2S_o;
wire S2CPU_o;
wire CPU2S_o;


SCSI_SM 
#(
    .SCSIAUTO         (1)
)u_SCSI_SM(
    .nAS_      (nAS_      ),
    .CPUREQ    (CPUREQ    ),
    .RW        (RW        ),
    .DMADIR    (DMADIR    ),
    .INCFIFO   (INCFIFO   ),
    .DECFIFO   (DECFIFO   ),
    .RESET_    (RESET_    ),
    .BOEQ3     (BOEQ3     ),
    .CPUCLK    (CPUCLK    ),
    .DREQ_     (DREQ_     ),
    .FIFOFULL  (FIFOFULL  ),
    .FIFOEMPTY (FIFOEMPTY ),
    .LS2CPU    (LS2CPU    ),
    .RDFIFO_o  (RDFIFO_o  ),
    .RIFIFO_o  (RIFIFO_o  ),
    .RE_o      (RE_o      ),
    .WE_o      (WE_o      ),
    .SCSI_CS_o (SCSI_CS_o ),
    .DACK_o    (DACK_o    ),
    .INCBO_o   (INCBO_o   ),
    .INCNO_o   (INCNO_o   ),
    .INCNI_o   (INCNI_o   ),
    .S2F_o     (S2F_o     ),
    .F2S_o     (F2S_o     ),
    .S2CPU_o   (S2CPU_o   ),
    .CPU2S_o   (CPU2S_o   )
);

    initial begin
        $display("*Testing SDMAC SCSI_SM.v Module*");
        $dumpfile("../SCSI_SM/VCD/SCSI_SM_tb.vcd");
        $dumpvars(0, scsi_sm_tb);
        
        //test FIFO Full Empty Counter
        $display("Testing SCSI State Machine RESET");
        //set initial state
        CPUCLK = 1'b1;
        CPUREQ = 1'b0;
        RESET_ = 1'b1;
        nAS_ = 1'b0;
        RW = 1'b1;
        DMADIR = 1'b0;
        INCFIFO = 1'b0;
        DECFIFO = 1'b0;
        BOEQ3 = 1'b0;
        DREQ_ = 1'b1;
        FIFOFULL = 1'b0;
        FIFOEMPTY = 1'b1;
        repeat(2) #20 CPUCLK = ~CPUCLK;
        RESET_ = 1'b0;
        repeat(4) #20 CPUCLK = ~CPUCLK;
        RESET_ = 1'b1;
        repeat(2) #20 CPUCLK = ~CPUCLK;
        CPUREQ = 1'b1;
        repeat(4) #20 CPUCLK = ~CPUCLK;
        nAS_ = 1'b1;
        repeat(32) #20 CPUCLK = ~CPUCLK;
        CPUREQ = 1'b0;
        nAS_ = 1'b0;
        repeat(16) #20 CPUCLK = ~CPUCLK;


        CPUCLK = 1'b1;
        CPUREQ = 1'b0;
        RESET_ = 1'b1;
        nAS_ = 1'b0;
        RW = 1'b0;
        DMADIR = 1'b0;
        INCFIFO = 1'b0;
        DECFIFO = 1'b0;
        BOEQ3 = 1'b0;
        DREQ_ = 1'b1;
        FIFOFULL = 1'b0;
        FIFOEMPTY = 1'b1;
        repeat(2) #20 CPUCLK = ~CPUCLK;
        RESET_ = 1'b0;
        repeat(4) #20 CPUCLK = ~CPUCLK;
        RESET_ = 1'b1;
        repeat(2) #20 CPUCLK = ~CPUCLK;
        CPUREQ = 1'b1;
        repeat(4) #20 CPUCLK = ~CPUCLK;
        nAS_ = 1'b1;
        repeat(32) #20 CPUCLK = ~CPUCLK;
        CPUREQ = 1'b0;
        nAS_ = 1'b0;
        repeat(16) #20 CPUCLK = ~CPUCLK;
        $finish;
    end 

endmodule