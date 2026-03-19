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
    input RESET_,
    input BOEQ0,
    input BOEQ3,
    input CLK,
    input CLK100,            // 100MHz main clock
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
    .CLK100         (CLK100         ),  // input, (wire), CLK100
    .nRESET         (RESET_         ),  // input, (wire), Active low reset
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

sync_2ff u_sync_BGRANT (
    .clk        (CLK100  ),
    .async_in   (aBGRANT_),
    .sync_out   (BGRANT_ )
);

sync_2ff u_sync_DMAENA (
    .clk        (CLK100  ),
    .async_in   (aDMAENA ),
    .sync_out   (DMAENA_ )
);

sync_2ff u_sync_DREQ (
    .clk        (CLK100  ),
    .async_in   (aDREQ_  ),
    .sync_out   (DREQ_   )
);

sync_2ff u_sync_FLUSHFIFO (
    .clk        (CLK100      ),
    .async_in   (aFLUSHFIFO  ),
    .sync_out   (FLUSHFIFO   )
);

// Synchronize cycle-done feedback to CLK100 domain.
always @(posedge CLK100 or negedge RESET_) begin
    if (~RESET_)
        nCYCLEDONE      <= 1'b1;
    else
        nCYCLEDONE      <= aCYCLEDONE_;
end

//clocked outputs
always @(posedge CLK100 or negedge RESET_) begin
    if (~RESET_) begin
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
    end else begin
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

// DSACK latching - fully synchronous on CLK100.
always @(posedge CLK100 or negedge RESET_) begin
    if (~RESET_)
        DSACK_LATCHED_ <= 2'b11;
    else begin
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
