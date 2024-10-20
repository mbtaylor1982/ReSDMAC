//ReSDMAC © 2024 by Michael Taylor is licensed under Creative Commons Attribution-ShareAlike 4.0 International. To view a copy of this license, visit https://creativecommons.org/licenses/by-sa/4.0/

module fifo__full_empty_ctr(
    input CLK,
    input RST_,
    input INC,
    input DEC,

    output EMPTY,
    output FULL
);
reg [3:0] COUNT;

always @ (negedge CLK) begin
  if (~RST_)
    COUNT <= 4'b0000;
  else begin
    if (INC) begin
      if (COUNT == 4'b1000)
        COUNT <= 4'b0000;
      else
        COUNT <= COUNT + 1'b1;
    end

    if (DEC) begin
      if (COUNT == 4'b0000)
        COUNT <= 4'b1000;
      else
        COUNT <= COUNT - 1'b1;
    end
  end
end

assign FULL  = (COUNT == 4'b1000); //FULL when count = 8
assign EMPTY = (COUNT == 4'b0000); //EMPTY when count = 0

endmodule