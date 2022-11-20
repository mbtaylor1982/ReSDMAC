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

`include "RTL/FIFO/fifo.v"

module fifo_tb; 

//inputs
reg LLWORD;
reg LHWORD;
reg LBYTE_;
reg H_0C;
reg ACR_WR;
reg RST_FIFO_;
reg MID25; 
reg [31:0] ID;
reg INCFIFO;
reg DECFIFO; 
reg INCBO;
reg INCNO; 
reg INCNI; 

//Outputs
wire FIFOFULL;
wire FIFOEMPTY;
wire BOEQ0; 
wire BOEQ3; 
wire BO0; 
wire BO1;
wire [31:0] OD;

fifo dut_fifo(
    .LLWORD    (LLWORD    ),
    .LHWORD    (LHWORD    ),
    .LBYTE_    (LBYTE_    ),
    .H_0C      (H_0C      ),
    .ACR_WR    (ACR_WR    ),
    .RST_FIFO_ (RST_FIFO_ ),
    .MID25     (MID25     ),
    .ID        (ID        ),
    .FIFOFULL  (FIFOFULL  ),
    .FIFOEMPTY (FIFOEMPTY ),
    .INCFIFO   (INCFIFO   ),
    .DECFIFO   (DECFIFO   ),
    .INCBO     (INCBO     ),
    .BOEQ0     (BOEQ0     ),
    .BOEQ3     (BOEQ3     ),
    .BO0       (BO0       ),
    .BO1       (BO1       ),
    .INCNO     (INCNO     ),
    .INCNI     (INCNI     ),
    .OD        (OD        )
);

    initial begin
        $display("*Testing SDMAC FIFO.v Module*");
        $dumpfile("../FIFO/VCD/fifo_tb.vcd");
        $dumpvars(0, fifo_tb);
        
        //test FIFO Full Empty Counter
        $display("Testing FIFO Full/Empty Counter");
        RST_FIFO_ = 1'b0;
        INCFIFO = 1'b0;
        DECFIFO = 1'b0;
        repeat(1) #20
        RST_FIFO_ = 1'b1;
        if (!FIFOEMPTY) 
            $display("Test Failed: FIFO Not Empty after reset");
        else
            $display("Test Passed: FIFO Empty After reset");
        
        repeat(16) #20 INCFIFO = ~INCFIFO;
        if (!FIFOFULL) 
            $display("Test Failed: FIFO Not Full After 8 INCFIFO pulses");
        else
            $display("Test Passed: FIFO Full After 8 INCFIFO pulses");

        repeat(17) #20 DECFIFO = ~DECFIFO;
        if (!FIFOEMPTY) 
            $display("Test Failed: FIFO Not Empty After 8 DECFIFO pulses");
        else
            $display("Test Passed: FIFO Empty After 8 DECFIFO pulses");


        //test next In Counter
        RST_FIFO_ = 1'b0;
        INCNI = 1'b0;
        repeat(1) #20
        RST_FIFO_ = 1'b1;
        repeat(16) #20 INCNI = ~INCNI;
        
        
        //test nexr Out Counter
        RST_FIFO_ = 1'b0;
        INCNO = 1'b0;
        repeat(1) #20
        RST_FIFO_ = 1'b1;
        repeat(16) #20 INCNO = ~INCNO;


        ID = 32'h55555555;
        
        //Byte Counter Test 1
        RST_FIFO_ = 1'b0;
        INCBO = 1'b0;
        LBYTE_ = 1'b0;
        LHWORD = 1'b0;
        LLWORD = 1'b0;
        H_0C = 1'b0;
        ACR_WR = 1'b0;
        MID25 = 1'b0;
        repeat(1) #20
        RST_FIFO_ = 1'b1;
        repeat(9) #20 INCBO = ~INCBO;

        //Byte Counter Test 2
        RST_FIFO_ = 1'b0;
        INCBO = 1'b0;
        LBYTE_ =1'b0;
        LHWORD = 1'b0;
        LLWORD = 1'b0;
        H_0C = 1'b1;
        ACR_WR = 1'b0;
        MID25 = 1'b0;
        repeat(1) #20
        RST_FIFO_ = 1'b1;
        repeat(5) #20 INCBO = ~INCBO;

        //Byte Counter Test 3
        RST_FIFO_ = 1'b0;
        INCBO = 1'b0;
        LBYTE_ =1'b0;
        LHWORD = 1'b0;
        LLWORD = 1'b0;
        H_0C = 1'b1;
        ACR_WR = 1'b0;
        MID25 = 1'b1;
        repeat(1) #12
        RST_FIFO_ = 1'b1;
        repeat(5) #20 INCBO = ~INCBO;
        repeat(16) #20 INCNO = ~INCNO;


        $finish;
    end    
    
endmodule