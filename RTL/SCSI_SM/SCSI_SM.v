//ReSDMAC © 2024 by Michael Taylor is licensed under Creative Commons Attribution-ShareAlike 4.0 International. To view a copy of this license, visit https://creativecommons.org/licenses/by-sa/4.0/

`ifdef __ICARUS__ 
    `include "SCSI_SM_INTERNALS.v"
    `include "scsi_sm_internals1.v"
`endif

module SCSI_SM

(   input BOEQ3,            //Asserted when transfering Byte 3
    input CLK,               //CPUClk.
    input CLK45,            //CPUClk phase shifted 45 deg.
    input CLK90,            //CPUCLK phase shifted 90 deg.
    input CLK135,           //CPUCLK phase shifted 135 deg
    input CPUREQ,           //Request CPU access to SCSI registers.
    input DECFIFO,          //Decrement FIFO pointer
    input DMADIR,           //Control Direction Of DMA transfer.
    input DREQ_,            //Data transfer request from SCSI IC
    input FIFOEMPTY,        //FIFOFULL flag
    input FIFOFULL,         //FIFOEMPTY flag
    input INCFIFO,          //Increment FIFO pointer
    input AS_,              //CPU Address Strobe
    input RESET_,           //System Reset
    input RW,               //CPU RW signal

    output reg CPU2S_o,     //Indicate CPU to SCSI Transfer
    output reg DACK_o,      //SCSI IC Data request Acknowledge
    output reg F2S_o,       //Indicate FIFO to SCSI Transfer
    output reg INCBO_o,     //Increment FIFO Byte Pointer
    output reg INCNI_o,     //Increment FIFO Next In Pointer
    output reg INCNO_o,     //Increement FIFO Next Out Pointer
    output reg RDFIFO_o,    //Read Longword from FIFO
    output reg RE_o,        //Read indicator to SCSI IC
    output reg RIFIFO_o,    //Write Longword to FIFO
    output reg S2CPU_o,     //Indicate SCSI to CPU Transfer
    output reg S2F_o,       //Indicate SCSI to FIFO Transfer
    output reg SCSI_CS_o,   //Chip Select for SCSI IC
    output reg WE_o,        //Write indicator to SCSI IC
    output wire LBYTE_,     //Load byte signal for FIFO
    output wire LS2CPU      //Latch SCSI to CPU DATA, Also indicates CPU Cycle Termination
);


//Clocked inputs
reg CCPUREQ;    // Clocked signal to indicate a CPU cycle to read or write WD33C93 Registers.
reg CDREQ_;     // Clocked WD33C93 DMA request.
reg CDSACK_;    // Clocked Feedback from CPU cycle termination.
reg CRESET_;    // Clocked system reset.

wire CPU2S;     // Enable CPU to SCSI datapath.
wire DACK;      // Ack WD3C93 DMA transfer request.
wire DSACK_;    // Feedback from CPU cycle termination.
wire F2S;       // Enable FIFO to SCSI datapath.
wire INCBO;     // Inc the FIFO byte ptr.
wire INCNI;     // Inc the FIFO Next in ptr.
wire INCNO;     // Inc the FIFO Next out ptr.
wire RDRST_;    // Feedback from RDFIFO_d.
wire RE;        // Read enable line for WD33C93 IC.
wire RIRST_;    // Feedback from RIFIFO_d.
wire S2CPU;     // Enable SCSI to CPU datapath.
wire S2F;       // Enable SCSI to FIFO datapath.
wire SCSI_CS;   // Chip select to WD33C93 IC.
wire SET_DSACK; // Signal to latch SCSI data for CPU and terminate CPU Cycle.
wire WE;        // Write enable line for WD33C93 IC.
wire RDFIFO;
wire RIFIFO;

reg nLS2CPU;    //Inverted signal to idicate when to latch the SCSI data for CPU cycle.

//*not sure on these  Miket 2023-01-28*
reg RDFIFO_d;   // Signal CPU SM to read FIFO?
reg RIFIFO_d;   // Signal CPU SM to Write to FIFO?

/*
--To swap between the FSM implmanetions instsiate the different modules--
    1.Original gate based FSM = SCSI_SM_INTERNALS1
    2.Standard verilog form fsm = SCSI_SM_INTERNALS
*/
SCSI_SM_INTERNALS u_SCSI_SM_INTERNALS (
    .CLK        (CLK90      ),  // input, (wire), CLK
    .nRESET     (CRESET_    ),  // input, (wire), Active low reset
    .BOEQ3      (BOEQ3      ),  // input, (wire), Asserted when transfering Byte 3
    .CCPUREQ    (CCPUREQ    ),  // input, (wire), Request CPU access to SCSI registers.
    .CDREQ_     (CDREQ_     ),  // input, (wire), Data transfer request from SCSI IC.
    .CDSACK_    (CDSACK_    ),  // input, (wire), DSACK
    .DMADIR     (DMADIR     ),  // input, (wire), Control Direction Of DMA transfer.
    .FIFOEMPTY  (FIFOEMPTY  ),  // input, (wire), FIFOFULL flag
    .FIFOFULL   (FIFOFULL   ),  // input, (wire), FIFOEMPTY flag
    .RDFIFO_o   (RDFIFO_o   ),  // input, (wire),
    .RIFIFO_o   (RIFIFO_o   ),  // input, (wire),
    .RW         (RW         ),  // input, (wire), CPU RW signal
    .CPU2S      (CPU2S      ),  // output, reg, Indicate CPU to SCSI Transfer
    .DACK       (DACK       ),  // output, reg, SCSI IC Data request Acknowledge
    .F2S        (F2S        ),  // output, reg, Indicate FIFO to SCSI Transfer
    .INCBO      (INCBO      ),  // output, reg, Increment FIFO Byte Pointer
    .INCNI      (INCNI      ),  // output, reg, Increment FIFO Next In Pointer
    .INCNO      (INCNO      ),  // output, reg, Increement FIFO Next Out Pointer
    .RDFIFO     (RDFIFO     ),  // output, reg, Read Longword from FIFO
    .RE         (RE         ),  // output, reg, Read indicator to SCSI IC
    .RIFIFO     (RIFIFO     ),  // output, reg, Write Longword to FIFO
    .S2CPU      (S2CPU      ),  // output, reg, Indicate SCSI to CPU Transfer
    .S2F        (S2F        ),  // output, reg, Indicate SCSI to FIFO Transfer
    .SCSI_CS    (SCSI_CS    ),  // output, reg, Chip Select for SCSI IC
    .WE         (WE         ),  // output, reg, Write indicator to SCSI IC
    .SET_DSACK  (SET_DSACK  )   // output, reg,
);

//clocked reset
always @(negedge  CLK) begin
    CRESET_ <= RESET_;
end

//clocked inputs.
always @(negedge  CLK135 or negedge CRESET_) begin
    if (~CRESET_)
    begin
        CDSACK_ <= 1'b1;
        CCPUREQ <= 1'b0;
        CDREQ_  <= 1'b1;
    end
    else
    begin
        CCPUREQ <= CPUREQ;
        CDREQ_  <= DREQ_;
        CDSACK_ <= DSACK_;
    end
end

//Clocked outputs.
always @(posedge CLK90 or negedge CRESET_) begin
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
    else
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

always @(posedge CLK135 or negedge RESET_) begin
    if (~RESET_) begin
        RDFIFO_o <= 1'b0;
	    RIFIFO_o <= 1'b0;
	end
    else if (DECFIFO)
        RDFIFO_o <= 1'b0;
	else if (INCFIFO)
        RIFIFO_o <= 1'b0;
	else if (RDFIFO_d)
        RDFIFO_o <= 1'b1;
	else if (RIFIFO_d)
        RIFIFO_o <= 1'b1;
end


always @(posedge CLK135 or posedge AS_) begin
    if (AS_)
        nLS2CPU <= 1'b0;
    else //if (SET_DSACK)
        nLS2CPU <= (LS2CPU & SET_DSACK);
end

assign LS2CPU = ~nLS2CPU;
assign DSACK_ = LS2CPU;
assign LBYTE_ = ~(DACK_o & RE_o);

endmodule