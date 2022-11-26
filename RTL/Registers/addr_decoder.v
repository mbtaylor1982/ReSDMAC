 
module addr_decoder(
  input [7:0] ADDR, // CPU address Bus
  input DMAC_,      // SDMAC Chip Select !SCSI from Fat Garry.
  input AS_,        // CPU Address Strobe.
  
  output h_00,
  output h_04,
  output h_08,
  output h_0C,
  output h_10;
  output h_14;
  output h_18;
  output h_1C;
  output h_3C;
  output WDREGREQ,
);

wire ADDR_VALID;
assign ADDR_VALID = ~(DMAC_ | AS_);

assign h_00 = ADDR_VALID & (ADDR == 8'h00);
assign h_04 = ADDR_VALID & (ADDR == 8'h04);
assign h_08 = ADDR_VALID & (ADDR == 8'h08);
assign h_0C = ADDR_VALID & (ADDR == 8'h0C);
assign h_10 = ADDR_VALID & (ADDR == 8'h10);
assign h_14 = ADDR_VALID & (ADDR == 8'h14);
assign h_18 = ADDR_VALID & (ADDR == 8'h18);
assign h_1C = ADDR_VALID & (ADDR == 8'h1C);
assign h_3C = ADDR_VALID & (ADDR == 8'h3C);
assign WDREGREQ = ADDR_VALID & (ADDR >= 8'h40);

endmodule
