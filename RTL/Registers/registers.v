 //ReSDMAC © 2024 by Michael Taylor is licensed under Creative Commons Attribution-ShareAlike 4.0 International. To view a copy of this license, visit https://creativecommons.org/licenses/by-sa/4.0/

`ifdef __ICARUS__
    `include "registers_flash.v"
    `define DEF_VERSION "v9.9"
    `define DEVICE "10M16SCU169C8G"
`endif

`include "..\phase_defs.vh"

module registers(
  input         i_CLK100,       // 100MHz main clock
  input  [1:0]  i_PHASE,        // Phase counter value
  input  [7:0]  i_ADDR,         // CPU address bus
  input         i_DMAC_n,       // SDMAC chip select
  input         i_AS_n,         // CPU address strobe
  input         i_DS_n,         // CPU data strobe
  input         i_RW,           // CPU read/write
  input  [31:0] i_MID,          // Data in
  input         i_STOPFLUSH,
  input         i_RST_n,        // System reset
  input         i_FIFOEMPTY,
  input         i_FIFOFULL,
  input         i_INTA,         // Interrupt input
  input         i_AS_O,         // Address strobe from CPU FSM
  input  [7:0]  i_DSP_DATA,

  output reg [31:0] o_REG_OD,
  output            o_PRESET,
  output reg        o_FLUSHFIFO,
  output            o_ACR_WR,
  output            o_H_0C,
  output reg        o_A1,
  output            o_INT_n,
  output            o_DMADIR,
  output            o_DMAENA,
  output            o_REG_DSK_n,
  output            o_WDREGREQ
);

// =========================================================================
// Address decode
// =========================================================================

wire addr_valid = ~(i_DMAC_n | i_AS_n);

wire h_04 = addr_valid & (i_ADDR == 8'h04);
wire h_08 = addr_valid & (i_ADDR == 8'h08);
assign o_H_0C = addr_valid & (i_ADDR == 8'h0C);
wire h_10 = addr_valid & (i_ADDR == 8'h10);
wire h_14 = addr_valid & (i_ADDR == 8'h14);
wire h_18 = addr_valid & (i_ADDR == 8'h18);
wire h_1C = addr_valid & (i_ADDR == 8'h1C);
wire h_20 = addr_valid & (i_ADDR == 8'h20);
wire h_24 = addr_valid & (i_ADDR == 8'h24);
wire h_28 = addr_valid & (i_ADDR == 8'h28);
wire h_2C = addr_valid & (i_ADDR == 8'h2C);
wire h_3C = addr_valid & (i_ADDR == 8'h3C);
wire h_5C = addr_valid & (i_ADDR == 8'h5C);
wire h_58 = addr_valid & (i_ADDR == 8'h58);

assign o_WDREGREQ = addr_valid & (i_ADDR[7:4] == 4'h4);

wire wtc_rd_n        = ~(h_04 & i_RW);
wire contr_rd_n      = ~(h_08 & i_RW);
wire istr_rd_n       = ~(h_1C & i_RW);
wire sspbdat_rd_n    = ~(h_58 & i_RW);
wire version_rd_n    = ~(h_20 & i_RW);
wire dsp_rd_n        = ~(h_5C & i_RW);
wire flash_addr_rd_n = ~(h_24 & i_RW);
wire flash_data_rd_n = ~(h_28 & i_RW);
wire dev_rd_n        = ~(h_2C & i_RW);

wire contr_wr      = h_08 & ~i_RW & ~i_DS_n;
assign o_ACR_WR    = o_H_0C & ~i_RW & ~i_DS_n;
wire sspbdat_wr    = h_58 & ~i_RW & ~i_DS_n;
wire version_wr    = h_20 & ~i_RW & ~i_DS_n;
wire flash_addr_wr = h_24 & ~i_RW & ~i_DS_n;
wire flash_data_wr = h_28 & ~i_RW & ~i_DS_n;

wire st_dma  = h_10;
wire sp_dma  = h_3C;
wire clr_int = h_18;
wire flush_n = ~h_14;

// =========================================================================
// Control register (CNTR)
// =========================================================================

reg intena;
reg cntr_preset;
reg cntr_dmadir;
reg cntr_dmaena;

always @(posedge i_CLK100 or negedge i_RST_n) begin
    if (~i_RST_n) begin
        cntr_dmadir <= 1'b0;
        intena      <= 1'b0;
        cntr_preset <= 1'b0;
        cntr_dmaena <= 1'b0;
    end
    else if (i_PHASE == `PHASE_1) begin
        if (contr_wr) begin
            cntr_dmadir <= i_MID[1];
            intena      <= i_MID[2];
            cntr_preset <= i_MID[4];
        end
        if (st_dma) cntr_dmaena <= 1'b1;
        if (sp_dma) cntr_dmaena <= 1'b0;
    end
end

wire [8:0] cntr_o = {cntr_dmaena, 1'b0, 1'b0, 1'b0, cntr_preset, 1'b0, intena, cntr_dmadir, 1'b0};

assign o_PRESET = cntr_preset;
assign o_DMADIR = ~cntr_dmadir;
assign o_DMAENA = cntr_dmaena;

// =========================================================================
// Interrupt status register (ISTR)
// =========================================================================

reg int_f, ints, e_int, int_p, ff, fe;

always @(posedge i_CLK100 or negedge i_RST_n) begin
    if (~i_RST_n) begin
        int_f <= 1'b0;
        ints  <= 1'b0;
        e_int <= 1'b0;
        int_p <= 1'b0;
        ff    <= 1'b0;
        fe    <= 1'b1;
    end
    else if (i_PHASE == `PHASE_1) begin
        if (clr_int) begin
            int_f <= 1'b0;
            ints  <= 1'b0;
            e_int <= 1'b0;
            int_p <= 1'b0;
        end
        if (~istr_rd_n) begin
            int_f <= i_INTA;
            ints  <= i_INTA;
            e_int <= i_INTA;
            int_p <= intena ? i_INTA : 1'b0;
            ff    <= i_FIFOFULL;
            fe    <= i_FIFOEMPTY;
        end
    end
end

wire [8:0] istr_o = {1'b0, int_f, ints, e_int, int_p, 1'b0, 1'b0, ff, fe};

assign o_INT_n = intena ? ~i_INTA : 1'b1;

// =========================================================================
// DSACK termination
// =========================================================================

localparam WAIT_CYCLES    = 1;
localparam COUNTER_WIDTH  = $clog2(WAIT_CYCLES + 1);

reg [COUNTER_WIDTH-1:0] term_counter;
reg reg_dsk_int;

`ifdef COCOTB_SIM
  wire cycle_active = ~(i_AS_n | i_DMAC_n | o_WDREGREQ | h_28);
`else
  wire cycle_active = ~(i_AS_n | i_DMAC_n | o_WDREGREQ | o_H_0C | h_28);
`endif

always @(posedge i_CLK100 or posedge i_AS_n) begin
    if (i_AS_n) begin
        term_counter <= {COUNTER_WIDTH{1'b0}};
        reg_dsk_int  <= 1'b1;
    end
    else if (cycle_active && (i_PHASE == `PHASE_1)) begin
        if (term_counter == WAIT_CYCLES[COUNTER_WIDTH-1:0])
            reg_dsk_int <= 1'b0;
        else
            term_counter <= term_counter + 1'b1;
    end
end

// =========================================================================
// FLUSHFIFO
// =========================================================================

always @(posedge i_CLK100 or negedge i_RST_n) begin
    if (~i_RST_n)
        o_FLUSHFIFO <= 1'b0;
    else if (~flush_n && (i_PHASE == `PHASE_1))
        o_FLUSHFIFO <= 1'b1;
    else if (i_STOPFLUSH && (i_PHASE == `PHASE_1))
        o_FLUSHFIFO <= 1'b0;
end

// =========================================================================
// A1 latch
// =========================================================================

always @(posedge i_CLK100 or negedge i_RST_n) begin
    if (~i_RST_n)
        o_A1 <= 1'b1;
    else if (o_ACR_WR && (i_PHASE == `PHASE_1))
        o_A1 <= i_MID[25];
    else if (~i_AS_O)
        o_A1 <= 1'b0;
end

// =========================================================================
// SSPBDAT register
// =========================================================================

reg [31:0] sspbdat;

always @(posedge i_CLK100 or negedge i_RST_n) begin
    if (~i_RST_n)
        sspbdat <= 32'b0;
    else if (sspbdat_wr && (i_PHASE == `PHASE_1))
        sspbdat <= i_MID[31:0];
end

// =========================================================================
// FLASH_ADDR register
// =========================================================================

reg [23:0] flash_addr;

always @(posedge i_CLK100 or negedge i_RST_n) begin
    if (~i_RST_n)
        flash_addr <= 24'b0;
    else if (flash_addr_wr & ~i_DS_n && (i_PHASE == `PHASE_1))
        flash_addr <= i_MID[23:0];
end

// =========================================================================
// VERSION / DEVICE
// =========================================================================

reg [8*4:1]  version_reg;
reg [8*14:1] device_txt;
reg [4:0]    device;

always @(posedge i_CLK100) begin
    if (~i_RST_n) begin
        version_reg <= `DEF_VERSION;
        device_txt  <= `DEVICE;

        case (device_txt)
            "10M02SCU169C8G": device <= 5'd2;
            "10M04SCU169C8G": device <= 5'd4;
            "10M16SCU169C8G": device <= 5'd16;
            default         : device <= 5'd0;
        endcase
    end
end

// =========================================================================
// DSP register
// =========================================================================

reg [7:0] dsp;

always @(posedge i_CLK100 or negedge i_RST_n) begin
    if (~i_RST_n)
        dsp <= 8'b0;
    else if (~dsp_rd_n && (i_PHASE == `PHASE_3))
        dsp <= i_DSP_DATA;
end

// =========================================================================
// Flash interface
// =========================================================================

wire [31:0] flash_data_out;
wire        flash_term;

registers_flash u_registers_flash(
    .i_CLK100          (i_CLK100        ),
    .i_PHASE           (i_PHASE         ),
    .i_RST_n           (i_RST_n         ),
    .i_DS_n            (i_DS_n          ),
    .i_AS_n            (i_AS_n          ),
    .i_FLASH_DATA_RD_n (flash_data_rd_n ),
    .i_FLASH_DATA_WR   (flash_data_wr   ),
    .i_FLASH_ADDR      (flash_addr      ),
    .i_FLASH_DATA_IN   (i_MID           ),
    .o_FLASH_DATA_OUT  (flash_data_out  ),
    .o_TERM            (flash_term      )
);

// =========================================================================
// Output mux
// =========================================================================

wire [8:0] mux_sel = {~wtc_rd_n, ~istr_rd_n, ~contr_rd_n, ~sspbdat_rd_n, ~version_rd_n,
                      ~dsp_rd_n, ~flash_data_rd_n, ~flash_addr_rd_n, ~dev_rd_n};

localparam WTC_SEL        = 9'b100000000;
localparam ISTR_SEL       = 9'b010000000;
localparam CONTR_SEL      = 9'b001000000;
localparam SSPBDAT_SEL    = 9'b000100000;
localparam VERSION_SEL    = 9'b000010000;
localparam DSP_SEL        = 9'b000001000;
localparam FLASH_DATA_SEL = 9'b000000100;
localparam FLASH_ADDR_SEL = 9'b000000010;
localparam DEV_SEL        = 9'b000000001;

always @(*) begin
    case (mux_sel)
        WTC_SEL        : o_REG_OD = 32'h00000000;
        ISTR_SEL       : o_REG_OD = {23'h0, istr_o};
        CONTR_SEL      : o_REG_OD = {23'h0, cntr_o};
        SSPBDAT_SEL    : o_REG_OD = sspbdat;
        VERSION_SEL    : o_REG_OD = version_reg;
        DSP_SEL        : o_REG_OD = {24'h0, dsp};
        FLASH_DATA_SEL : o_REG_OD = flash_data_out;
        FLASH_ADDR_SEL : o_REG_OD = {8'h0, flash_addr};
        DEV_SEL        : o_REG_OD = {27'h0, device};
        default        : o_REG_OD = 32'h00000000;
    endcase
end

assign o_REG_DSK_n = reg_dsk_int & ~flash_term;

// the "macro" to dump signals
`ifdef COCOTB_SIM1
initial begin
  $dumpfile ("registers.vcd");
  $dumpvars (0, registers);
  #1;
end
`endif

endmodule
