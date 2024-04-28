
`timescale 1ns/100ps

`include "RTL/Registers/registers.v"

module registers_tb; 

//inputs
reg [7:0] ADDR;     // CPU address Bus
reg DMAC_;          // SDMAC Chip Select !SCSI from Fat Garry.
reg AS_;            // CPU Address Strobe.
reg RW;             // CPU Read Write Control Line.
reg CPUCLK;
reg [31:0] MID;     //DATA IN
reg STOPFLUSH;
reg RST_;
reg FIFOEMPTY;
reg FIFOFULL;
reg INTA_I;

//outputs
wire [31:0] MOD;    //DATA OUT.
wire PRESET;        //Peripheral Reset.
wire FLUSHFIFO;     //Flush FIFO.
wire ACR_WR;        //input to FIFO_byte_ptr.
wire h_0C;          //input to FIFO_byte_ptr.
wire A1;            //Store value of A1 written to ACR.  
wire INT_O_;        //INT_2 Output.
wire DMADIR;        //DMA Direction
wire DMAENA;        //DMA Enabled.  
wire REG_DSK_;      //Term Register cycle
wire WDREGREQ;      //Select SCSI chip.



registers u_registers(
    .ADDR      (ADDR      ),
    .DMAC_     (DMAC_     ),
    .AS_       (AS_       ),
    .RW        (RW        ),
    .CLK       (~CPUCLK   ),
    .MID       (MID       ),
    .STOPFLUSH (STOPFLUSH ),
    .RST_      (RST_      ),
    .FIFOEMPTY (FIFOEMPTY ),
    .FIFOFULL  (FIFOFULL  ),
    .INTA_I    (INTA_I    ),
    
    .MOD       (MOD       ),
    .PRESET    (PRESET    ),
    .FLUSHFIFO (FLUSHFIFO ),
    .ACR_WR    (ACR_WR    ),
    .h_0C      (h_0C      ),
    .A1        (A1        ),
    .INT_O_    (INT_O_    ),
    .DMADIR    (DMADIR    ),
    .DMAENA    (DMAENA    ),
    .REG_DSK_  (REG_DSK_  ),
    .WDREGREQ  (WDREGREQ  )
);

initial begin
        $display("*Testing SDMAC registers.v Module*");
        $dumpfile("../Registers/VCD/registers_tb.vcd");
        $dumpvars(0, u_registers);
        
        $display("Testing registers Read Cycle");
        CPUCLK = 1'b1;
        RST_ = 1'b1;
        AS_ = 1'b1;
        RW = 1'b1;
        DMAC_ = 1'b1;
        FIFOEMPTY = 1'b1;
        FIFOFULL = 1'b0;
        INTA_I = 1'b1;
        STOPFLUSH = 1'b0;
        
        ADDR = 8'h08;       
        repeat(2) #20 CPUCLK = ~CPUCLK;
        RST_ = 1'b0;
        repeat(4) #20 CPUCLK = ~CPUCLK;
        RST_ = 1'b1;
        repeat(2) #20 CPUCLK = ~CPUCLK;
        DMAC_ = 1'b0;
        repeat(2) #20 CPUCLK = ~CPUCLK;
        AS_ = 1'b0;
        repeat(12) #20 CPUCLK = ~CPUCLK;
        AS_ = 1'b1;
        repeat(2) #20 CPUCLK = ~CPUCLK;
        DMAC_ = 1'b1;
        repeat(4) #20 CPUCLK = ~CPUCLK;


        ADDR = 8'h10;
        repeat(2) #20 CPUCLK = ~CPUCLK;
        DMAC_ = 1'b0;
        repeat(2) #20 CPUCLK = ~CPUCLK;
        AS_ = 1'b0;
        repeat(12) #20 CPUCLK = ~CPUCLK;
        AS_ = 1'b1;
        repeat(2) #20 CPUCLK = ~CPUCLK;
        DMAC_ = 1'b1;
        repeat(4) #20 CPUCLK = ~CPUCLK;


        ADDR = 8'h08;
        repeat(2) #20 CPUCLK = ~CPUCLK;
        DMAC_ = 1'b0;
        repeat(2) #20 CPUCLK = ~CPUCLK;
        AS_ = 1'b0;
        repeat(12) #20 CPUCLK = ~CPUCLK;
        AS_ = 1'b1;
        repeat(2) #20 CPUCLK = ~CPUCLK;
        DMAC_ = 1'b1;
        repeat(4) #20 CPUCLK = ~CPUCLK;

        ADDR = 8'h3C;
        repeat(2) #20 CPUCLK = ~CPUCLK;
        DMAC_ = 1'b0;
        repeat(2) #20 CPUCLK = ~CPUCLK;
        AS_ = 1'b0;
        repeat(12) #20 CPUCLK = ~CPUCLK;
        AS_ = 1'b1;
        repeat(2) #20 CPUCLK = ~CPUCLK;
        DMAC_ = 1'b1;
        repeat(4) #20 CPUCLK = ~CPUCLK;

        ADDR = 8'h08;
        repeat(2) #20 CPUCLK = ~CPUCLK;
        DMAC_ = 1'b0;
        repeat(2) #20 CPUCLK = ~CPUCLK;
        AS_ = 1'b0;
        repeat(12) #20 CPUCLK = ~CPUCLK;
        AS_ = 1'b1;
        repeat(2) #20 CPUCLK = ~CPUCLK;
        DMAC_ = 1'b1;
        repeat(4) #20 CPUCLK = ~CPUCLK;

        ADDR = 8'h04;
        repeat(2) #20 CPUCLK = ~CPUCLK;
        DMAC_ = 1'b0;
        repeat(2) #20 CPUCLK = ~CPUCLK;
        AS_ = 1'b0;
        repeat(12) #20 CPUCLK = ~CPUCLK;
        AS_ = 1'b1;
        repeat(2) #20 CPUCLK = ~CPUCLK;
        DMAC_ = 1'b1;
        repeat(4) #20 CPUCLK = ~CPUCLK;

        ADDR = 8'h1c;
        repeat(2) #20 CPUCLK = ~CPUCLK;
        DMAC_ = 1'b0;
        repeat(2) #20 CPUCLK = ~CPUCLK;
        AS_ = 1'b0;
        repeat(12) #20 CPUCLK = ~CPUCLK;
        AS_ = 1'b1;
        repeat(2) #20 CPUCLK = ~CPUCLK;
        DMAC_ = 1'b1;
        repeat(4) #20 CPUCLK = ~CPUCLK;
        $finish;
end




endmodule