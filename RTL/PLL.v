//ReSDMAC © 2024 by Michael Taylor is licensed under Creative Commons Attribution-ShareAlike 4.0 International. To view a copy of this license, visit https://creativecommons.org/licenses/by-sa/4.0/

module PLL (
	input RST,
	input CLK,

	output CLK100,
    output LOCKED);

`ifdef __ICARUS__
// simulate a PLL with 25MHz input clk
// and 100MHz output clock (4x multiplier)
    reg clk_100 = 1'b0;
	reg Slocked = 1'b0;

    // Generate 100MHz synchronized to input CLK
    // On each edge of CLK (both pos and neg), toggle CLK100 twice
    // This creates 4 CLK100 periods for each CLK period
    always @(posedge CLK) begin
        if (~RST) begin
            // Create 2 toggles during high phase of CLK
            #5 clk_100 = ~clk_100;   // Toggle at +5ns
            #5 clk_100 = ~clk_100;   // Toggle at +10ns
        end
    end

    always @(negedge CLK) begin
        if (~RST) begin
            // Create 2 toggles during low phase of CLK
            #5 clk_100 = ~clk_100;   // Toggle at +5ns from negedge
            #5 clk_100 = ~clk_100;   // Toggle at +10ns from negedge
        end
    end

    always @(posedge CLK, posedge RST) begin
        if (RST == 1'b1)
            Slocked <= 1'b0;
        else
            Slocked <= 1'b1;
    end

    assign CLK100 = clk_100;
    assign LOCKED = Slocked;

`elsif ALTERA_RESERVED_QIS
//Need to have ALTPLL IP Component installed in Quartus for this to work.
//Setup with 25MHz input and 100MHz output (4x multiplier).
//NOTE: The Quartus PLL IP will need to be reconfigured to output 100MHz instead of phase-shifted clocks.

	 attpll	attpll_inst (
	.areset ( RST ),
	.inclk0 ( CLK ),
	.c0 ( CLK100 ),
	.locked ( LOCKED )
	);


`endif

endmodule