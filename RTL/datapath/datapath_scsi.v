//ReSDMAC © 2024 by Michael Taylor is licensed under Creative Commons Attribution-ShareAlike 4.0 International. To view a copy of this license, visit https://creativecommons.org/licenses/by-sa/4.0/

`ifdef __ICARUS__ 
  `include "datapath_24dec.v"
  `include "datapath_8b_MUX.v"
`endif

module datapath_scsi (
    input CLK, CLK90, CLK135,
    input [15:0] SCSI_DATA_IN,
    output [15:0] SCSI_DATA_OUT,
    
    input [31:0] FIFO_OD,
    input [31:0] CPU_OD,
    input CPU2S,
    input S2CPU,
    input S2F,
    input F2S,
    input A3,
    input BO0,
    input BO1,
    input LS2CPU,

    output [31:0] MOD_SCSI,
    output [31:0] SCSI_OD,
    output SCSI_OUT
);

wire F2S_UUD;
wire F2S_UMD;
wire F2S_LMD;
wire F2S_LLD;

//wire SCSI_OUT;
wire SCSI_IN;

wire [7:0] SCSI_DATA_RX;
wire [7:0] SCSI_DATA_TX;

reg [7:0] SCSI_DATA__RX_LATCHED;
reg [7:0] SCSI_DATA__TX_LATCHED;

assign SCSI_OUT = (F2S | CPU2S);
assign SCSI_IN  = (S2F | S2CPU);

datapath_24dec u_datapath_24dec(
    .A  (BO1     ),
    .B  (BO0     ),
    .En (F2S     ),
    .D0 (F2S_UUD ),
    .D1 (F2S_UMD ),
    .D2 (F2S_LMD ),
    .D3 (F2S_LLD )
);

wire [5:0] MuxSelect;
assign MuxSelect = {(CPU2S & ~A3), (CPU2S & A3), F2S_UUD, F2S_UMD, F2S_LMD, F2S_LLD};

datapath_8b_MUX u_datapath_8b_MUX(
    //inputs
    .A (FIFO_OD[7:0]),
    .B (FIFO_OD[15:8]),
    .C (FIFO_OD[23:16]),
    .D (FIFO_OD[31:24]),
    .E (CPU_OD[23:16]),
    .F (CPU_OD[7:0]),
    .S (MuxSelect),//selects
    .Z (SCSI_DATA_TX) //output
);

assign SCSI_DATA_OUT = SCSI_OUT ? {SCSI_DATA__TX_LATCHED, SCSI_DATA__TX_LATCHED} : 16'h0000;
assign SCSI_DATA_RX = SCSI_IN ? SCSI_DATA_IN[7:0] : 8'h00;

always @(negedge CLK, negedge S2CPU) begin
    if (~S2CPU)
        SCSI_DATA__RX_LATCHED <= 8'h00;
    else if (~LS2CPU)
        SCSI_DATA__RX_LATCHED <= SCSI_DATA_RX;
end

always @(posedge CLK135) begin
    SCSI_DATA__TX_LATCHED <= SCSI_DATA_TX;
end

assign MOD_SCSI = {8'h00 , SCSI_DATA__RX_LATCHED, 8'h00, SCSI_DATA__RX_LATCHED};
assign SCSI_OD = {SCSI_DATA_RX, SCSI_DATA_RX, SCSI_DATA_RX, SCSI_DATA_RX};

endmodule