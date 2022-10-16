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

module registers(CLK,
                ADDR,
                _CS,
                _AS,
                _DS, 
                _RST, 
                R_W,
                DIN, 
                DOUT,
                _DSACK);


input CLK;
input [4:0] ADDR;   // CPU Address Bus, bits are actually [6:2]
input _CS;          // Registers Enable
input _AS;          // CPU Address Strobe.
input _DS;          // CPU Data Strobe.
input _RST;         // CPU Reset line;
input [31:0] DIN;   // CPU Data Bus
input R_W;          // CPU read write signal

output [31:0] DOUT;
output [1:0] _DSACK;

wire DataStrobe = _DS | _CS | _AS;

reg [31:0] DOUT;
reg [1:0] _DSACK = 2'b11;

//Registers
reg [1:0] DAWR;     //Data Acknowledge Width
reg [23:0] WTC;     //Word Transfer Count
reg [5:0] CNTR;     //Control Register
reg ST_DMA;         //Start DMA 
reg FLUSH;          //Flush FIFO
reg CLR_INT;        //Clear Interrupts
reg [8:0] ISTR;     //Interrupt Status Register
reg SP_DMA;         //Stop DMA 

//reg [31:0] TEST; // aditional 32 bit register for testing read write cycles.

//DAWR $00DD0000 (WRITE ONLY)
//localparam DAWR_RD = {5'h0,1'b1};
localparam DAWR_WR = {5'h0,1'b0};

//WTC $00DD0004
localparam WTC_RD = {5'h1,1'b1};
localparam WTC_WR = {5'h1,1'b0};

//CNTR $00DD0008
localparam CNTR_RD = {5'h2,1'b1};
localparam CNTR_WR = {5'h2,1'b0};

//ST_DMA $00DD0010
localparam ST_DMA_RD = {5'h4,1'b1};
localparam ST_DMA_WR = {5'h4,1'b0};

//FLUSH $00DD0014
localparam FLUSH_RD = {5'h5,1'b1};
localparam FLUSH_WR = {5'h5,1'b0};

//CINT $00DD0018
localparam CINT_RD = {5'h6,1'b1};
localparam CINT_WR = {5'h6,1'b0};

//ISTR $00DD001C (READ ONLY)
localparam ISTR_RD = {5'h7,1'b1};
//localparam ISTR_WR = {5'h7,1'b0};

//TEST $00DD0020
//localparam TEST_RD = {5'h8,1'b1};
//localparam TEST_WR = {5'h8,1'b0};

//SP_DMA $00DD003C
localparam SP_DMA_RD = {5'hf,1'b1};
localparam SP_DMA_WR = {5'hf,1'b0};

always @ (negedge DataStrobe or negedge _RST) begin
        
    if (!_RST) begin
        DAWR    <= 2'b00;
        WTC     <= 24'h0;
        CNTR    <= 6'h0;
        ST_DMA  <= 1'h0;
        FLUSH   <= 1'h0;
        CLR_INT <= 1'h0;
        ISTR    <= 9'h0;
        SP_DMA  <= 1'h0;
        //TEST    <= 32'h55555555;
        DOUT    <= 32'hz;
        _DSACK  <= 2'bzz;
    end else begin

        case ({ADDR, R_W})
            //DAWR_RD : DOUT      <= {30'b0,DAWR};
            DAWR_WR : DAWR        <= DIN[1:0];
            
            WTC_RD  : DOUT        <= {8'b0, WTC};
            WTC_WR  : WTC         <= DIN[23:0];
            
            CNTR_RD : DOUT        <= {26'b0,CNTR};
            CNTR_WR : CNTR        <= DIN[5:0];
            
            ST_DMA_RD : begin
                ST_DMA    <= ~ST_DMA;
                DOUT      <= 32'b0;
            end
            ST_DMA_WR : ST_DMA    <= ~ST_DMA;
            
            FLUSH_RD  : begin 
                FLUSH     <= ~FLUSH;
                DOUT      <= 32'b0;
            end
            FLUSH_WR  : FLUSH     <= ~FLUSH;
            
            CINT_RD   : begin
                CLR_INT   <= ~CLR_INT;
                DOUT      <= 32'b0;
            end
            CINT_WR   : CLR_INT   <= ~CLR_INT;
            
            ISTR_RD : DOUT        <= {23'b0,ISTR};
            //ISTR_WR : ISTR      <= DIN[8:0];

            //TEST_RD   : DOUT    <= TEST;
            //TEST_WR   : TEST    <= DIN;
            
            SP_DMA_RD : begin
                SP_DMA    <= ~SP_DMA;
                DOUT      <= 32'b0;
            end
            SP_DMA_WR : SP_DMA    <= ~SP_DMA;
            default   : DOUT      <= 32'b0;
        endcase

    end
        
end


always @(posedge CLK or posedge _AS) begin
    
    if (_AS) begin
        _DSACK <= 2'b11;
    end else begin
        if (!_CS)
        begin
            _DSACK  <= 2'b00;    
        end 
    end
end

endmodule
