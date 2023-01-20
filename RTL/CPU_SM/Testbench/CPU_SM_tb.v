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
    `include "RTL/CPU_SM/CPU_SM.v"
`endif 

//==============================================================================
module CPU_SM_tb;
//------------------------------------------------------------------------------
//  UUT
//------------------------------------------------------------------------------
    // ports
    wire    PAS        ;  // 
    wire    PDS        ;  // 
    wire    BGACK      ;  // 
    wire    BREQ       ;  // 
    reg     aBGRANT_   ;  // 
    wire    SIZE1      ;  // 
    reg     aRESET_    ;  // 
    reg     STERM_     ;  // 
    reg     DSACK0_    ;  // 
    reg     DSACK1_    ;  // 
    reg     CLK        ;  // 
    reg     DMADIR     ;  // 
    reg     A1         ;  // 
    wire    F2CPUL     ;  // 
    wire    F2CPUH     ;  // 
    wire    BRIDGEIN   ;  // 
    wire    BRIDGEOUT  ;  // 
    wire    DIEH       ;  // 
    wire    DIEL       ;  // 
    reg     BOEQ3      ;  // 
    reg     BOEQ0      ;  // 
    reg     FIFOFULL   ;  // 
    reg     FIFOEMPTY  ;  // 
    reg     RDFIFO_    ;  // 
    wire    DECFIFO    ;  // 
    reg     RIFIFO_    ;  // 
    wire    INCFIFO    ;  // 
    wire    INCNO      ;  // 
    wire    INCNI      ;  // 
    reg     aDREQ_     ;  // 
    reg     aFLUSHFIFO ;  // 
    wire    STOPFLUSH  ;  // 
    reg     aDMAENA    ;  // 
    wire    PLLW       ;  // 
    wire    PLHW       ;  // 
    reg     AS_        ;  //
    reg     BGACK_I_   ;  // 
    // module
    CPU_SM uut (
        .PAS            (PAS            ),
        .PDS            (PDS            ),
        .BGACK          (BGACK          ),
        .BREQ           (BREQ           ),
        .aBGRANT_       (aBGRANT_       ),
        .SIZE1          (SIZE1          ),
        .aRESET_        (aRESET_        ),
        .STERM_         (STERM_         ),
        .DSACK0_        (DSACK0_        ),
        .DSACK1_        (DSACK1_        ),
        .CLK            (CLK            ),
        .DMADIR         (DMADIR         ),
        .A1             (A1             ),
        .F2CPUL         (F2CPUL         ),
        .F2CPUH         (F2CPUH         ),
        .BRIDGEIN       (BRIDGEIN       ),
        .BRIDGEOUT      (BRIDGEOUT      ),
        .DIEH           (DIEH           ),
        .DIEL           (DIEL           ),
        .BOEQ0          (BOEQ0          ),
        .BOEQ3          (BOEQ3          ),
        .FIFOFULL       (FIFOFULL       ),
        .FIFOEMPTY      (FIFOEMPTY      ),
        .RDFIFO_        (RDFIFO_        ),
        .DECFIFO        (DECFIFO        ),
        .RIFIFO_        (RIFIFO_        ),
        .INCFIFO        (INCFIFO        ),
        .INCNO          (INCNO          ),
        .INCNI          (INCNI          ),
        .aDREQ_         (aDREQ_         ),
        .aFLUSHFIFO     (aFLUSHFIFO     ),
        .STOPFLUSH      (STOPFLUSH      ),
        .aDMAENA        (aDMAENA        ),
        .PLLW           (PLLW           ),
        .PLHW           (PLHW           ),
        .AS_            (AS_            ),
        .BGACK_I_       (BGACK_I_       )
    );
//------------------------------------------------------------------------------
//  localparam
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
//  clk
//------------------------------------------------------------------------------
    localparam CLK_FREQ = 25_000_000;
    localparam PERIOD = 1E9/CLK_FREQ;
    initial begin
        $display("*Testing SDMAC CPU_SM.v Module*");
        $dumpfile("../CPU_SM/VCD/CPU_SM_tb.vcd");
        $dumpvars(0, CPU_SM_tb);
        CLK = 0;
        forever #(PERIOD/2) CLK = ~ CLK;
    end
//------------------------------------------------------------------------------
//  general tasks and functions
//------------------------------------------------------------------------------
    // -------- wait n periods of clock --------
    task wait_n_clk(input integer i);
        begin
            repeat(i) @(posedge CLK);
        end
    endtask
    // -------- wait n periods of clock (with Tcko) --------
    task wait_n_clko(input integer i);
        begin
            repeat(i) @(posedge CLK);
            #1;
        end
    endtask
//------------------------------------------------------------------------------
//  initial values
//------------------------------------------------------------------------------
    initial begin
        aRESET_ = 0;
        // -------- input --------
        A1 = 1'b1;
        aBGRANT_ = 1'b1;
        
        AS_ = 1'b0;
        aDMAENA = 1'b0;
        aDREQ_ = 1'b1;
        aFLUSHFIFO = 1'b0;
        BOEQ0 = 1'b0;
        BOEQ3 = 1'b1;
        DMADIR = 1'b1;

        DSACK0_ = 1'b1;
        DSACK1_ = 1'b1;
        FIFOEMPTY = 1'b0;
        FIFOFULL = 1'b1;

        RDFIFO_ = 1'b1;
        RIFIFO_ = 1'b1;
        STERM_ = 1'b1;
    end
//------------------------------------------------------------------------------
//  simulation tasks
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
//  run simulation
//------------------------------------------------------------------------------
    initial begin
        // -------- RESET --------
        wait_n_clk(1);
        aRESET_ = 1;
        wait_n_clko(1);
        aDMAENA = 1;
        wait_n_clko(2);
        AS_ = 1'b1; 
        wait_n_clko(2);
        aBGRANT_ = 1'b0;
        wait_n_clko(1);
        wait_n_clko(50);
        

        $finish;
    end
    
  always @(BGACK) begin
    BGACK_I_ <= ~BGACK;  
    if (BGACK == 1'b0 ) aBGRANT_ <= 1'b1;
  end

//------------------------------------------------------------------------------
endmodule