
`ifdef __ICARUS__
  `include "mux2.v"
`endif
module fifo_byte_ptr(
    input CLK,
    input INCBO,
    input MID25, //MID25 is used to set the MSB of the BytePtr depending on if it is a transfer to odd or even address
    input ACR_WR,
    input H_0C,
    input RST_FIFO_,

    output [1:0] PTR
);


wire A;
wire Z;
reg B;
reg S;
reg BO0;
reg BO1;

    MUX2 u_MUX2 (
        .A  (A),  // input A,
        .B  (B),  // input B,
        .S  (S),  // select,
        .Z  (Z)   // output,
    );

assign A = ~(BO1 ^ BO0);
assign PTR = {BO1, BO0};

//added to eliminate glitches in the signals B and S.
always @(posedge CLK or negedge RST_FIFO_) begin
    if (~RST_FIFO_) begin
        B <= 1'b0;
        S <= 1'b0;
    end
    else begin
        B <= ~MID25;
        S <= H_0C;
    end
end

always @(posedge CLK or negedge RST_FIFO_) begin
    if (~RST_FIFO_) begin
        BO0 <= 1'b0;
        BO1 <= 1'b0;
    end
    else begin
        if (INCBO) begin
            BO0 <= ~BO0;
            BO1 <= Z;
        end
        if (ACR_WR)
            BO1 <= Z;
    end
end

endmodule