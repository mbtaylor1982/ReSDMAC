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

module Asynch_Read_Cycle_FSM(RW, _AS, _DS, _RST, Clk, ADDR);

localparam IDLE = 3'b111;
localparam S0 = 3'b000;
localparam S1 = 3'b001;
localparam S2 = 3'b010;
localparam S3 = 3'b011;
localparam S4 = 3'b100;
localparam S5 = 3'b101;  

input Clk, _RST;
output _AS, _DS, RW;
output [31:0] ADDR;

reg [3:0] State = IDLE;

reg _AS, _DS, RW;
reg [31:0] ADDR;

  
always @(Clk or negedge _RST)
begin
    if( _RST == 1'b0 ) begin
        State <= IDLE;
    end else begin
        case(State)
            IDLE: begin 
                _AS <= 1'b1;
                _DS <= 1'b1;
                ADDR <= 32'h00000000;
                RW <= 1'b0;
                State <= S0;
            end
            S0: begin
                ADDR <= 32'h00DD000;
                RW <= 1'b1;
                _AS <= 1'b0;
                State <= S1;
            end
            S1: begin
                _DS <= 1'b0;
                State <= S2;
            end
            S2: begin
                State <= S3;
            end
            S3: begin
                State <= S4;
            end
            S4: begin
                //Latch Incoming Data at end of S4.
                State <= S5;    
            end
            S5: begin
              State <= IDLE;
              _AS <= 1'b1;
              _DS <= 1'b1;
            end
        endcase
   end
end

endmodule