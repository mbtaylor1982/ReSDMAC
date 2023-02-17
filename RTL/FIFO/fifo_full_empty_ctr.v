 /*
// 
// Copyright (C) 2022  Mike Taylor
// This file is part of RE-SDMAC <https://github.com/mbtaylor1982/RE-SDMAC>.
// 
// RE-SDMAC is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// RE-SDMAC is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with dogtag.  If not, see <http://www.gnu.org/licenses/>.
 */
module fifo__full_empty_ctr(
    input INCFIFO,
    input DECFIFO,
    input RST_FIFO_,    

    output reg FIFOEMPTY,
    output reg FIFOFULL
);
reg [7:0] UP;
reg [6:0] DOWN;

wire FIFOEMPTY_RST;
wire FIFOFULL_RST;
wire UP_RST;

always @(posedge INCFIFO, negedge UP_RST)
begin
  if (UP_RST == 0)
    UP <= 8'b00000000;
  else
  begin
    UP[0] <= 1'b1;
    UP[1] <= (UP[0] | DOWN[6]);
    UP[2] <= (UP[1] | DOWN[5]);
    UP[3] <= (UP[2] | DOWN[4]);
    UP[4] <= (UP[3] | DOWN[3]);
    UP[5] <= (UP[4] | DOWN[2]);
    UP[6] <= (UP[5] | DOWN[1]);
    UP[7] <= (UP[6] | DOWN[0]);
    FIFOFULL <= (UP[6] | DOWN[0]); 
  end
end


always @(posedge DECFIFO, negedge RST_FIFO_)
begin
  if (RST_FIFO_ == 0)
  begin
    DOWN <= 7'b0000000;
    FIFOEMPTY <= 1'b1;
  end
  else
  begin
    DOWN[0] <= UP[7];
    DOWN[1] <= (UP[6] | DOWN[0]); 
    DOWN[2] <= (UP[5] | DOWN[1]);
    DOWN[3] <= (UP[4] | DOWN[2]);
    DOWN[4] <= (UP[3] | DOWN[3]);
    DOWN[5] <= (UP[2] | DOWN[4]);
    DOWN[6] <= (UP[1] | DOWN[5]);
    FIFOEMPTY <= ~( (UP[1] | DOWN[5]) |(UP[2] | DOWN[4])|(UP[3] | DOWN[3])|(UP[4] | DOWN[2])|(UP[5] | DOWN[1])|(UP[6] | DOWN[0])| UP[7]);
  end
end

always @(negedge FIFOEMPTY_RST)
begin
  if (FIFOEMPTY_RST == 0) FIFOEMPTY <= 1'b0;
end

always @(negedge FIFOFULL_RST)
begin
  if (FIFOFULL_RST == 0) FIFOFULL <= 1'b0;
end

assign FIFOEMPTY_RST = ~(RST_FIFO_ & FIFOEMPTY & INCFIFO);
assign FIFOFULL_RST = ~(~RST_FIFO_| ~(~FIFOFULL|~DECFIFO));
assign UP_RST = (RST_FIFO_& ~((UP[0]|UP[1]|UP[2]|UP[3]|UP[4]|UP[5]|UP[6]|UP[7]) & DECFIFO));
/*
reg [2:0] COUNT;
wire clk;

always @(posedge clk or negedge RST_FIFO_) begin
    if (RST_FIFO_ == 1'b0)
    begin
        COUNT <= 3'b000;
        FIFOEMPTY <= 1'b1;
        FIFOFULL <= 1'b0;
    end
    else if (INCFIFO)
    begin
      if (COUNT == 3'b111) 
        FIFOFULL <= 1'b1;
      else
      begin
        COUNT <=  COUNT + 1'b1;
        FIFOEMPTY <= 1'b0;
      end
    end 
    else if (DECFIFO)
    begin
        if (COUNT == 3'b000) 
            FIFOEMPTY <= 1'b1;
        else
        begin
            COUNT <=  COUNT -1'b1;
            FIFOFULL <= 1'b0;
        end
    end 
end

assign clk = (INCFIFO | DECFIFO);
*/
endmodule