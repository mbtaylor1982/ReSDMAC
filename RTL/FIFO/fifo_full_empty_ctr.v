//ReSDMAC © 2024 by Michael Taylor is licensed under Creative Commons Attribution-ShareAlike 4.0 International. To view a copy of this license, visit https://creativecommons.org/licenses/by-sa/4.0/

module fifo__full_empty_ctr
#(
    parameter BITS = 4,
    parameter MAX = 8)
(
    input CLK,
    input RST_,
    input INC,
    input DEC,

    output EMPTY,
    output FULL
);
reg [BITS-1:0] COUNT;

always @ (negedge CLK) begin
  if (~RST_)
    COUNT <= 0;
  else begin
    if (INC) begin
      if (COUNT == MAX)
        COUNT <= 0;
      else
        COUNT <= COUNT + 1'b1;
    end

    if (DEC) begin
      if (COUNT == 0)
        COUNT <= MAX;
      else
        COUNT <= COUNT - 1'b1;
    end
  end
end

assign FULL  = (COUNT == MAX); //FULL when count = MAX
assign EMPTY = (COUNT == 0); //EMPTY when count = 0

endmodule