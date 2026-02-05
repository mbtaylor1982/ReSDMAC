/*
ReSDMAC © 2026 by Michael Taylor is licensed under Creative Commons Attribution-ShareAlike 4.0 International. 
To view a copy of this license, visit https://creativecommons.org/licenses/by-sa/4.0/
*/

module sync_2ff (
    input  wire clk,
    input  wire async_in,
    output wire sync_out
);

    (* ASYNC_REG = "TRUE" *) reg [1:0] sync;

    always @(posedge clk) begin
        sync <= {sync[0], async_in};
    end

    assign sync_out = sync[1];

endmodule