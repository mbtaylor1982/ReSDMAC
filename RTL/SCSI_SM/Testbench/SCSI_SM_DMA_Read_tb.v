
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
wire BOEQ3;
reg CPUCLK;
reg DREQ_;
wire FIFOFULL;
wire FIFOEMPTY;

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

wire DACK_;
wire RE_;

SCSI_SM u_SCSI_SM(
    .CPUREQ    (CPUREQ    ),
    .RW        (RW        ),
    .DMADIR    (DMADIR    ),
    .INCFIFO   (INCFIFO   ),
    .DECFIFO   (DECFIFO   ),
    .RESET_    (RESET_    ),
    .BOEQ3     (BOEQ3     ),
    .BCLK    (CPUCLK    ),
    .DREQ_     (DREQ_     ),
    .FIFOFULL  (FIFOFULL  ),
    .FIFOEMPTY (FIFOEMPTY ),
    .nAS_      (nAS_      ),
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
    .CPU2S_o   (CPU2S_o   ),
    .LS2CPU    (LS2CPU    ),
    .LBYTE_    (LBYTE_    )
);
reg [1:0] ByteCount;
reg [3:0] LongWordCount;

assign DACK_ = ~DACK_o;
assign RE_ = ~RE_o;

assign BOEQ3 = (ByteCount == 2'b11);
assign FIFOEMPTY = (LongWordCount == 4'b0000);
assign FIFOFULL = (LongWordCount == 4'b1000);


always @(posedge INCBO_o or negedge RESET_) begin
     if (RESET_ == 1'b0)
        ByteCount <= 2'b00;
    else
        ByteCount <= ByteCount + 2'b01;
end

always @(posedge INCFIFO or negedge RESET_) begin
     if (RESET_ == 1'b0)
        LongWordCount <= 4'b0000;
    else
        LongWordCount <= LongWordCount + 4'b0001;
end

always @(posedge CPUCLK or negedge RESET_) begin
     if (RESET_ == 1'b0)
        INCFIFO <= 1'b0;
    else
        INCFIFO <= INCNI_o;
end

    initial begin
        $display("*Testing SDMAC SCSI_SM.v Module*");
        $dumpfile("../SCSI_SM/VCD/SCSI_SM_DMA_READ_tb.vcd");
        $dumpvars(0, scsi_sm_tb);
        
        $display("Testing SCSI State Machine DMA Read Cycle");
        CPUCLK = 1'b1;
        CPUREQ = 1'b0;
        RESET_ = 1'b1;
        nAS_ = 1'b0;
        RW = 1'b0;
        DMADIR = 1'b1;
        DECFIFO = 1'b0;
        DREQ_ = 1'b1;
        repeat(2) #20 CPUCLK = ~CPUCLK;
        RESET_ = 1'b0;
        repeat(4) #20 CPUCLK = ~CPUCLK;
        RESET_ = 1'b1;
        repeat(4) #20 CPUCLK = ~CPUCLK;
        DREQ_ = 1'b0;
        repeat(364) #20 CPUCLK = ~CPUCLK;        
        $finish;
    end 

    

endmodule