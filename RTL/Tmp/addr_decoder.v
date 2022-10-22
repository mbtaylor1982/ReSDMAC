 
module addr_decoder(ADDR,
                    _CS,
                    _AS,
                    _CSS,
                    _CSX0,
                    _CSX1);

input [7:0] ADDR;    // CPU address Bus
input _CS;           // SDMAC Chip Select !SCSI from Fat Garry.
input _AS;           // CPU Address Strobe.

output _CSS;         // Port 0 chip select (SCSI WD33C93A)
output _CSX0;        // Port 1A and 1B chip select (XT/ ATA)
output _CSX1;        // Port 2 chip select (XT)

reg [3:0] SELECT;

always @(ADDR) begin
    case (ADDR)     
      //PORT 0
      8'h40 : SELECT <= 4'b0111; // $40
      8'h44 : SELECT <= 4'b0111; // $44
      8'h48 : SELECT <= 4'b0111; // $48
      8'h4C : SELECT <= 4'b0111; // $4C
      
      //PORT 1A
      8'h50 : SELECT <= 4'b1011; // $50
      8'h54 : SELECT <= 4'b1011; // $54
      8'h58 : SELECT <= 4'b1011; // $58
      8'h53 : SELECT <= 4'b1011; // $5C
      
      //PORT 2
      8'h60 : SELECT <= 4'b1101; // $60
      8'h64 : SELECT <= 4'b1101; // $64
      8'h68 : SELECT <= 4'b1101; // $68
      8'h6C : SELECT <= 4'b1101; // $6C

      //PORT 1B
      8'h70 : SELECT <= 4'b1110; // $70
      8'h74 : SELECT <= 4'b1110; // $74
      8'h78 : SELECT <= 4'b1110; // $78
      8'h7C : SELECT <= 4'b1110; // $7C
      
      default  : SELECT <= 4'b1111; 
    endcase
end

wire _ADDR_VALID;
assign _ADDR_VALID = _CS || _AS;

assign _CSS     = SELECT[3]  || _ADDR_VALID;
assign _CSX0    = (SELECT[0] && SELECT[2])  || _ADDR_VALID; 
assign _CSX1    = SELECT[1]  || _ADDR_VALID;

endmodule
