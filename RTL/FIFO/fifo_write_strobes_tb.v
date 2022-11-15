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

`include "RTL/FIFO/fifo_write_strobes.v"

module fifo_write_strobes_tb; 

//inputs
reg BO0;
reg BO1;
reg LHWORD;
reg LLWORD;
reg LBYTE_;

//Outputs
wire UUWS;
wire UMWS;
wire LMWS;
wire LLWS;

//Test variables
integer i;

reg [8:0] test_data [0:31];
reg TV_UUWS;
reg TV_UMWS;
reg TV_LMWS;
reg TV_LLWS;

//Module Under Test
fifo_write_strobes dut_fifo_write_strobes(
    .BO0    (BO0    ),
    .BO1    (BO1    ),
    .LHWORD (LHWORD ),
    .LLWORD (LLWORD ),
    .LBYTE_ (LBYTE_ ),
    .UUWS   (UUWS   ),
    .UMWS   (UMWS   ),
    .LMWS   (LMWS   ),
    .LLWS   (LLWS   )
);
    
    initial begin
        $display("*Testing SDMAC fifo_write_strobes.v");
        $dumpfile("../FIFO/VCD/fifo_write_strobes_tb.vcd");
        $dumpvars(0, fifo_write_strobes_tb);
        $display("read test data from file");
        $readmemb("../FIFO/TestData/fifo_write_strobes_vectors.txt", test_data);

        for (i = 0; i < 31; i = i + 1)
        begin
            {LBYTE_, LHWORD, LLWORD, BO1, BO0, TV_UUWS, TV_UMWS, TV_LMWS, TV_LLWS} = test_data[i];
            #10
            if (LLWS != TV_LLWS) $display("Test case %0d Failed on LLWS", i);
            if (LMWS != TV_LMWS) $display("Test case %0d Failed on LMWS", i);
            if (UUWS != TV_UUWS) $display("Test case %0d Failed on UUWS", i);
            if (UMWS != TV_UMWS ) $display("Test case %0d Failed on UMWS", i);
        end

        $finish;
    end    
    
endmodule