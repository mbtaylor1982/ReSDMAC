//ReSDMAC © 2024-2026 by Michael Taylor is licensed under Creative Commons Attribution-ShareAlike 4.0 International.
//To view a copy of this license, visit https://creativecommons.org/licenses/by-sa/4.0/

`include "../synchroniser.v"

module SCSI_SM

(   input  i_CLK100,               // 100MHz main clock
    input  i_BOEQ3,                // Indicates Byte Pointer is at 4th byte (end of 32-bit word), from FIFO module
    input  i_CPUREQ_async,         // CPU Request for SCSI transfer (async)
    input  i_DEC_FIFO_ACK,         // Acknowledgment from CPU SM that it has processed the FIFO decrement request
    input  i_DMADIR,               // DMA Direction: 1 = CPU to SCSI, 0 = SCSI to CPU, from CPU SM
    input  i_DREQ_n_async,         // SCSI IC Data Request (async, active low)
    input  i_FIFOEMPTY,            // Indicates FIFO is empty, from FIFO module
    input  i_FIFOFULL,             // Indicates FIFO is full, from FIFO module
    input  i_INC_FIFO_ACK,         // acknowledgment from CPU SM that it has processed the FIFO increment request
    input  i_AS_n,                 // Address Strobe used to indicate CPU cycle termination (active low)
    input  i_RESET_n,              // Active low reset
    input  i_RW,                   // Read/Write signal used to indicate CPU read (1) or write (0) during CPU transfers

    output reg  o_CPU2S,           // Indicate CPU to SCSI Transfer
    output reg  o_DACK,            // Data transfer acknowledge to scsi IC (also used to generate LBYTE_n)
    output reg  o_F2S,             // Indicate FIFO to SCSI Transfer
    output reg  o_INCBO,           // Increment FIFO Byte Pointer
    output reg  o_INCNI,           // Increment FIFO Next In Pointer
    output reg  o_INCNO,           // Increment FIFO Next Out Pointer
    output reg  o_FIFO_DEC_PEND,   // FIFO decrement request pending (set on request, cleared when CPU SM acknowledges)
    output reg  o_RE,              // Read indicator to SCSI IC
    output reg  o_FIFO_INC_PEND,   // FIFO increment request pending (set on request, cleared when CPU SM acknowledges)
    output reg  o_S2CPU,           // Indicate SCSI to CPU Transfer
    output reg  o_S2F,             // Indicate SCSI to FIFO Transfer
    output reg  o_SCSI_CS,         // Chip Select for SCSI IC
    output reg  o_WE,              // Write indicator to SCSI IC
    output reg  o_LBYTE_n,         // Load byte signal for FIFO, active low
    output      o_LS2CPU           // Latch SCSI to CPU DATA, Also indicates CPU Cycle Termination
);

// -------------------------------------------------------------------------
// Synchronized versions of async inputs
// -------------------------------------------------------------------------

wire cpu_req;   // i_CPUREQ_async synchronized to i_CLK100
wire dreq_n;    // i_DREQ_n_async synchronized to i_CLK100, active low
wire dsack_n;   // Feedback from CPU cycle termination, active low
reg dsack;

sync_2ff u_sync_dreq (
    .clk        (i_CLK100        ),
    .async_in   (i_DREQ_n_async  ),
    .sync_out   (dreq_n          )
);

sync_2ff u_sync_cpureq (
    .clk        (i_CLK100        ),
    .async_in   (i_CPUREQ_async  ),
    .sync_out   (cpu_req         )
);

// -------------------------------------------------------------------------
// One-hot state encoding: one bit per state, optimal for FPGA (Quartus) synthesis.
// -------------------------------------------------------------------------

localparam [14:0]
    // Idle state waiting for a transfer to start
    IDLE        = 15'b000_0000_0000_0001,

    //CPU to SCSI States
    C2S_SETUP   = 15'b000_0000_0000_0010,
    C2S_XFER    = 15'b000_0000_0000_0100,
    C2S_WAIT    = 15'b000_0000_0000_1000,
    C2S_HOLD    = 15'b000_0000_0001_0000,

    //SCSI to CPU States
    S2C_SETUP   = 15'b000_0000_0010_0000,
    S2C_XFER    = 15'b000_0000_0100_0000,
    S2C_WAIT    = 15'b000_0000_1000_0000,
    S2C_HOLD    = 15'b000_0001_0000_0000,

    //FIFO to SCSI States
    F2S_STROBE  = 15'b000_0010_0000_0000,
    F2S_HOLD    = 15'b000_0100_0000_0000,
    F2S_UPDATE  = 15'b000_1000_0000_0000,

    //SCSI to FIFO States
    S2F_STROBE  = 15'b001_0000_0000_0000,
    S2F_LATCH   = 15'b010_0000_0000_0000,
    S2F_UPDATE  = 15'b100_0000_0000_0000;

// -------------------------------------------------------------------------
// Timing constants for WD33C93 SCSI IC interface (100MHz clock, 1 cycle = 10ns).
// Timing parameters reference WD33C93A (conservative). WD33C93B is faster on
// tRLDV (162ns vs 180ns) and tRHCH/tWHCH (-5ns vs 0ns); A values satisfy both.
// -------------------------------------------------------------------------

localparam [7:0]
    // CPU Write (C2S): SETUP + XFER together form the WE pulse.
    // Total WE = (C2S_SETUP_CYCLES+1) + (C2S_XFER_CYCLES+1) = 12 cycles = 120ns (tWE min 120ns)

    C2S_SETUP_CYCLES  = 8'd4,   //  5 cycles =  50ns  address/data setup
    C2S_XFER_CYCLES   = 8'd6,   //  7 cycles =  70ns  WE asserted with data

    // CPU Read (S2C): RE must be low for tRLDV = 180ns (WD33C93A) before data valid.
    // Total RE = (S2C_SETUP_CYCLES+1) + (S2C_XFER_CYCLES+1) = 20 cycles = 200ns

    S2C_SETUP_CYCLES  = 8'd17,  // 18 cycles = 180ns  RE low, waiting for data valid (tRLDV)
    S2C_XFER_CYCLES   = 8'd1,   //  2 cycles =  20ns  data sampled while RE still asserted

    // CPU cycles: minimum wait before polling dsack_n (both C2S and S2C)

    DSACK_MIN_WAIT    = 8'd3,   //  4 cycles =  40ns

    // CPU cycles: CS/WE/RE recovery time. tWHWL / tRHRL = 100ns min (both A and B)

    CPU_HOLD_CYCLES   = 8'd9,   // 10 cycles = 100ns

    // DMA strobe phase durations (active WE/RE assertion).
    // tWR (WE pulse) min = 50ns; tRD (RE pulse) min = 80ns (WD33C93A/B identical)

    F2S_STROBE_CYCLES = 8'd5,   //  6 cycles =  60ns  WE pulse (F2S, meets tWR >= 50ns)
    S2F_STROBE_CYCLES = 8'd7,   //  8 cycles =  80ns  RE pulse (S2F, meets tRD >= 80ns)

    // DMA post-strobe hold: WE/RE deasserted, signals held before pointer update

    DMA_HOLD_CYCLES   = 8'd3,   //  4 cycles =  40ns  data hold after WE/RE deassert

    // DMA pointer update pulse: INCBO/INCNO/INCNI asserted for this duration

    DMA_UPDATE_CYCLES = 8'd3;   //  4 cycles =  40ns  pointer increment pulse width

// -------------------------------------------------------------------------
// State machine registers
// -------------------------------------------------------------------------

reg [14:0] state_reg;
reg [14:0] next_state;

// Counter to create wait states for SCSI IC timing requirements
reg [7:0] wait_state_counter;

// -------------------------------------------------------------------------
// Transfer start conditions
// -------------------------------------------------------------------------

wire start_s2f = (~cpu_req & ~dreq_n & ~i_FIFOFULL  &  i_DMADIR & ~o_FIFO_INC_PEND); // hold off until prior increment is acknowledged
wire start_f2s = (~cpu_req & ~dreq_n & ~i_FIFOEMPTY & ~i_DMADIR & ~o_FIFO_DEC_PEND); // hold off until prior decrement is acknowledged
wire start_s2c = ( cpu_req &  dreq_n &  i_RW );
wire start_c2s = ( cpu_req &  dreq_n & ~i_RW );

// -------------------------------------------------------------------------
// Combinational state machine signals (registered at output stage below)
// -------------------------------------------------------------------------

reg comb_cpu2s;
reg comb_dack;
reg comb_f2s;
reg comb_incbo;
reg comb_incni;
reg comb_incno;
reg comb_fifo_dec_req;
reg comb_re;
reg comb_fifo_inc_req;
reg comb_s2cpu;
reg comb_s2f;
reg comb_scsi_cs;
reg comb_we;
reg comb_set_dsack;

// -------------------------------------------------------------------------
// State machine: sequential (state register + wait counter)
// -------------------------------------------------------------------------

always @(posedge i_CLK100 or negedge i_RESET_n) begin
    if (!i_RESET_n) begin
        state_reg          <= IDLE;
        wait_state_counter <= 8'd0;
    end else begin
        state_reg <= next_state;

        if (next_state != state_reg)
            wait_state_counter <= 8'd0;
        else
            wait_state_counter <= wait_state_counter + 1;
    end
end

// -------------------------------------------------------------------------
// State machine: next-state logic
// -------------------------------------------------------------------------

always @(*) begin
    next_state = IDLE;

    case (state_reg)
        IDLE: begin
            casez ({start_s2f, start_f2s, start_s2c, start_c2s})
                4'b1000  : next_state = S2F_STROBE;
                4'b0100  : next_state = F2S_STROBE;
                4'b??1?  : next_state = S2C_SETUP;
                4'b???1  : next_state = C2S_SETUP;
                default  : next_state = IDLE;
            endcase
        end

        //CPU to SCSI
        C2S_SETUP : next_state = wait_state_counter >= C2S_SETUP_CYCLES  ? C2S_XFER   : C2S_SETUP;
        C2S_XFER  : next_state = wait_state_counter >= C2S_XFER_CYCLES   ? C2S_WAIT   : C2S_XFER;
        C2S_WAIT  : next_state = wait_state_counter >= DSACK_MIN_WAIT    ? (dsack_n ? C2S_HOLD : C2S_WAIT) : C2S_WAIT;
        C2S_HOLD  : next_state = wait_state_counter >= CPU_HOLD_CYCLES   ? IDLE       : C2S_HOLD;

        //SCSI to CPU
        S2C_SETUP : next_state = wait_state_counter >= S2C_SETUP_CYCLES  ? S2C_XFER   : S2C_SETUP;
        S2C_XFER  : next_state = wait_state_counter >= S2C_XFER_CYCLES   ? S2C_WAIT   : S2C_XFER;
        S2C_WAIT  : next_state = wait_state_counter >= DSACK_MIN_WAIT    ? (dsack_n ? S2C_HOLD : S2C_WAIT) : S2C_WAIT;
        S2C_HOLD  : next_state = wait_state_counter >= CPU_HOLD_CYCLES   ? IDLE       : S2C_HOLD;

        //FIFO to SCSI
        F2S_STROBE : next_state = wait_state_counter >= F2S_STROBE_CYCLES ? F2S_HOLD   : F2S_STROBE;
        F2S_HOLD   : next_state = wait_state_counter >= DMA_HOLD_CYCLES   ? F2S_UPDATE : F2S_HOLD;
        F2S_UPDATE : next_state = wait_state_counter >= DMA_UPDATE_CYCLES ? IDLE       : F2S_UPDATE;

        //SCSI to FIFO
        S2F_STROBE : next_state = wait_state_counter >= S2F_STROBE_CYCLES ? S2F_LATCH  : S2F_STROBE;
        S2F_LATCH  : next_state = wait_state_counter >= DMA_HOLD_CYCLES   ? S2F_UPDATE : S2F_LATCH;
        S2F_UPDATE : next_state = wait_state_counter >= DMA_UPDATE_CYCLES ? IDLE       : S2F_UPDATE;

    endcase
end

// -------------------------------------------------------------------------
// State machine: output logic (combinational)
// -------------------------------------------------------------------------

always @(*) begin
    comb_cpu2s        = 1'b0;
    comb_dack         = 1'b0;
    comb_f2s          = 1'b0;
    comb_incbo        = 1'b0;
    comb_incni        = 1'b0;
    comb_incno        = 1'b0;
    comb_fifo_dec_req = 1'b0;
    comb_re           = 1'b0;
    comb_fifo_inc_req = 1'b0;
    comb_s2cpu        = 1'b0;
    comb_s2f          = 1'b0;
    comb_scsi_cs      = 1'b0;
    comb_we           = 1'b0;
    comb_set_dsack    = 1'b0;

    case (state_reg)
        //CPU to SCSI
        C2S_SETUP: begin
            comb_scsi_cs  = 1'b1;
            comb_we       = 1'b1;
            comb_cpu2s    = 1'b1;
        end
        //same outputs as C2S_SETUP, may want to add extra outputs to signal when to latch data onto the scsi bus.
        C2S_XFER: begin
            comb_scsi_cs  = 1'b1;
            comb_we       = 1'b1;
            comb_cpu2s    = 1'b1;
        end
        C2S_WAIT: begin
            comb_set_dsack = 1'b1;
        end

        //SCSI to CPU
        S2C_SETUP: begin
            comb_scsi_cs  = 1'b1;
            comb_re       = 1'b1;
            //comb_s2cpu  = 1'b1; experimenting with asserting s2cpu during setup.
        end
        S2C_XFER: begin
            comb_scsi_cs  = 1'b1;
            comb_re       = 1'b1;
            comb_s2cpu    = 1'b1;
        end
        S2C_WAIT: begin
            comb_set_dsack = 1'b1;
        end

        //FIFO to SCSI
        F2S_STROBE: begin
            // comb_scsi_cs not asserted: WD33C93 does not require CS during DMA transfers
            comb_we       = 1'b1;
            comb_f2s      = 1'b1;
            comb_dack     = 1'b1;
        end
        F2S_HOLD: begin
            comb_f2s      = 1'b1;
        end
        F2S_UPDATE: begin
            comb_f2s      = 1'b1;
            comb_incbo    = 1'b1;
            if (i_BOEQ3) begin
                comb_incno        = 1'b1;
                comb_fifo_dec_req = 1'b1;
            end
        end

        //SCSI to FIFO
        S2F_STROBE: begin
            // comb_scsi_cs not asserted: WD33C93 does not require CS during DMA transfers
            comb_re       = 1'b1;
            comb_s2f      = 1'b1;
            comb_dack     = 1'b1;
        end
        S2F_LATCH: begin
            comb_s2f      = 1'b1;
        end
        S2F_UPDATE: begin
            comb_incbo    = 1'b1;
            comb_s2f      = 1'b1;
            if (i_BOEQ3) begin
                comb_incni        = 1'b1;
                comb_fifo_inc_req = 1'b1;
            end
        end
    endcase
end

// -------------------------------------------------------------------------
// Register combinational outputs
// -------------------------------------------------------------------------

always @(posedge i_CLK100 or negedge i_RESET_n) begin
    if (~i_RESET_n) begin
        o_CPU2S         <= 1'b0;
        o_DACK          <= 1'b0;
        o_F2S           <= 1'b0;
        o_INCBO         <= 1'b0;
        o_INCNI         <= 1'b0;
        o_INCNO         <= 1'b0;
        o_RE            <= 1'b0;
        o_S2CPU         <= 1'b0;
        o_S2F           <= 1'b0;
        o_SCSI_CS       <= 1'b0;
        o_WE            <= 1'b0;
        o_FIFO_DEC_PEND <= 1'b0;
        o_FIFO_INC_PEND <= 1'b0;
        dsack           <= 1'b0;
        o_LBYTE_n       <= 1'b1;
    end else begin

        if (i_INC_FIFO_ACK)
            o_FIFO_INC_PEND <= 1'b0; // Clear pending flag when CPU SM acknowledges the increment request
        else if (comb_fifo_inc_req)
            o_FIFO_INC_PEND <= 1'b1; // Set pending flag when SCSI SM issues a new increment request

        if (i_DEC_FIFO_ACK)
            o_FIFO_DEC_PEND <= 1'b0; // Clear pending flag when CPU SM acknowledges the decrement request
        else if (comb_fifo_dec_req)
            o_FIFO_DEC_PEND <= 1'b1; // Set pending flag when SCSI SM issues a new decrement request

        if (i_AS_n)
            dsack    <= 1'b1; // Deassert dsack when CPU cycle termination is indicated by the address strobe going inactive,
        else if (comb_set_dsack)
            dsack    <= 1'b0; // Assert dsack to indicate CPU cycle termination.

        o_CPU2S         <= comb_cpu2s;
        o_DACK          <= comb_dack;
        o_F2S           <= comb_f2s;
        o_INCBO         <= comb_incbo;
        o_INCNI         <= comb_incni;
        o_INCNO         <= comb_incno;
        o_RE            <= comb_re;
        o_S2CPU         <= comb_s2cpu;
        o_S2F           <= comb_s2f;
        o_SCSI_CS       <= comb_scsi_cs;
        o_WE            <= comb_we;
        o_LBYTE_n       <= ~(comb_dack & comb_re);
    end
end

assign dsack_n  = ~dsack;
assign o_LS2CPU = dsack_n;

endmodule
