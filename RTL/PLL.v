module PLL (
	input rst,
	input  CPUCLK_I,
	output nCLK,
	output BCLK,
	output BBCLK,
   output QnCPUCLK,
	output locked);

`ifdef __ICARUS__ 
// simulate a PLL with 25MHZ input clk
// and 3 output 22.5,90 and 135 deg phase shifted clks
    reg c1 = 1'b0;
    reg c2 = 1'b0;
    reg c3 = 1'b0;
	 reg Slocked;
 
    always @(CPUCLK_I) begin
            c1 <= #2.5 CPUCLK_I;  //22.5 deg
            c2 <= #10 CPUCLK_I;  //90 deg
            c3 <= #15 CPUCLK_I; //135 deg
    end

    //assign nCLK =  rst ? 1'b0 : ~c1;
    //assign BCLK =  rst ? 1'b0 : c2;
    //assign BBCLK =  rst ? 1'b0 : c3;
    //assign QnCPUCLK = rst ? 1'b0 : ~CPUCLK_I; 

    always @(posedge BCLK, posedge rst) begin
        if (rst == 1'b1)
            Slocked <= 1'b0;
        else 
            Slocked <= 1'b1;
    end
	 
	 assign locked = Slocked;
	 
`elsif ALTERA_RESERVED_QIS
//Need to have ALTPLL IP Component installed in Quartus for this to work.
//Setup with 25Mhz input and 3 clks at 22.5,90 and 135 degrees phase shift.

wire c1, c2, c3;

    atpll APLL_inst (
        .areset (rst    ),
        .inclk0 (CPUCLK_I    ),
        .c0     (c1    ),
        .c1     (c2    ),
        .c2     (c3   ),
        .locked (locked )
    );

`endif

    assign nCLK = ~c1;
    assign BCLK =  c2;
    assign BBCLK =  c3;
    assign QnCPUCLK = ~CPUCLK_I; 

endmodule