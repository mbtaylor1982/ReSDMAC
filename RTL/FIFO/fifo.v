//ReSDMAC © 2024 by Michael Taylor is licensed under Creative Commons Attribution-ShareAlike 4.0 International. To view a copy of this license, visit https://creativecommons.org/licenses/by-sa/4.0/

`ifdef __ICARUS__ 
  `include "fifo_write_strobes.v"
  `include "fifo_full_empty_ctr.v"
  `include "fifo_3bit_cntr.v"
  `include "fifo_byte_ptr.v"
`endif

module fifo
#(
      parameter DEPTH = 8,
      parameter  WIDTH = 32)
(

    input CLK, CLK90, CLK135, //Clocks

    input LLWORD,       //Load Lower Word strobe from CPU sm
    input LHWORD,       //Load Higher Word strobe from CPU sm

    input LBYTE_,       //Load Byte strobe from SCSI SM = !(DACK.o & RE.o)
    input RST_FIFO_,    //Reset FIFO
    input A1,           //value of A1 loaded into ACR as start of DMA cycle

    input [WIDTH-1:0] FIFO_ID,    //FIFO Data Input

    output FIFOFULL,    //Signal FIFO is FULL
    output FIFOEMPTY,   //Signal FIFO is Empty

    input INCFIFO,      //Inc FIFO from CPU sm
    input DECFIFO,      //Dec FIFO from CPU sm

    input INCBO,        //Inc Byte Pointer from SCSI SM.

    output BOEQ0,       //True when BytePtr indicates 1st Byte
    output BOEQ3,       //True when BytePtr indicates 4th Byte

    output BO0,         //BytePtr Bit 0
    output BO1,         //BytePtr Bit 1

    input INCNO,        //Inc Next Out (Write Pointer)
    input INCNI,        //Inc Next In (Read Pointer)

    output [WIDTH-1:0] FIFO_OD    //FIFO Data Output
);

localparam CNTR_BITS = ($clog2(DEPTH));

wire [CNTR_BITS-1:0] WRITE_PTR;
wire [CNTR_BITS-1:0] READ_PTR;
wire [1:0] BYTE_PTR;
wire UUWS;
wire UMWS;
wire LMWS;
wire LLWS;

fifo_write_strobes u_write_strobes(
    .PTR    (BYTE_PTR ),
    .LHWORD (LHWORD   ),
    .LLWORD (LLWORD   ),
    .LBYTE_ (LBYTE_   ),
    .UUWS   (UUWS     ),
    .UMWS   (UMWS     ),
    .LMWS   (LMWS     ),
    .LLWS   (LLWS     )
);

fifo__full_empty_ctr #(
  .BITS($clog2(DEPTH+1)),
  .MAX(DEPTH)
)
u_full_empty_ctr
(
    .CLK       (CLK       ),
    .RST_      (RST_FIFO_ ),
    .INC       (INCFIFO   ),
    .DEC       (DECFIFO   ),
    .EMPTY     (FIFOEMPTY ),
    .FULL      (FIFOFULL  )
);

//Next In Write Counter
fifo_3bit_cntr #(.BITS(CNTR_BITS))
u_next_in_cntr
(
    .CLK       (CLK135    ),
    .RST_      (RST_FIFO_ ),
    .ClKEN     (INCNI     ),
    .COUNT     (WRITE_PTR )
);

//Next Out Read Counter
fifo_3bit_cntr #(.BITS(CNTR_BITS))
u_next_out_cntr
(
    .CLK       (CLK135    ),
    .RST_      (RST_FIFO_ ),
    .ClKEN     (INCNO     ),
    .COUNT     (READ_PTR  )
);

//BYTE POINTER
fifo_byte_ptr u_byte_ptr(
  .CLK       (CLK90      ),
  .SyncLoad  (~RST_FIFO_ ),
  .Enable    (INCBO      ),
  .Data      ({A1, 1'b0} ),
  .Count     (BYTE_PTR   )
);

assign BO0 = BYTE_PTR[0];
assign BO1 = BYTE_PTR[1];

assign BOEQ0 = (BYTE_PTR == 0);
assign BOEQ3 = (BYTE_PTR == 3);

//32 bit wide FIFO buffer default depth = 8
reg [WIDTH-1:0] BUFFER [DEPTH-1:0];
integer i;

//WRITE DATA TO FIFO BUFFER
always @(posedge CLK90) begin
  if (~RST_FIFO_) begin
    for (i = 0; i < DEPTH; i = i+1) begin
      BUFFER[i] <= 32'h00000000;
    end
  end
  else begin
    if (UUWS)
      BUFFER[WRITE_PTR][31:24] <= FIFO_ID[31:24];
    if (UMWS)
      BUFFER[WRITE_PTR][23:16] <= FIFO_ID[23:16];
    if (LMWS)
      BUFFER[WRITE_PTR][15:8] <= FIFO_ID[15:8];
    if (LLWS)
      BUFFER[WRITE_PTR][7:0] <= FIFO_ID[7:0];
  end
end

assign FIFO_OD = BUFFER[READ_PTR];

endmodule