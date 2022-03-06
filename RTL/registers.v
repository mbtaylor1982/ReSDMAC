module registers(ADDR,
                _CS,
                _AS,
                _DS, 
                _RST, 
                R_W,
                DIN, 
                DOUT);


input [7:0] ADDR;   // CPU Address Bus
input _CS;          // SDMAC Chip Select !SCSI from Fat Garry.
input _AS;          // CPU Address Strobe.
input _DS;          // CPU Data Strobe.
input _RST;         // CPU Reset line;
input [31:0] DIN;   // CPU Data Bus
input R_W;          // CPU read write signal

output [31:0] DOUT;

reg [31:0] DOUT;
reg [7:0] addr_int; // address latched on neg edge _AS


//Registers
reg [1:0] DAWR;     //Data Acknowledge Width
reg [23:0] WTC;     //Word Transfer Count
reg [5:0] CNTR;     //Control Register (See ctrl_reg.v)
reg ST_DMA;         //Start DMA 
reg FLUSH;          //Flush FIFO
reg CLR_INT;        //Clear Interrupts
reg [8:0] ISTR;     //Interrupt Status Register
reg SP_DMA;         //Stop DMA 

//DAWR $00DD0000 (WRITE ONLY)
//localparam DAWR_RD = {8'h00,1'b1};
localparam DAWR_WR = {8'h00,1'b0};

//WTC $00DD0004
localparam WTC_RD = {8'h04,1'b1};
localparam WTC_WR = {8'h04,1'b0};

//CNTR $00DD0008
localparam CNTR_RD = {8'h08,1'b1};
localparam CNTR_WR = {8'h08,1'b0};

//ST_DMA $00DD0010
localparam ST_DMA_RD = {8'h10,1'b1};
localparam ST_DMA_WR = {8'h10,1'b0};

//FLUSH $00DD0014
localparam FLUSH_RD = {8'h14,1'b1};
localparam FLUSH_WR = {8'h14,1'b0};

//CINT $00DD0018
localparam CINT_RD = {8'h18,1'b1};
localparam CINT_WR = {8'h18,1'b0};

//ISTR $00DD001C (READ ONLY)
localparam ISTR_RD = {8'h1C,1'b1};
//localparam ISTR_WR = {8'h1C,1'b0};

//SP_DMA $00DD003C
localparam SP_DMA_RD = {8'h3C,1'b1};
localparam SP_DMA_WR = {8'h3C,1'b0};

always @ (negedge _AS, negedge _RST) begin
    if (_RST  == 1'b0) begin
        addr_int <= 8'hff; 
    end else begin
        if ((_AS || _CS) == 1'b0) begin
            addr_int <= ADDR;  
        end
    end
end

always @ (negedge _DS, negedge _RST) begin
        
    if (_RST == 1'b0) begin
        DAWR    <= 2'b0;
        WTC     <= 24'h0;
        CNTR    <= 6'h0;
        ST_DMA  <= 1'h0;
        FLUSH   <= 1'h0;
        CLR_INT <= 1'h0;
        ISTR    <= 9'h0;
        SP_DMA  <= 1'h0;
    end else begin

        case ({addr_int, R_W})
            //DAWR_RD : DOUT      <= {30'b0,DAWR};
            DAWR_WR : DAWR      <= DIN[1:0];
            
            WTC_RD  : DOUT      <= {8'b0, WTC};
            WTC_WR  : WTC       <= DIN[23:0];
            
            CNTR_RD : DOUT      <= {26'b0,CNTR};
            CNTR_WR : CNTR      <= DIN[5:0];
            
            ST_DMA_RD : ST_DMA    <= ~ST_DMA;
            ST_DMA_WR : ST_DMA    <= ~ST_DMA;
            
            FLUSH_RD  : FLUSH     <= ~FLUSH;
            FLUSH_WR  : FLUSH     <= ~FLUSH;
            
            CINT_RD   : CLR_INT   <= ~CLR_INT;
            CINT_WR   : CLR_INT   <= ~CLR_INT;
            
            ISTR_RD : DOUT      <= {23'b0,ISTR};
            //ISTR_WR : ISTR      <= DIN[8:0];
            
            SP_DMA_RD : SP_DMA    <= ~SP_DMA;
            SP_DMA_WR : SP_DMA    <= ~SP_DMA;
            default   : DOUT      <= 'b0;
        endcase

    end
        
end

endmodule
