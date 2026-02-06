//ReSDMAC © 2024 by Michael Taylor is licensed under Creative Commons Attribution-ShareAlike 4.0 International. To view a copy of this license, visit https://creativecommons.org/licenses/by-sa/4.0/

`include "../phase_defs.vh"

module registers_istr(
  input CLK100,         // 100MHz main clock
  input [1:0] phase,    // Phase counter value
  input RESET_,
  input FIFOEMPTY,
  input FIFOFULL,
  input CLR_INT,
  input ISTR_RD_,
  input INTENA,
  input INTA_I,

  output reg [8:0] ISTR_O,
  output reg INT_O_
);

reg INT_F;
reg INTS;
reg E_INT;
reg INT_P;
reg FF;
reg FE;

wire CLR_INT_;
assign CLR_INT_ = ~CLR_INT;

always @(posedge CLK100 or negedge RESET_) begin
  if (~RESET_) begin
    INT_F   <= 1'b0;
    INTS    <= 1'b0;
    E_INT   <= 1'b0;
    INT_P   <= 1'b0;
    FF      <= 1'b0;
    FE      <= 1'b1;
  end
  else if (phase == `PHASE_1) begin
    if (~CLR_INT_) begin
      INT_F   <= 1'b0;
      INTS    <= 1'b0;
      E_INT   <= 1'b0;
      INT_P   <= 1'b0;
    end
    if (~ISTR_RD_) begin
      INT_F   <= INTA_I;
      INTS    <= INTA_I;
      E_INT   <= INTA_I;
      INT_P   <= INTENA ? INTA_I: 1'b0;
      FF      <= FIFOFULL;
      FE      <= FIFOEMPTY;
    end
  end
end

always @(*) begin
	ISTR_O <= {1'b0, INT_F, INTS, E_INT, INT_P , 1'b0, 1'b0, FF, FE};
	INT_O_ <= INTENA ? ~INTA_I : 1'b1;
end

endmodule