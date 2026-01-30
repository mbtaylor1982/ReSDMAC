//ReSDMAC © 2024 by Michael Taylor is licensed under Creative Commons Attribution-ShareAlike 4.0 International. To view a copy of this license, visit https://creativecommons.org/licenses/by-sa/4.0/

`ifdef __ICARUS__ 
    `include "SCSI_SM_INTERNALS.v"
`endif

module SCSI_SM

(   input BOEQ3,            //Asserted when transfering Byte 3
    input CLK,              //CPUClk.
    input CLK100,           //100MHz main clock
    input [1:0] phase,      //Phase counter value
    input phase_0,          //Phase 0 indicator (equivalent to CLK at 0°)
    input phase_90,         //Phase 1 indicator (equivalent to CLK45)
    input phase_180,        //Phase 2 indicator (equivalent to CLK90)
    input phase_270,        //Phase 3 indicator (equivalent to CLK135)
    input CPUREQ,           //Request CPU access to SCSI registers.
    input DECFIFO,          //Decrement FIFO pointer used to ack the request
    input DMADIR,           //Control Direction Of DMA transfer.
    input DREQ_,            //Data transfer request from SCSI IC (async)
    input FIFOEMPTY,        //FIFOFULL flag
    input FIFOFULL,         //FIFOEMPTY flag
    input INCFIFO,          //Increment FIFO pointer used to ack the request
    input AS_,              //CPU Address Strobe
    input RESET_,           //System Reset
    input RW,               //CPU RW signal

    output reg CPU2S_o,     //Indicate CPU to SCSI Transfer
    output reg DACK_o,      //SCSI IC Data request Acknowledge
    output reg F2S_o,       //Indicate FIFO to SCSI Transfer
    output reg INCBO_o,     //Increment FIFO Byte Pointer
    output reg INCNI_o,     //Increment FIFO Next In Pointer
    output reg INCNO_o,     //Increement FIFO Next Out Pointer
    output reg RDFIFO_o,    //Request FIFO Decrement from CPU FSM
    output reg RE_o,        //Read indicator to SCSI IC
    output reg RIFIFO_o,    //Request FIFO Increment from CPU FSM
    output reg S2CPU_o,     //Indicate SCSI to CPU Transfer
    output reg S2F_o,       //Indicate SCSI to FIFO Transfer
    output reg SCSI_CS_o,   //Chip Select for SCSI IC
    output reg WE_o,        //Write indicator to SCSI IC
    output wire LBYTE_,     //Load byte signal for FIFO
    output wire LS2CPU      //Latch SCSI to CPU DATA, Also indicates CPU Cycle Termination
);


//Clocked inputs with multi-stage synchronizers
reg CRESET_;    // Clocked system reset.
reg CCPUREQ;    // Clocked signal to indicate a CPU cycle to read or write WD33C93 Registers (synchronous).
reg CDSACK_;    // Clocked Feedback from CPU cycle termination (synchronous).

// Multi-stage synchronizer for async DREQ_ input (prevents metastability)
reg dreq_sync1, dreq_sync2;
wire CDREQ_ = dreq_sync2;  // Synchronized version used internally

wire CPU2S;     // Enable CPU to SCSI datapath.
wire DACK;      // Ack WD3C93 DMA transfer request.
wire DSACK_;    // Feedback from CPU cycle termination.
wire F2S;       // Enable FIFO to SCSI datapath.
wire INCBO;     // Inc the FIFO byte ptr.
wire INCNI;     // Inc the FIFO Next in ptr.
wire INCNO;     // Inc the FIFO Next out ptr.
wire RE;        // Read enable line for WD33C93 IC.
wire S2CPU;     // Enable SCSI to CPU datapath.
wire S2F;       // Enable SCSI to FIFO datapath.
wire SCSI_CS;   // Chip select to WD33C93 IC.
wire SET_DSACK; // Signal to latch SCSI data for CPU and terminate CPU Cycle.
wire WE;        // Write enable line for WD33C93 IC.
wire RDFIFO;    // Request FIFO Decrement from CPU FSM
wire RIFIFO;    // Request FIFO Increment from CPU FSM

reg nLS2CPU;    //Inverted signal to idicate when to latch the SCSI data for CPU cycle.

reg RDFIFO_d;   // clocked request FIFO Decrement from CPU FSM
reg RIFIFO_d;   // clocked request FIFO Increment from CPU FSM

/*
--To swap between the FSM implmanetions instsiate the different modules--
    1.Original gate based FSM = SCSI_SM_INTERNALS1
    2.Standard verilog form fsm = SCSI_SM_INTERNALS
*/
SCSI_SM_INTERNALS u_SCSI_SM_INTERNALS (
    .CLK100     (CLK100     ),  // input, (wire), CLK100
    .phase_180  (phase_180  ),  // input, (wire), Phase 180 indicator
    .nRESET     (CRESET_    ),  // input, (wire), Active low reset
    .BOEQ3      (BOEQ3      ),  // input, (wire), Asserted when transfering Byte 3
    .CCPUREQ    (CCPUREQ    ),  // input, (wire), Request CPU access to SCSI registers.
    .CDREQ_     (CDREQ_     ),  // input, (wire), Data transfer request from SCSI IC.
    .CDSACK_    (CDSACK_    ),  // input, (wire), DSACK
    .DMADIR     (DMADIR     ),  // input, (wire), Control Direction Of DMA transfer.
    .FIFOEMPTY  (FIFOEMPTY  ),  // input, (wire), FIFOFULL flag
    .FIFOFULL   (FIFOFULL   ),  // input, (wire), FIFOEMPTY flag
    .RDFIFO_o   (RDFIFO_o   ),  // input, (wire), Request FIFO DEC from CPU FSM
    .RIFIFO_o   (RIFIFO_o   ),  // input, (wire), Request FIFO INC from CPU FSM
    .RW         (RW         ),  // input, (wire), CPU RW signal
    .CPU2S      (CPU2S      ),  // output, reg, Indicate CPU to SCSI Transfer
    .DACK       (DACK       ),  // output, reg, SCSI IC Data request Acknowledge
    .F2S        (F2S        ),  // output, reg, Indicate FIFO to SCSI Transfer
    .INCBO      (INCBO      ),  // output, reg, Increment FIFO Byte Pointer
    .INCNI      (INCNI      ),  // output, reg, Increment FIFO Next In Pointer
    .INCNO      (INCNO      ),  // output, reg, Increement FIFO Next Out Pointer
    .RDFIFO     (RDFIFO     ),  // output, reg, Request FIFO Decrement from CPU FSM
    .RE         (RE         ),  // output, reg, Read indicator to SCSI IC
    .RIFIFO     (RIFIFO     ),  // output, reg, Request FIFO Increment from CPU FSM
    .S2CPU      (S2CPU      ),  // output, reg, Indicate SCSI to CPU Transfer
    .S2F        (S2F        ),  // output, reg, Indicate SCSI to FIFO Transfer
    .SCSI_CS    (SCSI_CS    ),  // output, reg, Chip Select for SCSI IC
    .WE         (WE         ),  // output, reg, Write indicator to SCSI IC
    .SET_DSACK  (SET_DSACK  )   // output, reg,
);

//clocked reset (synchronized on CLK100 phase_0, equivalent to negedge CLK timing)
always @(posedge CLK100) begin
    if (phase_0)
        CRESET_ <= RESET_;
end

// Multi-stage synchronizer for async DREQ_ input
// Synchronize on phase_270 (equivalent to negedge CLK135 timing)
always @(posedge CLK100 or negedge CRESET_) begin
    if (~CRESET_) begin
        // Multi-stage sync for async DREQ_
        dreq_sync1  <= 1'b1;
        dreq_sync2  <= 1'b1;
        // Synchronous inputs (single stage)
        CDSACK_     <= 1'b1;
        CCPUREQ     <= 1'b0;
    end
    else if (phase_270) begin
        // First stage (may be metastable)
        dreq_sync1  <= DREQ_;
        // Second stage (stable output)
        dreq_sync2  <= dreq_sync1;
        // Synchronous inputs
        CCPUREQ     <= CPUREQ;
        CDSACK_     <= DSACK_;
    end
end

//Clocked outputs.
// Register on phase_180 (equivalent to posedge CLK90 timing)
always @(posedge CLK100 or negedge CRESET_) begin
    if (~CRESET_)
    begin
        CPU2S_o     <= 1'b0;
        DACK_o      <= 1'b0;
        F2S_o       <= 1'b0;
        INCBO_o     <= 1'b0;
        INCNI_o     <= 1'b0;
        INCNO_o     <= 1'b0;
        RDFIFO_d    <= 1'b0;
        RE_o        <= 1'b0;
        RIFIFO_d    <= 1'b0;
        S2CPU_o     <= 1'b0;
        S2F_o       <= 1'b0;
        SCSI_CS_o   <= 1'b0;
        WE_o        <= 1'b0;
    end
    else if (phase_180)
    begin
        CPU2S_o     <= CPU2S;
        DACK_o      <= DACK;
        F2S_o       <= F2S;
        INCBO_o     <= INCBO;
        INCNI_o     <= INCNI;
        INCNO_o     <= INCNO;
        RDFIFO_d    <= RDFIFO;
        RE_o        <= RE;
        RIFIFO_d    <= RIFIFO;
        S2CPU_o     <= S2CPU;
        S2F_o       <= S2F;
        SCSI_CS_o   <= SCSI_CS;
        WE_o        <= WE;
    end
end

// FIFO request handshaking on phase_270 (equivalent to posedge CLK135 timing)
always @(posedge CLK100 or posedge INCFIFO or negedge RESET_ ) begin
    if (INCFIFO | ~RESET_) //ack the fifo inc request
        RIFIFO_o <= 1'b0;
	else if (phase_270 && RIFIFO_d) //request fifo inc
        RIFIFO_o <= 1'b1;
end

always @(posedge CLK100 or posedge DECFIFO or negedge RESET_) begin
    if (DECFIFO | ~RESET_) //ack the fifo dec request
        RDFIFO_o <= 1'b0;
    else if (phase_270 && RDFIFO_d) //request fifo dec
        RDFIFO_o <= 1'b1;
end

// LS2CPU latch - now fully synchronous (was problematic async AS_ pattern before)
// Sample on phase_180 (equivalent to posedge CLK90 timing)
always @(posedge CLK100 or negedge CRESET_) begin
    if (~CRESET_)
        nLS2CPU <= 1'b0;
    else if (phase_180) begin
        if (AS_)
            nLS2CPU <= 1'b0;
        else if (SET_DSACK)
            nLS2CPU <= 1'b1;
    end
end

assign LS2CPU = ~nLS2CPU;
assign DSACK_ = LS2CPU;
assign LBYTE_ = ~(DACK_o & RE_o);

endmodule