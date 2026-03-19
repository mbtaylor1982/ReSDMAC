//ReSDMAC © 2024 by Michael Taylor is licensed under Creative Commons Attribution-ShareAlike 4.0 International.
//To view a copy of this license, visit https://creativecommons.org/licenses/by-sa/4.0/

module fifo
#(
      parameter DEPTH = 8,
      parameter  WIDTH = 32)
(

    input i_CLK100,       // 100MHz main clock
    input i_LLWORD,       //Load Lower Word strobe from CPU sm
    input i_LHWORD,       //Load Higher Word strobe from CPU sm

    input i_LBYTE_n,      //Load Byte strobe from SCSI SM = !(DACK.o & RE.o)
    input i_RST_FIFO_n,   //Reset FIFO
    input i_A1,           //value of A1 loaded into ACR as start of DMA cycle

    input [WIDTH-1:0] i_FIFO_ID,    //FIFO Data Input

    output o_FIFOFULL,    //Signal FIFO is FULL
    output o_FIFOEMPTY,   //Signal FIFO is Empty

    input i_INCFIFO,      //Inc FIFO from CPU sm
    input i_DECFIFO,      //Dec FIFO from CPU sm

    input i_INCBO,        //Inc Byte Pointer from SCSI SM.

    output o_BOEQ0,       //True when BytePtr indicates 1st Byte
    output o_BOEQ3,       //True when BytePtr indicates 4th Byte

    output o_BO0,         //BytePtr Bit 0
    output o_BO1,         //BytePtr Bit 1

    input i_INCNO,        //Inc Next Out (Write Pointer)
    input i_INCNI,        //Inc Next In (Read Pointer)

    output [WIDTH-1:0] o_FIFO_OD    //FIFO Data Output
);

localparam cntr_bits = ($clog2(DEPTH));
localparam full_empty_bits = ($clog2(DEPTH+1));

reg [1:0] incbo_edge_detect;
reg [1:0] incni_edge_detect;
reg [1:0] incno_edge_detect;
reg [1:0] incfifo_edge_detect;
reg [1:0] decfifo_edge_detect;

reg [cntr_bits-1:0] write_ptr;
reg [cntr_bits-1:0] read_ptr;
reg [1:0] byte_ptr;

wire uuws;
wire umws;
wire lmws;
wire llws;

wire incbo_rise_evt    = (incbo_edge_detect   == 2'b01);
wire incni_rise_evt    = (incni_edge_detect   == 2'b01);
wire incno_rise_evt    = (incno_edge_detect   == 2'b01);
wire incfifo_rise_evt  = (incfifo_edge_detect == 2'b01);
wire decfifo_rise_evt  = (decfifo_edge_detect == 2'b01);

//Edge detection for all counter increment/decrement signals.
//Each detects only the rising edge, ensuring a single-cycle pulse regardless of how long the input is asserted.
//The pulse is delayed by one clock cycle relative to the input rising edge.

always @(posedge i_CLK100) begin
  incbo_edge_detect    <= {incbo_edge_detect[0],    i_INCBO   };
  incni_edge_detect    <= {incni_edge_detect[0],    i_INCNI   };
  incno_edge_detect    <= {incno_edge_detect[0],    i_INCNO   };
  incfifo_edge_detect  <= {incfifo_edge_detect[0],  i_INCFIFO };
  decfifo_edge_detect  <= {decfifo_edge_detect[0],  i_DECFIFO };
end

// --- Write Strobes ---
assign uuws = (!byte_ptr[1] & !byte_ptr[0] & !i_LBYTE_n) | i_LHWORD; // B0
assign umws = (!byte_ptr[1] &  byte_ptr[0] & !i_LBYTE_n) | i_LHWORD; // B1
assign lmws = ( byte_ptr[1] & !byte_ptr[0] & !i_LBYTE_n) | i_LLWORD; // B2
assign llws = ( byte_ptr[1] &  byte_ptr[0] & !i_LBYTE_n) | i_LLWORD; // B3

// --- Full/Empty Counter ---
reg [full_empty_bits-1:0] full_empty_count;

always @(posedge i_CLK100) begin
  if (~i_RST_FIFO_n)
    full_empty_count <= 0;
  else begin
    if (incfifo_rise_evt) begin
      if (full_empty_count == DEPTH)
        full_empty_count <= 0;
      else
        full_empty_count <= full_empty_count + 1'b1;
    end

    if (decfifo_rise_evt) begin
      if (full_empty_count == 0)
        full_empty_count <= DEPTH;
      else
        full_empty_count <= full_empty_count - 1'b1;
    end
  end
end

assign o_FIFOFULL  = (full_empty_count == DEPTH);
assign o_FIFOEMPTY = (full_empty_count == 0);

// --- Next In Write Counter ---
always @(posedge i_CLK100) begin
    if (~i_RST_FIFO_n)
        write_ptr <= 0;
    else if (incni_rise_evt)
        write_ptr <= write_ptr + 1'b1;
end

// --- Next Out Read Counter ---
always @(posedge i_CLK100) begin
    if (~i_RST_FIFO_n)
        read_ptr <= 0;
    else if (incno_rise_evt)
        read_ptr <= read_ptr + 1'b1;
end

// --- Byte Pointer ---
always @(posedge i_CLK100) begin
    if (~i_RST_FIFO_n)
        byte_ptr <= {i_A1, 1'b0};
    else if (incbo_rise_evt)
        byte_ptr <= byte_ptr + 1'b1;
end

assign o_BO0 = byte_ptr[0];
assign o_BO1 = byte_ptr[1];

assign o_BOEQ0 = (byte_ptr == 0);
assign o_BOEQ3 = (byte_ptr == 3);

//32 bit wide FIFO buffer default depth = 8
reg [WIDTH-1:0] buffer [DEPTH-1:0];
integer i;

//WRITE DATA TO FIFO BUFFER
always @(posedge i_CLK100) begin
  if (~i_RST_FIFO_n) begin
    for (i = 0; i < DEPTH; i = i+1) begin
      buffer[i] <= {WIDTH{1'b0}};
    end
  end
  else begin
    if (uuws)
      buffer[write_ptr][31:24] <= i_FIFO_ID[31:24];
    if (umws)
      buffer[write_ptr][23:16] <= i_FIFO_ID[23:16];
    if (lmws)
      buffer[write_ptr][15:8] <= i_FIFO_ID[15:8];
    if (llws)
      buffer[write_ptr][7:0] <= i_FIFO_ID[7:0];
  end
end

assign o_FIFO_OD = buffer[read_ptr]; // Output data from FIFO at the current read pointer location

endmodule
