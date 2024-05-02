//ReSDMAC © 2024 by Michael Taylor is licensed under Creative Commons Attribution-ShareAlike 4.0 International. To view a copy of this license, visit https://creativecommons.org/licenses/by-sa/4.0/

module datapath_input (
    input CLK,
    input [31:0] DATA,
    
    input bBRIDGEIN,
    input bDIEH,
    input bDIEL,
    input DS_O_,

    output [31:0] MID,
    output [31:0] CPU_OD
);

wire [15:0] LOWER_INPUT_DATA;
wire [15:0] UPPDER_INTPUT_DATA;

wire [15:0] LOWER_OUTPUT_DATA;
wire [15:0] UPPDER_OUTPUT_DATA;

reg [15:0] UD_LATCH;

always @(negedge CLK) begin
    if (~DS_O_)
        UD_LATCH <= UPPDER_INTPUT_DATA;   
end

assign LOWER_INPUT_DATA = DATA[15:0];
assign UPPDER_INTPUT_DATA = DATA[31:16];

assign UPPDER_OUTPUT_DATA = bDIEH ? UPPDER_INTPUT_DATA : 16'h0000;
assign LOWER_OUTPUT_DATA = bDIEL ? LOWER_INPUT_DATA : (bBRIDGEIN ? UD_LATCH : 16'h0000);
assign CPU_OD = {UPPDER_OUTPUT_DATA, LOWER_OUTPUT_DATA};

assign MID = DATA;

endmodule
