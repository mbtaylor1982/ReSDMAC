//ReSDMAC © 2024 by Michael Taylor is licensed under Creative Commons Attribution-ShareAlike 4.0 International. To view a copy of this license, visit https://creativecommons.org/licenses/by-sa/4.0/

module datapath_output (
    input CLK,
    output [31:0] DATA,  
    
    input [31:0] OD,
    input [31:0] MOD,
    input BRIDGEOUT,
    input DOEH_,
    input DOEL_,
    input F2CPUL,
    input F2CPUH,
    input S2CPU,
    input PAS     
);

wire LOD1_F2CPU;
wire LOD2_F2CPU;

wire [15:0] LOWER_INPUT_DATA;
wire [15:0] UPPER_INPUT_DATA;

wire [15:0] LOWER_OUTPUT_DATA;
wire [15:0] UPPER_OUTPUT_DATA;

reg [15:0] LD_LATCH;
reg [15:0] UD_LATCH;


always @(posedge CLK) begin
    if (LOD1_F2CPU)
        LD_LATCH <= LOWER_INPUT_DATA;
end

always @(posedge CLK) begin
    if (LOD2_F2CPU)
        UD_LATCH <= BRIDGEOUT ? LOWER_INPUT_DATA : UPPER_INPUT_DATA;
end

assign LOD1_F2CPU = PAS;
assign LOD2_F2CPU = PAS;

assign LOWER_INPUT_DATA = OD[15:0];
assign UPPER_INPUT_DATA = OD[31:16];

assign LOWER_OUTPUT_DATA = F2CPUL ? LD_LATCH : MOD[15:0];
assign UPPER_OUTPUT_DATA = F2CPUH ? UD_LATCH : MOD[31:16];
assign DATA = S2CPU ? MOD : {UPPER_OUTPUT_DATA, LOWER_OUTPUT_DATA};

endmodule