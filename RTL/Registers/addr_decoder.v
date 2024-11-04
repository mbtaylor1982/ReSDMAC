//ReSDMAC © 2024 by Michael Taylor is licensed under Creative Commons Attribution-ShareAlike 4.0 International. To view a copy of this license, visit https://creativecommons.org/licenses/by-sa/4.0/

module addr_decoder(
  input [7:0] ADDR, // CPU address Bus
  input DMAC_,      // SDMAC Chip Select !SCSI from Fat Garry.
  input AS_,        // CPU Address Strobe.
  input RW,         // CPU Read Write Control Line.
  input DMADIR,     // DMADIR from bit from Control Register.

  output h_0C,      // RAMSEY ACR Address Decode
  output h_28,
  output WDREGREQ,  // WD33C93  Address Decode

  output CONTR_RD_,
  output ISTR_RD_,
  output WTC_RD_,
  output SSPBDAT_RD_,
  output VERSION_RD_,
  output DSP_RD_,
  output FLASH_ADDR_RD_,
  output FLASH_DATA_RD_,

  output CONTR_WR,
  output ACR_WR,
  output SSPBDAT_WR,
  output VERSION_WR,
  output FLASH_ADDR_WR,
  output FLASH_DATA_WR,


  output ST_DMA,
  output SP_DMA,
  output CLR_INT,
  output FLUSH_
);

wire h_04;
wire h_08;
wire h_10;
wire h_14;
wire h_18;
wire h_1C;
wire h_20;
wire h_24;
//wire h_28;
//wire h_2C;
wire h_3C;
wire h_5C;
wire h_58;


wire ADDR_VALID;
assign ADDR_VALID = ~(DMAC_ | AS_);

assign h_04 = ADDR_VALID & (ADDR == 8'h04);
assign h_08 = ADDR_VALID & (ADDR == 8'h08);
assign h_0C = ADDR_VALID & (ADDR == 8'h0C);
assign h_10 = ADDR_VALID & (ADDR == 8'h10);
assign h_14 = ADDR_VALID & (ADDR == 8'h14);
assign h_18 = ADDR_VALID & (ADDR == 8'h18);
assign h_1C = ADDR_VALID & (ADDR == 8'h1C);
assign h_20 = ADDR_VALID & (ADDR == 8'h20);
assign h_24 = ADDR_VALID & (ADDR == 8'h24);
assign h_28 = ADDR_VALID & (ADDR == 8'h28);
//assign h_2C = ADDR_VALID & (ADDR == 8'h2C);
assign h_3C = ADDR_VALID & (ADDR == 8'h3C);
assign h_5C = ADDR_VALID & (ADDR == 8'h5C);
assign h_58 = ADDR_VALID & (ADDR == 8'h58);

assign WDREGREQ = ADDR_VALID & (ADDR[7:4] == 4'h4);

//Register Read and Write Strobes
assign WTC_RD_        = ~(h_04 & RW);
assign CONTR_RD_      = ~(h_08 & RW);
assign ISTR_RD_       = ~(h_1C & RW);
assign SSPBDAT_RD_    = ~(h_58 & RW);
assign VERSION_RD_    = ~(h_20 & RW);
assign DSP_RD_        = ~(h_5C & RW);
assign FLASH_ADDR_RD_ = ~(h_24 & RW);
assign FLASH_DATA_RD_ = ~(h_28 & RW);

assign CONTR_WR       = (h_08 & ~RW);
assign ACR_WR         = (h_0C & ~RW);
assign SSPBDAT_WR     = (h_58 & ~RW);
assign VERSION_WR     = (h_20 & ~RW);
assign FLASH_ADDR_WR  = (h_24 & ~RW);
assign FLASH_DATA_WR  = (h_28 & ~RW);

//action strobes
assign ST_DMA   = h_10;
assign SP_DMA   = h_3C;
assign CLR_INT  = h_18;
assign FLUSH_   = ~h_14;

endmodule
