`timescale 1ns/100ps

// Isolate the socket data-driver contract from the DMA sequencer. Normal
// end-to-end tests must drive the real bus rather than these internal controls.
module bus_wrapper;
    reg sclk = 0;
    reg reset_n = 0;
    reg owner = 0;
    reg dma_to_memory = 0;
    reg cs_n = 1;
    reg acr_select = 0;
    reg external_enable = 0;
    reg external_read = 1;
    reg [31:0] external_data = 0;
    reg [31:0] device_data = 32'h55555555;
    tri1 [31:0] data_bus;
    tri1 rw;
    tri1 as_n, ds_n, bgack_n;
    tri1 [1:0] dsack_n;
    tri1 [15:0] peripheral_bus;
    wire cs_input = cs_n;
    wire reset_input = reset_n;

    assign data_bus = external_enable ? external_data : 32'hzzzzzzzz;
    assign rw = owner ? 1'bz : external_read;

    RESDMAC dut (
        .SCLK(sclk), ._RST(reset_input), ._CS(cs_input), .ADDR(5'b0),
        .DATA_IO(data_bus), .R_W_IO(rw), ._AS_IO(as_n), ._DS_IO(ds_n),
        ._DSACK_IO(dsack_n), ._BGACK_IO(bgack_n), .PD_PORT(peripheral_bus),
        ._BERR(1'b1), ._BG(1'b1), ._STERM(1'b1), ._DREQ(1'b1),
        .INTA(1'b0), .IORDY(1'b1), .INTB(1'b1), .JP(1'b0),
        .PIN_D8(1'b0), .INC_ADD(1'b0), .CSX1(1'b0), .CSX0(1'b0)
    );

    initial begin
        force dut.OWN = owner;
        force dut.DMADIR = dma_to_memory;
        force dut.DATA_O = device_data;
        force dut.H_0C = acr_select;
    end
endmodule
