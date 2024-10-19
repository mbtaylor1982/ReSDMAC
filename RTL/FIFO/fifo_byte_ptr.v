//ReSDMAC © 2024 by Michael Taylor is licensed under Creative Commons Attribution-ShareAlike 4.0 International. To view a copy of this license, visit https://creativecommons.org/licenses/by-sa/4.0/

module fifo_byte_ptr(
    input CLK,
    input INCBO,
    input RST_FIFO_,
    input A1,       //value of MID25 (A1) stored when ACR_WR and H_0C are asserted.

    output reg [1:0] PTR
);

 always @(negedge CLK or negedge RST_FIFO_) begin
    if (~RST_FIFO_) begin
        if (A1)
            PTR <= 2'b10;
        else
            PTR <= 2'b00;
    end
    else if(INCBO)
      PTR <= PTR + 1'b1;
end

endmodule