 //ReSDMAC © 2024 by Michael Taylor is licensed under Creative Commons Attribution-ShareAlike 4.0 International. To view a copy of this license, visit https://creativecommons.org/licenses/by-sa/4.0/
 
 `ifdef __ICARUS__ 
    `include "addr_decoder.v"
    `include "registers_istr.v"
    `include "registers_cntr.v"
    `include "registers_term.v"
`endif

module registers(
  input [7:0] ADDR,     // CPU address Bus
  input DMAC_,          // SDMAC Chip Select !SCSI from Fat Garry.
  input AS_,            // CPU Address Strobe.
  input RW,             // CPU Read Write Control Line.
  input CLK,            // System Clock
  input [31:0] MID,     // DATA IN
  input STOPFLUSH,      //
  input RST_,           // System Reset
  input FIFOEMPTY,      // FIFO Emtpty Flag
  input FIFOFULL,       // FIFO Full Flag
  input INTA_I,         // Interupt input
  input AS_O,           // Address strobe from CPU FSM
  input DSP_DATA,

  output reg [31:0] REG_OD,     //DATA OUT.
  output PRESET,            //Peripheral Reset.
  output reg FLUSHFIFO,     //Flush FIFO.
  output ACR_WR,            //input to FIFO_byte_ptr.
  output h_0C,              //input to FIFO_byte_ptr.
  output reg A1,            //Store value of A1 written to ACR.
  output INT_O_,            //INT_2 Output. (maskable by negating INTENA in the control register)
  output DMADIR,            //DMA Direction
  output DMAENA,            //DMA Enabled.
  output REG_DSK_,          //Register Cycle Term.
  output WDREGREQ          //SCSI IC Chip Select.

);

wire CONTR_RD_;
wire CONTR_WR;
wire ISTR_RD_;
wire WTC_RD_;
wire DSP_RD_;
wire INTENA;
wire SSPBDAT_RD_;
wire SSPBDAT_WR;
wire VERSION_RD_;
wire VERSION_WR;
wire [5:0] MuxSelect;

//Action strobes
wire ST_DMA;    //Start DMA 
wire SP_DMA;    //Stop DMA 
wire CLR_INT;   //Clear Interrupts
wire FLUSH_;    //Flush FIFO

//Registers
wire [8:0] ISTR_O;  //Interrupt Status Register
wire [8:0] CNTR_O;  //Control Register
wire nDMADIR;
reg [31:0] SSPBDAT;  //Fake Synchronous Serial Peripheral Bus Data Register (used to test SDMAC rev 4 in the test tool by CDH)

reg [8*4:1] VERSION; //used to store the code version (git tag) limited to 4 ascii chars.
reg [7:0] DSP;
//reg [31:0] META_DATA0;
//reg [31:0] META_DATA1;
//reg [31:0] META_DATA2;


wire [31:0] WTC;
wire [31:0] CNTR;
wire [31:0] ISTR;


//Address Decoding and Strobes
addr_decoder u_addr_decoder(
    .ADDR           (ADDR       ),
    .DMAC_          (DMAC_      ),
    .AS_            (AS_        ),
    .RW             (RW         ),
    .DMADIR         (nDMADIR    ),
    .h_0C           (h_0C       ),
    .WDREGREQ       (WDREGREQ   ),
    .WTC_RD_        (WTC_RD_    ),
    .CONTR_RD_      (CONTR_RD_  ),
    .CONTR_WR       (CONTR_WR   ),
    .ISTR_RD_       (ISTR_RD_   ),
    .DSP_RD_        (DSP_RD_    ),
    .ACR_WR         (ACR_WR     ),
    .ST_DMA         (ST_DMA     ),
    .SP_DMA         (SP_DMA     ),
    .CLR_INT        (CLR_INT    ),
    .FLUSH_         (FLUSH_     ),
    .SSPBDAT_WR     (SSPBDAT_WR ),
    .SSPBDAT_RD_    (SSPBDAT_RD_),
    .VERSION_RD_    (VERSION_RD_),
    .VERSION_WR     (VERSION_WR )
);

//Interupt Status Register
registers_istr u_registers_istr(
    .RESET_    (RST_      ),
    .CLK       (CLK       ),
    .FIFOEMPTY (FIFOEMPTY ),
    .FIFOFULL  (FIFOFULL  ),
    .CLR_INT   (CLR_INT   ),
    .ISTR_RD_  (ISTR_RD_  ),
    .INTENA    (INTENA    ),
    .INTA_I    (INTA_I    ),
    .ISTR_O    (ISTR_O    ),
    .INT_O_    (INT_O_    )
);

//Control Register
registers_cntr u_registers_cntr(
    .RESET_    (RST_      ),
    .CLK       (CLK       ),
    .CONTR_WR  (CONTR_WR  ),
    .ST_DMA    (ST_DMA    ),
    .SP_DMA    (SP_DMA    ),
    .MID       (MID[8:0]  ),
    .CNTR_O    (CNTR_O    ),
    .INTENA    (INTENA    ),
    .PRESET    (PRESET    ),
    .DMADIR    (nDMADIR   ),
    .DMAENA    (DMAENA    )
);

//DSACK timing.
registers_term u_registers_term(
    .CLK      (CLK      ),
    .AS_      (AS_      ),
    .DMAC_    (DMAC_    ),
    .WDREGREQ (WDREGREQ ),
    .h_0C     (h_0C     ),
    .REG_DSK_ (REG_DSK_ )
);

assign DMADIR = ~nDMADIR;

always @(negedge CLK or negedge RST_) begin
    if (~RST_)
        FLUSHFIFO <= 1'b0;
    else if (~FLUSH_)
        FLUSHFIFO <= 1'b1;
	else if (STOPFLUSH)
		FLUSHFIFO <= 1'b0;
end

//Store value of A1 loaded into ACR
always @(negedge CLK or negedge RST_) begin
    if (~RST_)
        A1 <= 1'b1;
    else if (ACR_WR)
        A1 <= MID[25];
    else if (~AS_O)
        A1 <= 1'b0;
end

//Fake SSPBDAT register (only used for testing read and write cycles)
always @(negedge CLK or negedge RST_) begin
    if (~RST_)
        SSPBDAT <= 32'b0;
    else if (SSPBDAT_WR)
        SSPBDAT <= MID[31:0];
end

always @(negedge RST_) begin
    if (~RST_)
        VERSION <= "/$V$"; // This will get replaced with the release tag by github eg(v0.4).
end


always @(negedge CLK or negedge RST_) begin
    if (~RST_)
        DSP <= 8'b0;
    else if (~AS_)
        DSP <= DSP_DATA;
end

assign MuxSelect = {~WTC_RD_, ~ISTR_RD_, ~CONTR_RD_, ~SSPBDAT_RD_, ~VERSION_RD_, ~DSP_RD_};

localparam WTC_SEL = 6'b100000;
localparam ISTR_SEL = 6'b010000;
localparam CONTR_SEL = 6'b001000;
localparam SSPBDAT_SEL = 6'b000100;
localparam VERSION_SEL = 6'b000010;
localparam DSP_SEL = 6'b000001;

always @(*) begin
    case (MuxSelect)
      WTC_SEL       : REG_OD <= 32'h00000000;
      ISTR_SEL      : REG_OD <= {23'h0, ISTR_O};
      CONTR_SEL     : REG_OD <= {23'h0, CNTR_O};
      SSPBDAT_SEL   : REG_OD <= SSPBDAT;
      VERSION_SEL   : REG_OD <= VERSION;
      DSP_SEL       : REG_OD <= {24'h0, DSP};
      default       : REG_OD <= 32'h00000000;
    endcase
end

// the "macro" to dump signals
`ifdef COCOTB_SIM1
initial begin
  $dumpfile ("registers.vcd");
  $dumpvars (0, registers);
  #1;
end
`endif

endmodule