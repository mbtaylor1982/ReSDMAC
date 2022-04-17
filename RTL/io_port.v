/*

AMIGA SDMAC Replacement Project  A3000
Copyright 2022 Mike Taylor

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

*/

module io_port(CLK,
                ADDR,
                _CS,
                _AS,
                _DS,
                R_W,
                _RST,
                DATA_IN,
                DATA_OUT,
                _CSS,
                _CSX0,
                _CSX1,
                P_DATA,
                _IOR,
                _IOW,
                _DSACK);

input CLK;           // CPU CLK
input [4:0] ADDR;    // CPU address Bus
input _CS;           // Port enable
input _AS;           // CPU Address Strobe.
input _DS;           // CPU Data Strobe.
input R_W;           // Read Write Control
input _RST;          // System Reset

input [31:0] DATA_IN;       // CPU data input
output [31:0] DATA_OUT;     // CPU data output.

inout [15:0] P_DATA;        //Peripheral Data bus

output _IOR;         // False on Read
output _IOW;         // False on Write
output _CSS;         // Port 0 chip select (SCSI WD33C93A)
output _CSX0;        // Port 1A and 1B chip select (XT/ ATA)
output _CSX1;        // Port 2 chip select (XT)
output [1:0] _DSACK;

wire [15:0] PDATA_IN;

reg [31:0] DATA_OUT = 32'h0;
reg [15:0] PDATA_OUT = 16'h0;
reg [1:0] _DSACK = 2'b11;
reg [2:0] ASDLY = 3'b000;

//Port0 $00DD0040-4F 
localparam PORT0_RD = {3'h4,1'b1,1'b0,1'b0,3'h5};
localparam PORT0_WR = {3'h4,1'b0,1'b0,1'b0,3'h2};
localparam PORT0_RD_TERM = {3'h4, 1'b1, 1'b0, 1'b0, 3'h5}; 
localparam PORT0_WR_TERM = {3'h4, 1'b0, 1'b0, 1'b0, 3'h5} ; 

//Port1A $00DD0050-5F
localparam PORT1A_RD = {3'h5,1'b1,1'b0,1'b0,3'h5};
localparam PORT1A_WR = {3'h5,1'b0,1'b0,1'b0,3'h2};
localparam PORT1A_RD_TERM = {3'h5, 1'b1, 1'b0, 1'b0, 3'h5};
localparam PORT1A_WR_TERM = {3'h5, 1'b1, 1'b0, 1'b0, 3'h5};

//Port2 $00DD0060-6F 
localparam PORT2_RD = {3'h6,1'b1,1'b0,1'b0,3'h5};
localparam PORT2_WR = {3'h6,1'b0,1'b0,1'b0,3'h2};
localparam PORT2_RD_TERM = {3'h6, 1'b1, 1'b0, 1'b0,  3'h5};
localparam PORT2_WR_TERM = {3'h6, 1'b1, 1'b0, 1'b0,  3'h5};

//Port1B $00DD0070-7F
localparam PORT1B_RD = {3'h7,1'b1,1'b0,1'b0,3'h5};
localparam PORT1B_WR = {3'h7,1'b0,1'b0,1'b0,3'h2};
localparam PORT1B_RD_TERM = {3'h7, 1'b1, 1'b0, 1'b0,  3'h5};
localparam PORT1B_WR_TERM = {3'h7, 1'b1, 1'b0, 1'b0,  3'h5};

always @ (posedge CLK or negedge _RST) begin
        
    if (!_RST) begin
        DATA_OUT <= 32'h0;
    end else begin

        case ({ADDR[4:2], R_W, _CS, _DS, ASDLY})
            PORT0_RD    : DATA_OUT <= {PDATA_IN, PDATA_IN};
            PORT1A_RD   : DATA_OUT <= {PDATA_IN, PDATA_IN};
            PORT2_RD    : DATA_OUT <= {PDATA_IN, PDATA_IN};
            PORT1B_RD   : DATA_OUT <= {PDATA_IN, PDATA_IN};
         endcase

    end
        
end

always @(posedge CLK or negedge _RST) begin
    if (!_RST) begin
        PDATA_OUT <= 16'h0;
    end else begin
        case({ADDR[4:2], R_W, _CS, _AS, ASDLY})
            PORT0_WR    : PDATA_OUT <= {DATA_IN[7:0], DATA_IN[7:0]};
            PORT1A_WR   : PDATA_OUT <= {DATA_IN[7:0], DATA_IN[7:0]};
            PORT2_WR    : PDATA_OUT <= {DATA_IN[7:0], DATA_IN[7:0]};
            PORT1B_WR   : PDATA_OUT <= DATA_IN[31:16];
        endcase
    end
end

always @(negedge CLK or posedge _AS) begin
    
    if (_AS) begin
        ASDLY <= 3'b000;
    end else begin        
        ASDLY <= ASDLY + 1;
    end

end

always @(posedge CLK or posedge _AS) begin
    
    if (_AS) begin
        _DSACK <= 2'b11;
    end else begin
        case ({ADDR[4:2], R_W, _CS, _DS, ASDLY})
         PORT0_RD_TERM : _DSACK <= 2'b00;
         PORT0_WR_TERM : _DSACK <= 2'b00;
         PORT1A_RD_TERM : _DSACK <= 2'b00;
         PORT1A_WR_TERM : _DSACK <= 2'b00;
         PORT2_RD_TERM : _DSACK <= 2'b00;
         PORT2_WR_TERM : _DSACK <= 2'b00;
         PORT1B_RD_TERM : _DSACK <= 2'b01;    
         PORT1B_WR_TERM : _DSACK <= 2'b01;
        endcase
    end
end

assign _CSS  = !({ADDR[4:2], _CS}  ==  {3'h4, 1'b0});
assign _CSX0 = !({ADDR[4],ADDR[2],_CS}  ==  {1'b1,1'b1,1'b0});
assign _CSX1 = !({ADDR[4:2],_CS}  ==  {3'h6,1'b0});

assign _IOW = (R_W | _AS | _CS | (ASDLY > 5));
assign _IOR = (~R_W | _AS | _CS | (ASDLY > 5));

assign PDATA_IN = P_DATA;
assign P_DATA = (_CS | R_W) ? 16'bz : PDATA_OUT;

endmodule

