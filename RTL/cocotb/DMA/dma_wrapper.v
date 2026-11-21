`timescale 1ns/100ps

// cocotb-test defines this globally. The legacy register test uses it to
// synthesize an ACR acknowledgement inside SDMAC. Use the hardware branch:
// the real board's 8-bit Ramsey port owns ACR termination instead.
`undef COCOTB_SIM

// Board-side drivers only. No force, hierarchical deposits, or sequencer hooks.
module dma_wrapper;
    reg clk = 0;
    reg reset_n = 0;
    reg cpu_enable = 0;
    reg cpu_as_n = 1, cpu_ds_n = 1, cpu_rw = 1;
    reg cpu_data_enable = 0;
    reg [31:0] cpu_data = 0, cpu_address = 0;
    reg [31:0] ramsey_address = 0;
    reg memory_enable = 0;
    reg [31:0] memory_data = 0;
    reg [31:0] memory_mask = 32'hffffffff;
    reg [1:0] response_n = 2'b11;
    reg sterm_n = 1, grant_n = 1, berr_n = 1;
    reg other_owner = 0;
    reg peripheral_enable = 0;
    reg [7:0] peripheral_data = 0;
    reg dreq_n = 1;
    tri1 [31:0] data_bus;
    tri1 [15:0] peripheral_bus;
    tri1 as_n, ds_n, rw, bgack_n;
    tri1 [1:0] dsack_n;
    wire br_n, dmaen_n, siz1, dack_n, ior_n, iow_n, css_n, int_n;
    wire reset_input = reset_n;
    wire sterm_input = sterm_n;
    wire grant_input = grant_n;
    wire berr_input = berr_n;
    wire dreq_input = dreq_n;
    wire [31:0] address = dmaen_n ? cpu_address : ramsey_address;
    // Fat Gary's SDMAC select; unlike the old tests this follows the address.
    wire cs_n = !(address[31:14] == (32'h00dd0000 >> 14));

    assign as_n = cpu_enable ? cpu_as_n : 1'bz;
    assign ds_n = cpu_enable ? cpu_ds_n : 1'bz;
    assign rw = cpu_enable ? cpu_rw : 1'bz;
    assign data_bus = cpu_data_enable ? cpu_data : 32'bz;
    genvar bit_index;
    generate for (bit_index = 0; bit_index < 32; bit_index = bit_index + 1) begin : memory_driver
        assign data_bus[bit_index] = (memory_enable && memory_mask[bit_index]) ? memory_data[bit_index] : 1'bz;
    end endgenerate
    assign dsack_n[0] = response_n[0] ? 1'bz : 1'b0;
    assign dsack_n[1] = response_n[1] ? 1'bz : 1'b0;
    assign bgack_n = other_owner ? 1'b0 : 1'bz;
    // Only PD[7:0] connects to the WD chip on the stock A3000.
    assign peripheral_bus = peripheral_enable ? {8'bz, peripheral_data} : 16'bz;

    RESDMAC dut (
        .SCLK(clk), ._RST(reset_input), ._CS(cs_n), .ADDR(address[6:2]),
        .DATA_IO(data_bus), .R_W_IO(rw), ._AS_IO(as_n), ._DS_IO(ds_n),
        ._DSACK_IO(dsack_n), ._STERM(sterm_input), ._BERR(berr_input),
        ._BR(br_n), ._BG(grant_input), ._BGACK_IO(bgack_n),
        ._DMAEN(dmaen_n), ._SIZ1(siz1), .PD_PORT(peripheral_bus),
        ._DREQ(dreq_input), ._DACK(dack_n), ._IOR(ior_n), ._IOW(iow_n),
        ._CSS(css_n), ._INT(int_n), .INTA(1'b0), .IORDY(1'b1),
        .INTB(1'b1), .JP(1'b0), .PIN_D8(1'b0), .INC_ADD(1'b0),
        .CSX1(1'b0), .CSX0(1'b0)
    );

    initial begin
        $dumpfile("dma.vcd");
        $dumpvars(0, dma_wrapper);
    end
endmodule
