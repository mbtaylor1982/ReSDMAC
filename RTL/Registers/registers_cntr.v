//ReSDMAC © 2024 by Michael Taylor is licensed under Creative Commons Attribution-ShareAlike 4.0 International. To view a copy of this license, visit https://creativecommons.org/licenses/by-sa/4.0/

`include "../phase_defs.vh"

module registers_cntr(
  input CLK100,         // 100MHz main clock
  input [1:0] phase,    // Phase counter value
  input RESET_,
  input CONTR_WR,
  input ST_DMA,
  input SP_DMA,
  input [8:0] MID,

  output reg [8:0] CNTR_O,
  output reg INTENA,
  output reg PRESET,
  output reg DMADIR,
  output reg DMAENA
);

always @(posedge CLK100 or negedge RESET_) begin
    if (~RESET_) begin
        DMADIR <= 1'b0;
        INTENA <= 1'b0;
        PRESET <= 1'b0;
		    DMAENA <= 1'b0;
    end
    else if(phase == `PHASE_1) begin
      if (CONTR_WR) begin
          DMADIR <= MID[1];
          INTENA <= MID[2];
          PRESET <= MID[4];
      end
      if (ST_DMA )
          DMAENA <= 1'b1;
      if (SP_DMA )
          DMAENA <= 1'b0;
    end
end

always @(*) begin
  CNTR_O <= {DMAENA, 1'b0, 1'b0, 1'b0, PRESET, 1'b0, INTENA, DMADIR, 1'b0};
end

endmodule