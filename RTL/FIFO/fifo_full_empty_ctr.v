/*ReSDMAC © 2024 by Michael Taylor is licensed under Creative Commons Attribution-ShareAlike 4.0 International. To view a copy of this license, visit https://creativecommons.org/licenses/by-sa/4.0/*/

module fifo__full_empty_ctr(
    input CLK, CLK135,
    input INCFIFO,
    input DECFIFO,
    input RST_FIFO_,

    output reg FIFOEMPTY,
    output reg FIFOFULL
);
reg [7:0] UP;
reg [6:0] DOWN;

always @(posedge CLK, negedge RST_FIFO_)
begin
  if (~RST_FIFO_)
    UP <= 8'h0;
  else if (DECFIFO) begin
    if (UP != 8'h0)
      UP <= 8'h0;
  end
  else if (INCFIFO)
  begin
    UP[0] <= 1'b1;
    UP[1] <= (UP[0] | DOWN[6]);
    UP[2] <= (UP[1] | DOWN[5]);
    UP[3] <= (UP[2] | DOWN[4]);
    UP[4] <= (UP[3] | DOWN[3]);
    UP[5] <= (UP[4] | DOWN[2]);
    UP[6] <= (UP[5] | DOWN[1]);
    UP[7] <= (UP[6] | DOWN[0]);
  end
  
end


always @(posedge CLK, negedge RST_FIFO_)
begin
  if (~RST_FIFO_)
  begin
    DOWN <= 7'b0000000;
  end
  else if (DECFIFO)
  begin
    DOWN[0] <= UP[7];
    DOWN[1] <= (UP[6] | DOWN[0]);
    DOWN[2] <= (UP[5] | DOWN[1]);
    DOWN[3] <= (UP[4] | DOWN[2]);
    DOWN[4] <= (UP[3] | DOWN[3]);
    DOWN[5] <= (UP[2] | DOWN[4]);
    DOWN[6] <= (UP[1] | DOWN[5]);
	end
end

always @(negedge CLK, negedge RST_FIFO_)
begin
  if (~RST_FIFO_)
    FIFOEMPTY <= 1'b1;
  else if (INCFIFO & FIFOEMPTY)
    FIFOEMPTY <= 1'b0;
  else if (DECFIFO)
		FIFOEMPTY <=  ~((UP[1] | DOWN[5]) | (UP[2] | DOWN[4]) | (UP[3] | DOWN[3]) | (UP[4] | DOWN[2]) | (UP[5] | DOWN[1]) | (UP[6] | DOWN[0]) | UP[7]);
end

always @(negedge CLK, negedge RST_FIFO_)
begin
	if (~RST_FIFO_)
		FIFOFULL <= 1'b0;
  else if (DECFIFO & FIFOFULL)
    FIFOFULL <= 1'b0;
	else if (INCFIFO)
		FIFOFULL <= (UP[6] | DOWN[0]);
end

endmodule