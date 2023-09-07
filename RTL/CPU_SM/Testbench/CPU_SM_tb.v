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

/******************************************************************************/
// `include "gParam.v"
//------------------------------------------------------------------------------
`timescale 1 ns/100 ps
`include "RTL/PLL.v"
`include "RTL/CPU_SM/CPU_SM.v"
//==============================================================================
module CPU_SM_tb;
//==============================================================================
//  simulation parameters
//------------------------------------------------------------------------------
    localparam CLK_FREQ = 25_000_000;
    localparam [0:0] RESET_LEVEL = 0;
//==============================================================================
//  global clock and reset
//------------------------------------------------------------------------------
    reg tb_clk = 0;
    reg tb_rst = RESET_LEVEL;
    // -------- clock --------
    localparam PERIOD = 1E9/CLK_FREQ;
    initial begin
        tb_clk = 0;
        forever #(PERIOD/2) tb_clk = ~ tb_clk;
    end
    // -------- reset --------
    task sim_reset(input integer n);
        begin
            //$display("sim_reset");
            tb_rst = ~RESET_LEVEL;
            repeat(n) @(posedge tb_clk);
            #1;
            tb_rst = ~tb_rst;
            repeat(n) @(posedge tb_clk);
            #1;
            tb_rst = ~tb_rst;
        end
    endtask

//==============================================================================
//  UUT
//------------------------------------------------------------------------------
    // * connect your clock/reset with the signal "tb_clk"/"tb_rst"
    // ports
    reg     A1        ;  // 
    reg     aBGRANT_  ;  // 
    reg     aDMAENA   ;  // 
    reg     aDREQ_    ;  // 
    reg     aFLUSHFIFO;  // 
    reg     aRESET_   ;  // 
    reg     BOEQ0     ;  // 
    reg     BOEQ3     ;  // 
    reg     DMADIR    ;  // 
    reg     DSACK0_   ;  // 
    reg     DSACK1_   ;  // 
    reg     FIFOEMPTY ;  // 
    reg     FIFOFULL  ;  // 
    reg     RDFIFO_   ;  // 
    reg     RIFIFO_   ;  // 
    reg     iSTERM_   ;  // 
    reg     AS_       ;  // 
    reg     BGACK_I_  ;  // 

    wire    BGACK     ;  // 
    wire    BREQ      ;  // 
    wire    BRIDGEIN  ;  // 
    wire    BRIDGEOUT ;  // 
    wire    DECFIFO   ;  // 
    wire    DIEH      ;  // 
    wire    DIEL      ;  // 
    wire    F2CPUH    ;  // 
    wire    F2CPUL    ;  // 
    wire    INCFIFO   ;  // 
    wire    INCNI     ;  // 
    wire    INCNO     ;  // 
    wire    PAS       ;  // 
    wire    PDS       ;  // 
    wire    PLHW      ;  // 
    wire    PLLW      ;  // 
    wire    SIZE1     ;  // 
    wire    STOPFLUSH ;  // 
    wire    LOCKED    ;  //
    wire    CLK45     ;  // CPUCLK pahse shifted 45 deg
    wire    CLK90     ;  // CPUCLK pahse shifted 90 deg.
    wire    CLK135    ;  // CPUCLK pahse shifted 135 deg.     
    
    // module
    PLL u_PLL (
        .RST    (~tb_rst ),  // input, (wire), 
        .CLK    (tb_clk ),  // input, (wire), 
        .CLK45  (CLK45  ),  // output, (wire), 
        .CLK90  (CLK90  ),  // output, (wire), 
        .CLK135 (CLK135 ),  // output, (wire), 
        .LOCKED (LOCKED )   // output, (wire), 
    );
    CPU_SM uut (
        .A1         (A1         ),
        .aBGRANT_   (aBGRANT_   ),
        .aDMAENA    (aDMAENA    ),
        .aDREQ_     (aDREQ_     ),
        .aFLUSHFIFO (aFLUSHFIFO ),
        .aRESET_    (LOCKED     ),
        .BOEQ0      (BOEQ0      ),
        .BOEQ3      (BOEQ3      ),
        .CLK45      (CLK45      ),
        .CLK90      (CLK90      ),
        .CLK135     (CLK135     ),
        .DMADIR     (DMADIR     ),
        .DSACK0_    (DSACK0_    ),
        .DSACK1_    (DSACK1_    ),
        .FIFOEMPTY  (FIFOEMPTY  ),
        .FIFOFULL   (FIFOFULL   ),
        .RDFIFO_    (RDFIFO_    ),
        .RIFIFO_    (RIFIFO_    ),
        .iSTERM_    (iSTERM_    ),
        .AS_        (AS_        ),
        .BGACK_I_   (BGACK_I_   ),
        .BGACK      (BGACK      ),
        .BREQ       (BREQ       ),
        .BRIDGEIN   (BRIDGEIN   ),
        .BRIDGEOUT  (BRIDGEOUT  ),
        .DECFIFO    (DECFIFO    ),
        .DIEH       (DIEH       ),
        .DIEL       (DIEL       ),
        .F2CPUH     (F2CPUH     ),
        .F2CPUL     (F2CPUL     ),
        .INCFIFO    (INCFIFO    ),
        .INCNI      (INCNI      ),
        .INCNO      (INCNO      ),
        .PAS        (PAS        ),
        .PDS        (PDS        ),
        .PLHW       (PLHW       ),
        .PLLW       (PLLW       ),
        .SIZE1      (SIZE1      ),
        .STOPFLUSH  (STOPFLUSH  )
    );

//==============================================================================
//  UUT - initial values
//------------------------------------------------------------------------------
    // * connect your clock/reset with the signal "tb_clk"/"tb_rst"
    initial begin
        A1          <= 1'b0;  // 
        aBGRANT_    <= 1'b1;  // 
        aDMAENA     <= 1'b1;  // 
        aDREQ_      <= 1'b0;  // 
        aFLUSHFIFO  <= 1'b1;  // 
        aRESET_     <= 1'b0;  // 
        BOEQ0       <= 1'b1;  // 
        BOEQ3       <= 1'b0;  // 
        DMADIR      <= 1'b0;  // 
        DSACK0_     <= 1'b1;  // 
        DSACK1_     <= 1'b1;  // 
        FIFOEMPTY   <= 1'b1;  // 
        FIFOFULL    <= 1'b0;  // 
        RDFIFO_     <= 1'b1;; // 
        RIFIFO_     <= 1'b1;  // 
        iSTERM_     <= 1'b1;  // 
        AS_         <= 1'b1;  // 
        BGACK_I_    <= 1'b1;  //
    end
 
//==============================================================================
//  simulation models
//------------------------------------------------------------------------------

//==============================================================================
//  general simulation tasks or functions
//------------------------------------------------------------------------------
    // -------- wait n clock cycles --------
    task wait_ncc(input integer n);
        begin
            repeat(n) @(posedge tb_clk);
        end
    endtask
    // -------- wait n clock cycles (with Tcko) --------
    task wait_ncco(input integer n);
        begin
            repeat(n) @(posedge tb_clk);
            #1;
        end
    endtask
    // -------- show messages for simulation (100 charactors MAX) --------
    reg [1:100*8] sim_msg;
    task show_sim_message(input [1:100*8] msg);
        begin: break
            sim_msg = msg;
            while (1) begin
                if(sim_msg[1:8] == 0)
                    sim_msg = sim_msg<<8;
                else
                    disable break;
            end
        end
    endtask
//==============================================================================
//  simulation tasks
//------------------------------------------------------------------------------

//==============================================================================
//  run simulation
//------------------------------------------------------------------------------
    initial begin
        $display("*Testing SDMAC CPU_SM.v Module*");
        $dumpfile("../CPU_SM/VCD/CPU_SM_tb.vcd");
        $dumpvars(0, CPU_SM_tb);

        $display("  Time, STATE, NEXT_STATE, aDMAENA, DMADIR, FIFOEMPTY, FIFOFULL, aFLUSHFIFO, BOEQ0");
        $monitor("%6d, %5d, %10d, %7b, %6b, %9b, %8b, %10b, %5b", $time, uut.STATE, uut.NEXT_STATE, aDMAENA, DMADIR, FIFOEMPTY, FIFOFULL, aFLUSHFIFO, BOEQ0); 
    
    
        // -------- RESET --------
        //show_sim_message("reset");
        
        sim_reset(2);    
        // --------  --------
        wait_ncco(4);

        aDMAENA <= 1'b1; 
        DMADIR <= 1'b0; 
        FIFOEMPTY <= 1'b1;
        FIFOFULL <= 1'b0; 
        aFLUSHFIFO <= 1'b1;
        BOEQ0 <= 1'b1;
        
        wait_ncco(4);
        wait_ncco(32);

        // -------- END --------
        //show_sim_message("END");    
        $finish;
    end
//------------------------------------------------------------------------------
endmodule