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

module CPU_SM(
    output PAS,
    output PDS,
    output BGACK,
    output BREQ,
    input aBGRANT_,
    output SIZE1,
    input aRESET_,
    input STERM_,
    input DSACK0_,
    input DSACK1_,
    input DSACK,
    input aCYCLEDONE_,
    input CLK,
    input DMADIR,
    input A1,
    output F2CPUL,
    output F2CPUH,
    output BRIDGEIN,
    output BRIDGEOUT,
    output DIEH,
    output DIEL,
    input LASTWORD,
    input BOEQ3,
    input FIFOFULL,
    input FIFOEMPTY,
    input RDFIFO_,
    output DECFIFO,
    input RIFIFO_,
    output INCFIFO,
    output INCNO,
    output INCNI,
    input aDREQ_,
    input aFLUSHFIFO,
    output STOPFLUSH,
    input aDMAENA,
    output PLLW,
    output PLHW
);

reg [5:0] state = S0;
reg CCRESET_ = 1'b1;

wire nCLK; // CPUCLK Inverted
wire BCLK; // CPUCLK inverted 4 times for delay.
wire BBCLK; // CPUCLK Inverted 6 time for delay.


//clocked reset
always @(posedge nCLK) begin
    CCRESET_ <= aRESET_;   
end

//clocked inputs.
always @(posedge  BBCLK) begin

end

//State Machine
always @(posedge BCLK, negedge CCRESET_) begin
 if(CCRESET_ == 1'b0) 
        begin
            state <= 5'b00000;
        end
    else
        begin
            
        end    
end

assign nCLK = !CLK;
assign BCLK = CLK; // may need to change this to add delays
assign BBCLK = CLK; // may need to change this to add delays


endmodule