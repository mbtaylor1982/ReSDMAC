//ReSDMAC © 2024 by Michael Taylor is licensed under Creative Commons Attribution-ShareAlike 4.0 International. To view a copy of this license, visit https://creativecommons.org/licenses/by-sa/4.0/

`ifdef __ICARUS__
    `include "datapath_scsi.v"
`endif

module datapath (
    input i_CLK100,
    input [31:0] i_CPU_DATA,

    input [15:0] i_SCSI_PORT,
    output [15:0] o_SCSI_PORT,

    input [31:0] i_FIFO_RD_DATA,
    input [31:0] i_REG_DATA,

    input i_PAS,

    input i_BRIDGE_IN,
    input i_BRIDGE_OUT,

    input i_DIEH,
    input i_DIEL,

    input i_LS2CPU,
    input i_S2CPU,

    input i_S2F,

    input i_F2S,
    input i_CPU2S,

    input [1:0] i_BYTE_PTR,
    input i_A3,

    input i_F2CPU_LO,
    input i_F2CPU_HI,

    input i_DS_n,

    output [31:0] o_REG_DATA,
    output [31:0] o_FIFO_WR_DATA,
    output [31:0] o_CPU_DATA,
    output o_SCSI_OE
);

wire [31:0] scsi_rx_cpu;
wire [31:0] mux_data;
wire [31:0] scsi_rx_fifo;

// --- CPU bus input latching ---
reg [15:0] cpu_hi_latch;

always @(posedge i_CLK100) begin
    if (~i_DS_n)
        cpu_hi_latch <= i_CPU_DATA[31:16];
end

wire [15:0] latch_hi = (i_DIEH | i_CPU2S) ? i_CPU_DATA[31:16] : 16'h0000;
wire [15:0] latch_lo = (i_DIEL | i_CPU2S) ? i_CPU_DATA[15:0]  : (i_BRIDGE_IN ? cpu_hi_latch : 16'h0000);

wire [31:0] cpu_latch = {latch_hi, latch_lo};
assign o_REG_DATA = i_CPU_DATA;

// --- FIFO output latching ---
reg [15:0] fifo_lo_latch;
reg [15:0] fifo_hi_latch;

always @(posedge i_CLK100) begin
    if (i_PAS) begin
        fifo_lo_latch <= i_FIFO_RD_DATA[15:0];
        fifo_hi_latch <= i_FIFO_RD_DATA[31:16];
    end
end

wire [15:0] out_lo = i_F2CPU_LO ? fifo_lo_latch : mux_data[15:0];
wire [15:0] out_hi = i_F2CPU_HI ? fifo_hi_latch : (i_BRIDGE_OUT ? fifo_lo_latch : mux_data[31:16]);
assign o_CPU_DATA = i_S2CPU ? mux_data : {out_hi, out_lo};

// --- Routing ---
assign mux_data       = i_S2CPU ? scsi_rx_cpu : i_REG_DATA;
assign o_FIFO_WR_DATA = i_S2F   ? scsi_rx_fifo : cpu_latch;

datapath_scsi u_datapath_scsi(
    .i_CLK100       (i_CLK100       ),
    .i_SCSI_DATA    (i_SCSI_PORT    ),
    .o_SCSI_DATA    (o_SCSI_PORT    ),
    .o_SCSI_RX_FIFO (scsi_rx_fifo   ),
    .i_FIFO_RD_DATA (i_FIFO_RD_DATA ),
    .i_CPU_LATCH    (cpu_latch      ),
    .i_CPU2S        (i_CPU2S        ),
    .i_S2CPU        (i_S2CPU        ),
    .i_S2F          (i_S2F          ),
    .i_F2S          (i_F2S          ),
    .i_A3           (i_A3           ),
    .i_BYTE_PTR     (i_BYTE_PTR     ),
    .i_LS2CPU       (i_LS2CPU       ),
    .o_SCSI_RX_CPU  (scsi_rx_cpu    ),
    .o_SCSI_OE      (o_SCSI_OE      )
);

endmodule
