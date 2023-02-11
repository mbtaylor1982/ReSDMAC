module PLL (
	input rst,
	input  CPUCLK_I,
	output nCLK,
	output BCLK,
	output BBCLK,
    output QnCPUCLK,
	output reg locked);

`ifdef __ICARUS__ 
// simulate a PLL with 25MHZ input clk
// and 3 output 22.5,90 and 135 deg phase shifted clks
    reg c1 = 1'b0;
    reg c2 = 1'b0;
    reg c3 = 1'b0;
    wire c4, c5, c6, c7;

    always @(CPUCLK_I) begin
            c1 <= #2.5 CPUCLK_I;  //22.5 deg
            c2 <= #10 CPUCLK_I;  //90 deg
            c3 <= #15 CPUCLK_I; //135 deg
    end

    assign c4 = CPUCLK_I ^ c2; // 50MHZ
    assign c5 = c1 ^ c3;
    assign c6 = c4 ^ c5; //100MHZ
    
    //assign nCLK =  rst ? 1'b0 : ~c1;
    //assign BCLK =  rst ? 1'b0 : c2;
    //assign BBCLK =  rst ? 1'b0 : c3;
    //assign QnCPUCLK = rst ? 1'b0 : ~CPUCLK_I; 

    assign nCLK = ~c1;
    assign BCLK =  c2;
    assign BBCLK =  c3;
    assign QnCPUCLK = ~CPUCLK_I; 

    always @(posedge BCLK, posedge rst) begin
        if (rst == 1'b1)
            locked <= 1'b0;
        else 
            locked <= 1'b1;
    end
`else

//Need to have ALTPLL IP Component installed in Quartus for this to work.
//Setup with 25Mhz input and 3 clks at 22.5,90 and 135 degrees phase shift.

18, 72, 108,
    APLL APLL_inst (
        .areset (rst    ),
        .inclk0 (clk    ),
        .c0     (c1    ),
        .c1     (c2    ),
        .c2     (c3   ),
        .locked (locked )
    );

`endif

endmodule