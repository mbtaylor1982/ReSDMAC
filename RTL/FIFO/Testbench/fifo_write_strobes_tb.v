`timescale 1ns/100ps
 `include "RTL/FIFO/fifo_write_strobes.v"

module fifo_write_strobes_tb; 

//inputs
reg [1:0] PTR;
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
    .PTR    (PTR),
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
            {LBYTE_, LHWORD, LLWORD, PTR, TV_UUWS, TV_UMWS, TV_LMWS, TV_LLWS} = test_data[i];
            #10
            if (LLWS != TV_LLWS) $display("Test case %0d Failed on LLWS", i);
            if (LMWS != TV_LMWS) $display("Test case %0d Failed on LMWS", i);
            if (UUWS != TV_UUWS) $display("Test case %0d Failed on UUWS", i);
            if (UMWS != TV_UMWS ) $display("Test case %0d Failed on UMWS", i);
        end

        $finish;
    end    
    
endmodule