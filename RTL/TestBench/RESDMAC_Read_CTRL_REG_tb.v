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

`include "RTL/RESDMAC.v"

module RESDMAC_tb;
//------------------------------------------------------------------------------
//  UUT
//------------------------------------------------------------------------------
    // ports
    reg R_W_i;
    wire R_W_o;
    assign R_W_o = R_W_IO;
    assign R_W_IO = OWN_ ? R_W_i : 1'bz;

    reg _AS_i;
    wire _AS_o;
    assign _AS_o = _AS_IO;
    assign _AS_IO = OWN_ ? _AS_i : 1'bz;

    reg _DS_i;
    wire _DS_o;
    assign _DS_o = _DS_IO;
    assign _DS_IO = OWN_ ? _DS_i : 1'bz;

    reg [31:0] DATA_i ;
    wire [31:0] DATA_o;
    assign DATA_o = DATA_IO;
    assign DATA_IO = OWN_ ? DATA_i : 32'bz;

    
    tri1        _INT     ;  // Connected to INT2 needs to be Open Collector output.
    wire        SIZ1     ;  // Indicates a 16 bit transfer is true. 
    tri1        R_W_IO   ;  // Read Write from CPU
    tri1        _AS_IO   ;  // Address Strobe
    tri1        _DS_IO   ;  // Data Strobe 
    tri1 [1:0] _DSACK_IO ;  // Dynamic size and DATA ack.
    tri1 [31:0] DATA_IO  ;  // CPU side data bus 32bit wide
    reg         _STERM   ;  // static/synchronous data ack.
    reg         SCLK     ;  // CPUCLKB
    reg         _CS      ;  // _SCSI from Fat Garry
    reg         _RST     ;  // System Reset
    reg         _BERR    ;  // Bus Error 
    reg  [31:0] ADDR     ;  // CPU address Bus, bits are actually [6:2]
    tri1        _BR      ;  // Bus Request
    reg         _BG      ;  // Bus Grant
    tri1        BGACK_IO_; // Bus Grant Acknoledge
    wire        _DMAEN   ;  // Low =  Enable Address Generator in Ramsey
    reg         _DREQ    ;  // 
    wire        _DACK    ;  // 
    reg         INTA     ;  // Interupt from WD33c93A (SCSI)
    wire        _IOR     ;  // Active Low read strobe
    wire        _IOW     ;  // Ative Low Write strobe
    wire        _CSS     ;  // Port 0 CS      
    tri1  [7:0] PD_PORT  ;  // 
    wire        _LED_RD  ;  // Indicated read from SDMAC or peripherial port.
    wire        _LED_WR  ;  // Indicate write to SDMAC or peripherial port.
    wire        _LED_DMA ;  // Indicate DMA cycle/busmaster.
    wire        OWN_     ;  // Active low signal to show SDMAC is bus master, This can be used to set direction on level shifters for control signals.
    wire        DATA_OE_ ;  // Active low ouput enable for DBUS level shifters.
    wire        PDATA_OE_;  // Active low ouput enable for Peripheral BUS level shifters.
    // module
    RESDMAC uut (
        ._INT       (_INT       ),
        .SIZ1       (SIZ1       ),
        .R_W_IO     (R_W_IO     ),
        ._AS_IO     (_AS_IO     ),
        ._DS_IO     (_DS_IO     ),
        ._DSACK_IO  (_DSACK_IO  ),
        .DATA_IO    (DATA_IO    ),
        ._STERM     (_STERM     ),
        .SCLK       (SCLK       ),
        ._CS        (_CS        ),
        ._RST       (_RST       ),
        ._BERR      (_BERR      ),
        .ADDR       (ADDR[6:2]  ),
        ._BR        (_BR        ),
        ._BG        (_BG        ),
        .BGACK_IO_   (BGACK_IO_ ),
        ._DMAEN     (_DMAEN     ),
        ._DREQ      (_DREQ      ),
        ._DACK      (_DACK      ),
        .INTA       (INTA       ),
        ._IOR       (_IOR       ),
        ._IOW       (_IOW       ),
        ._CSS       (_CSS       ),
        .PD_PORT    (PD_PORT    ),
        ._LED_RD    (_LED_RD    ),
        ._LED_WR    (_LED_WR    ),
        ._LED_DMA   (_LED_DMA   ),
        .OWN_       (OWN_       ),
        .DATA_OE_   (DATA_OE_   ),
        .PDATA_OE_  (PDATA_OE_  )
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
        SCLK = 0;
        forever #(PERIOD/2) SCLK = ~ SCLK;
    end
//------------------------------------------------------------------------------
//  general tasks and functions
//------------------------------------------------------------------------------
    // -------- wait n periods of clock --------
    task wait_n_clk(input integer i);
        begin
            repeat(i) @(posedge SCLK);
        end
    endtask
    // -------- wait n periods of clock (with Tcko) --------
    task wait_n_clko(input integer i);
        begin
            repeat(i) @(posedge SCLK);
            #1;
        end
    endtask
//------------------------------------------------------------------------------
//  initial values
//------------------------------------------------------------------------------
    initial begin
        _RST = 1;
        // -------- input --------
        R_W_i = 1;
        _AS_i = 1'b1;
        _DS_i = 1;
        //_CS = 1;
        _BG = 1;
        _DREQ = 1;
        INTA = 0;
        _BERR = 1;
        _STERM = 1;
        R_W_i = 1;
        _AS_i = 1'b1;
        _DS_i = 1;
        ADDR <= 32'hffffffff;
        DATA_i <= 32'hzzzzzzzz;
        

    end
//------------------------------------------------------------------------------
//  simulation tasks
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
//  run simulation
//------------------------------------------------------------------------------
    initial begin
        $display("*Testing RESDMAC TOP Module Read From CTRL Register*");
        $dumpfile("../VCD/RESDMAC_Read_CTRL_REG_tb.vcd");
        $dumpvars(0, RESDMAC_tb);
        // -------- RESET --------
        wait_n_clk(1);
        _RST = 0;
        wait_n_clko(1);
        _RST = 1;
        wait_n_clko(3);
        ADDR <= 32'h00DD0008;
        DATA_i <= 32'hAAAAAAAA; 
        wait_n_clko(1);
        _AS_i = 1'b0;
        R_W_i = 1'b0;
        wait_n_clko(1);
        _DS_i = 1'b0;
        wait_n_clko(5);        
        R_W_i = 1;
        wait_n_clko(2);
        ADDR <= 32'hffffffff;
        DATA_i <= 32'hzzzzzzzz;

        wait_n_clko(2);
        ADDR <= 32'h00DD0008;
        wait_n_clko(1);
        _AS_i = 1'b0;
        R_W_i = 1'b1;
        wait_n_clko(1);
        _DS_i = 1'b0;
        wait_n_clko(5);        
        R_W_i = 1;
        wait_n_clko(2);
        ADDR <= 32'hffffffff;
        DATA_i <= 32'hzzzzzzzz;
        wait_n_clko(2);
        $finish;
    end
    always @(negedge SCLK) begin
        if (~(_DSACK_IO[0] & _DSACK_IO[1])  == 1'b1) 
        begin
            _AS_i <= 1'b1;
            _DS_i <= 1'b1;    
        end
    end

    always @(ADDR) begin
        _CS <= ~(~ADDR[31] & ~ADDR[30] & ~ADDR[29] & ~ADDR[28]  & ~ADDR[27] & ~ADDR[26] & ~ADDR[25]  & ~ADDR[24] & ADDR[23]  
        & ADDR[22] & ~ADDR[21] & ADDR[20]  & ADDR[19] & ADDR[18] & ~ADDR[17]  & ADDR[16]);
    end

//------------------------------------------------------------------------------
endmodule