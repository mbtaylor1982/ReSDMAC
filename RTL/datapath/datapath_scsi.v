//ReSDMAC © 2024 by Michael Taylor is licensed under Creative Commons Attribution-ShareAlike 4.0 International. To view a copy of this license, visit https://creativecommons.org/licenses/by-sa/4.0/

module datapath_scsi (
    input i_CLK100,
    input [15:0] i_SCSI_DATA,
    output [15:0] o_SCSI_DATA,

    input [31:0] i_FIFO_RD_DATA,
    input [31:0] i_CPU_LATCH,
    input i_CPU2S,
    input i_S2CPU,
    input i_S2F,
    input i_F2S,
    input i_A3,
    input [1:0] i_BYTE_PTR,
    input i_LS2CPU,

    output [31:0] o_SCSI_RX_CPU,
    output [31:0] o_SCSI_RX_FIFO,
    output o_SCSI_OE
);

// 2->4 one-hot decoder (byte lane select for FIFO->SCSI)
wire f2s_uud = (i_BYTE_PTR == 2'd0) & i_F2S;
wire f2s_umd = (i_BYTE_PTR == 2'd1) & i_F2S;
wire f2s_lmd = (i_BYTE_PTR == 2'd2) & i_F2S;
wire f2s_lld = (i_BYTE_PTR == 2'd3) & i_F2S;

wire [5:0] mux_sel = {(i_CPU2S & ~i_A3), (i_CPU2S & i_A3), f2s_uud, f2s_umd, f2s_lmd, f2s_lld};

// 6-input byte MUX (TX byte lane selection)
reg [7:0] scsi_tx;
always @(*) begin
    case (mux_sel)
        6'b000001 : scsi_tx = i_FIFO_RD_DATA[7:0];
        6'b000010 : scsi_tx = i_FIFO_RD_DATA[15:8];
        6'b000100 : scsi_tx = i_FIFO_RD_DATA[23:16];
        6'b001000 : scsi_tx = i_FIFO_RD_DATA[31:24];
        6'b010000 : scsi_tx = i_CPU_LATCH[23:16];
        6'b100000 : scsi_tx = i_CPU_LATCH[7:0];
        default   : scsi_tx = 8'h00;
    endcase
end

wire scsi_in = (i_S2F | i_S2CPU);
wire [7:0] scsi_rx = scsi_in ? i_SCSI_DATA[7:0] : 8'h00;

reg [7:0] scsi_rx_latch;
reg [7:0] scsi_tx_latch;

assign o_SCSI_OE   = (i_F2S | i_CPU2S);
assign o_SCSI_DATA = o_SCSI_OE ? {scsi_tx_latch, scsi_tx_latch} : 16'h0000;

// RX latch
always @(posedge i_CLK100) begin
    if (~i_S2CPU)
        scsi_rx_latch <= 8'h00;
    else if (~i_LS2CPU)
        scsi_rx_latch <= scsi_rx;
end

// TX latch — negedge gives half-cycle setup margin to SCSI bus
always @(negedge i_CLK100) begin
    scsi_tx_latch <= scsi_tx;
end

assign o_SCSI_RX_CPU  = {8'h00, scsi_rx_latch, 8'h00, scsi_rx_latch};
assign o_SCSI_RX_FIFO = {scsi_rx, scsi_rx, scsi_rx, scsi_rx};

endmodule
