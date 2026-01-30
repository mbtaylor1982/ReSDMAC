//ReSDMAC © 2024 by Michael Taylor is licensed under Creative Commons Attribution-ShareAlike 4.0 International. To view a copy of this license, visit https://creativecommons.org/licenses/by-sa/4.0/

module fifo_byte_ptr(
    input CLK,
    input phase,     // Phase enable signal
    input SyncLoad,
    input Enable,
    input [1:0] Data,
    output reg [1:0] Count
);

// Update on specific phase (was negedge CLK90, now phase_180 on CLK100)
 always @(posedge CLK) begin
    if (phase) begin
        if (SyncLoad) begin
            Count <= Data;
        end
        else if(Enable)
          Count <= Count + 1'b1;
    end
end

endmodule