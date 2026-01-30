//ReSDMAC © 2024 by Michael Taylor is licensed under Creative Commons Attribution-ShareAlike 4.0 International. To view a copy of this license, visit https://creativecommons.org/licenses/by-sa/4.0/

`ifdef __ICARUS__ 
  `include "CPU_SM_INTERNALS.v"
`endif

module CPU_SM(
    input A1,
    input aBGRANT_,
    input aDMAENA,
    input aDREQ_,
    input aFLUSHFIFO,
    input aRESET_,
    input BOEQ0,
    input BOEQ3,
    input CLK,
    input CLK100,            // 100MHz main clock
    input [1:0] phase,       // Phase counter value
    input phase_0,           // Phase 0 indicator (equivalent to CLK at 0°)
    input phase_90,          // Phase 1 indicator (equivalent to CLK45)
    input phase_180,         // Phase 2 indicator (equivalent to CLK90)
    input phase_270,         // Phase 3 indicator (equivalent to CLK135)
    input DMADIR,
    input DSACK0_,
    input DSACK1_,
    input FIFOEMPTY,
    input FIFOFULL,
    input RDFIFO_,
    input RIFIFO_,
    input iSTERM_,
    input AS_,
    input BGACK_I_,

    output reg BGACK,
    output reg BREQ,
    output reg BRIDGEIN,
    output reg BRIDGEOUT,
    output reg DECFIFO,
    output reg DIEH,
    output reg DIEL,
    output reg F2CPUH,
    output reg F2CPUL,
    output reg INCFIFO,
    output reg INCNI,
    output reg INCNO,
    output reg PAS,
    output reg PDS,
    output reg PLHW,
    output reg PLLW,
    output reg SIZE1,
    output reg STOPFLUSH,
    output reg RST_FIFO
);

//clocked inputs with multi-stage synchronizers
reg CCRESET_;
reg [1:0] DSACK_LATCHED_;
reg nCYCLEDONE;

// Multi-stage synchronizers for async inputs (prevents metastability)
reg bgrant_sync1, bgrant_sync2;
reg dmaena_sync1, dmaena_sync2;
reg dreq_sync1, dreq_sync2;
reg flushfifo_sync1, flushfifo_sync2;

// Synchronized versions used internally
wire BGRANT_   = bgrant_sync2;
wire DMAENA    = dmaena_sync2;
wire DREQ_     = dreq_sync2;
wire FLUSHFIFO = flushfifo_sync2;

wire aCYCLEDONE_;
wire BGACK_d;
wire BRIDGEOUT_d;
wire CYCLEDONE;
wire DECFIFO_d;
wire DIEH_d;
wire DIEL_d;
wire iDSACK;
wire DSACK;


wire F2CPUH_d;
wire F2CPUL_d;
wire INCFIFO_d;
wire INCNO_d;
wire BREQ_d;
wire BRIDGEIN_d;
wire INCNI_d;
wire STOPFLUSH_d;
wire RST_FIFO_d;
wire PAS_d;
wire PDS_d;
wire PLHW_d;
wire PLLW_d;
wire SIZE1_d;
wire STERM_;
wire LASTWORD;

CPU_SM_INTERNALS u_CPU_SM_INTERNALS (
    .CLK            (CLK            ),  // input, (wire), CLK (SCLK for compatibility)
    .CLK100         (CLK100         ),  // input, (wire), CLK100
    .phase          (phase          ),  // input, (wire), phase counter
    .phase_0        (phase_0        ),  // input, (wire), phase 0 indicator
    .phase_90       (phase_90       ),  // input, (wire), phase 90 indicator
    .phase_180      (phase_180      ),  // input, (wire), phase 180 indicator
    .phase_270      (phase_270      ),  // input, (wire), phase 270 indicator
    .nRESET         (CCRESET_       ),  // input, (wire), Active low reset
    .A1             (A1             ),  // input, (wire),
    .nBGRANT        (BGRANT_        ),  // input, (wire),
    .BOEQ3          (BOEQ3          ),  // input, (wire),
    .CYCLEDONE      (CYCLEDONE      ),  // input, (wire),
    .DMADIR         (DMADIR         ),  // input, (wire),
    .DMAENA         (DMAENA         ),  // input, (wire),
    .nDREQ          (DREQ_          ),  // input, (wire),
    .nDSACK0        (DSACK0_        ),  // input, (wire),
    .nDSACK1        (DSACK1_        ),  // input, (wire),
    .FIFOEMPTY      (FIFOEMPTY      ),  // input, (wire),
    .FIFOFULL       (FIFOFULL       ),  // input, (wire),
    .FLUSHFIFO      (FLUSHFIFO      ),  // input, (wire),
    .LASTWORD       (LASTWORD       ),  // input, (wire),
    .DSACK          (DSACK          ),  // input, (wire),
    .nSTERM         (STERM_         ),  // input, (wire),
    .nRDFIFO        (RDFIFO_        ),  // input, (wire),
    .nRIFIFO        (RIFIFO_        ),  // input, (wire),

    .INCNI        (INCNI_d        ),  // output, (wire),
    .BREQ         (BREQ_d         ),  // output, (wire),
    .SIZE1        (SIZE1_d        ),  // output, (wire),
    .PAS          (PAS_d          ),  // output, (wire),
    .PDS          (PDS_d          ),  // output, (wire),
    .F2CPUL       (F2CPUL_d       ),  // output, (wire),
    .F2CPUH       (F2CPUH_d       ),  // output, (wire),
    .BRIDGEOUT    (BRIDGEOUT_d    ),  // output, (wire),
    .PLLW         (PLLW_d         ),  // output, (wire),
    .PLHW         (PLHW_d         ),  // output, (wire),
    .INCFIFO      (INCFIFO_d      ),  // output, (wire),
    .DECFIFO      (DECFIFO_d      ),  // output, (wire),
    .INCNO        (INCNO_d        ),  // output, (wire),
    .STOPFLUSH    (STOPFLUSH_d    ),  // output, (wire),
    .DIEH         (DIEH_d         ),  // output, (wire),
    .DIEL         (DIEL_d         ),  // output, (wire),
    .BRIDGEIN     (BRIDGEIN_d     ),  // output, (wire),
    .BGACK        (BGACK_d        ),   // output, (wire),
    .RST_FIFO     (RST_FIFO_d     )
);

//clocked reset (synchronized on CLK100 phase_0, equivalent to negedge CLK timing)
always @(posedge CLK100) begin
    if (phase_0)
        CCRESET_ <= aRESET_;
end

// Multi-stage synchronizers for async inputs
// Synchronize on phase_270 (equivalent to old CLK135 timing)
always @(posedge CLK100 or negedge CCRESET_) begin
    if (~CCRESET_) begin
        // First stage
        bgrant_sync1    <= 1'b1;
        dmaena_sync1    <= 1'b0;
        dreq_sync1      <= 1'b1;
        flushfifo_sync1 <= 1'b0;
        // Second stage
        bgrant_sync2    <= 1'b1;
        dmaena_sync2    <= 1'b0;
        dreq_sync2      <= 1'b1;
        flushfifo_sync2 <= 1'b0;
        // Synchronous signal
        nCYCLEDONE      <= 1'b1;
    end
    else if (phase_270) begin
        // First stage (may be metastable)
        bgrant_sync1    <= aBGRANT_;
        dmaena_sync1    <= aDMAENA;
        dreq_sync1      <= aDREQ_;
        flushfifo_sync1 <= aFLUSHFIFO;
        // Second stage (stable output)
        bgrant_sync2    <= bgrant_sync1;
        dmaena_sync2    <= dmaena_sync1;
        dreq_sync2      <= dreq_sync1;
        flushfifo_sync2 <= flushfifo_sync1;
        // Synchronous signal (only needs single stage)
        nCYCLEDONE      <= aCYCLEDONE_;
    end
end

//clocked outputs
// Register on phase_180 (equivalent to posedge CLK90 timing)
always @(posedge CLK100 or negedge CCRESET_) begin
    if (~CCRESET_) begin
        BGACK       <= 1'b0;
        PAS         <= 1'b0;
        PDS         <= 1'b0;
        BREQ        <= 1'b0;
        BRIDGEIN    <= 1'b0;
        BRIDGEOUT   <= 1'b0;
        DECFIFO     <= 1'b0;
        DIEH        <= 1'b0;
        DIEL        <= 1'b0;
        F2CPUH      <= 1'b0;
        F2CPUL      <= 1'b0;
        INCFIFO     <= 1'b0;
        INCNI       <= 1'b0;
        INCNO       <= 1'b0;
        PLHW        <= 1'b0;
        PLLW        <= 1'b0;
        SIZE1       <= 1'b0;
        STOPFLUSH   <= 1'b0;
        RST_FIFO    <= 1'b0;
    end
    else if (phase_180) begin
        BGACK       <= BGACK_d;
        BREQ        <= BREQ_d;
        BRIDGEIN    <= BRIDGEIN_d;
        BRIDGEOUT   <= BRIDGEOUT_d;
        DECFIFO     <= DECFIFO_d;
        DIEH        <= DIEH_d;
        DIEL        <= DIEL_d;
        F2CPUH      <= F2CPUH_d;
        F2CPUL      <= F2CPUL_d;
        INCFIFO     <= INCFIFO_d;
        INCNI       <= INCNI_d;
        INCNO       <= INCNO_d;
        PAS         <= PAS_d;
        PDS         <= PDS_d;
        PLHW        <= PLHW_d;
        PLLW        <= PLLW_d;
        SIZE1       <= SIZE1_d;
        STOPFLUSH   <= STOPFLUSH_d;
        RST_FIFO    <= RST_FIFO_d;
    end
end

// DSACK latching - now fully synchronous (was problematic async pattern before)
// Sample on phase_0 (equivalent to negedge CLK timing)
always @(posedge CLK100 or negedge CCRESET_) begin
    if (~CCRESET_)
        DSACK_LATCHED_ <= 2'b11;
    else if (phase_0) begin
        if (AS_)
            DSACK_LATCHED_ <= 2'b11;
        else
            DSACK_LATCHED_ <= {DSACK1_, DSACK0_};
    end
end

assign aCYCLEDONE_ = ~(BGACK_I_ & AS_ & DSACK0_ & DSACK1_ & iSTERM_);
assign LASTWORD = (~BOEQ0 & aFLUSHFIFO & FIFOEMPTY);
assign CYCLEDONE = ~nCYCLEDONE;
assign iDSACK = ~(DSACK_LATCHED_[0] & DSACK_LATCHED_[1]);
assign DSACK = iDSACK;
assign STERM_ = iSTERM_;


endmodule