//ReSDMAC © 2024 by Michael Taylor is licensed under Creative Commons Attribution-ShareAlike 4.0 International. To view a copy of this license, visit https://creativecommons.org/licenses/by-sa/4.0/

module fifo_3bit_cntr
#(
  parameter BITS = 3)
(
    input CLK,
    input ClKEN,
    input RST_,

    output reg [BITS-1:0] COUNT
);

always @(posedge CLK) begin
    if (~RST_)
        COUNT <= 0;
    else if(ClKEN)
      COUNT <= COUNT + 1'b1;
end

endmodule