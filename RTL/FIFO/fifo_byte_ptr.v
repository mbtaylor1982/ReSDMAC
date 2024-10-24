//ReSDMAC © 2024 by Michael Taylor is licensed under Creative Commons Attribution-ShareAlike 4.0 International. To view a copy of this license, visit https://creativecommons.org/licenses/by-sa/4.0/

module fifo_byte_ptr(
    input CLK,
    input SyncLoad,
    input Enable,
    input [1:0] Data,
    output reg [1:0] Count
);

 always @(negedge CLK) begin
    if (SyncLoad) begin
        Count <= Data;
    end
    else if(Enable)
      Count <= Count + 1'b1;
end

endmodule