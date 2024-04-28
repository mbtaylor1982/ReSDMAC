
`timescale  1ns / 1ps

`include "RTL/Registers/addr_decoder.v"

module tb_addr_decoder;

// addr_decoder Parameters


//Test variables
integer i;

// addr_decoder Inputs
reg   CLK                                  = 0 ;
reg   [7:0]  ADDR                          = 0 ;
reg   DMAC_                                = 0 ;
reg   AS_                                  = 0 ;
reg   RW                                   = 0 ;
reg   DMADIR                               = 0 ;

// addr_decoder Outputs
wire  h_0C                                 ;
wire  WDREGREQ                             ;
wire  CONTR_RD_                            ;
wire  CONTR_WR                             ;
wire  ISTR_RD_                             ;
wire  ACR_WR                               ;
wire  WTC_RD_                              ;
wire  ST_DMA                               ;
wire  SP_DMA                               ;
wire  CLR_INT                              ;
wire  FLUSH_                               ;

addr_decoder u_addr_decoder (
    .CLK        (CLK        ),  // Input, (wire), CPU Clk.
    .ADDR       (ADDR       ),  // input, (wire) [7:0], CPU address Bus
    .DMAC_      (DMAC_      ),  // input, (wire), SDMAC Chip Select !SCSI from Fat Garry.
    .AS_        (AS_        ),  // input, (wire), CPU Address Strobe.
    .RW         (RW         ),  // input, (wire), CPU Read Write Control Line.
    .DMADIR     (DMADIR     ),  // input, (wire), DMADIR from bit from Control Register.
    .h_0C       (h_0C       ),  // output, (wire), 
    .WDREGREQ   (WDREGREQ   ),  // output, (wire), 
    .CONTR_RD_  (CONTR_RD_  ),  // output, (wire), 
    .CONTR_WR   (CONTR_WR   ),  // output, (wire), 
    .ISTR_RD_   (ISTR_RD_   ),  // output, (wire), 
    .ACR_WR     (ACR_WR     ),  // output, (wire), 
    .WTC_RD_    (WTC_RD_    ),  // output, (wire), 
    .ST_DMA     (ST_DMA     ),  // output, (wire), 
    .SP_DMA     (SP_DMA     ),  // output, (wire), 
    .CLR_INT    (CLR_INT    ),  // output, (wire), 
    .FLUSH_     (FLUSH_     )   // output, (wire), 
);

//------------------------------------------------------------------------------
//  clk
//------------------------------------------------------------------------------
localparam CLK_FREQ = 25_000_000;
localparam PERIOD = 1E9/CLK_FREQ;
initial begin
    CLK = 0;
    forever #(PERIOD/2) CLK = ~ CLK;
end

initial
begin
    $display("*Testing SDMAC addr_decoder.v Module*");
    $dumpfile("../Registers/VCD/addr_decoder_tb.vcd");
    $dumpvars(0, u_addr_decoder);
        
    
    AS_ <= 1'b0;
    DMAC_ <= 1'b0;
    DMADIR <= 1'b1;
    
    
    $display("Testing address decode on Read Cycle");
    RW <= 1'b1;

    for (i = 0; i < 120; i = i + 4)
    begin
        ADDR <= i;
        repeat(2) #(PERIOD/2);   
    end
    
    repeat(2) #(PERIOD/2);
    
    $display("Testing address decode on Write Cycle");
    RW <= 1'b0;

    for (i = 0; i < 120; i = i + 4)
    begin
        ADDR <= i;
        repeat(2) #(PERIOD/2);    
    end

    $finish;
end

endmodule