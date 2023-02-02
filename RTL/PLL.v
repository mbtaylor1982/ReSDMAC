module PLL (
	input rst,
	input  clk,
	output c45,
	output c90,
	output c135,
	output reg locked);

`ifdef __ICARUS__ 
// simulate a PLL with 25MHZ input clk
// and 3 output 45,90 and 135 deg phase shifted clks
    reg c1 = 1'b0;
    reg c2 = 1'b0;
    reg c3 = 1'b0;

    always @(clk) begin
            c1 <= #5 clk;
            c2 <= #10 clk;
            c3 <= #15 clk;
    end
    assign c45 =  rst ? 1'b0 : c1;
    assign c90 =  rst ? 1'b0 : c2;
    assign c135 =  rst ? 1'b0 : c3;

    always @(posedge c45, posedge rst) begin
        if (rst == 1'b1)
            locked <= 1'b0;
        else 
            locked <= 1'b1;
    end
`else
//Need to have ALTPLL IP Component installed in Quartus for this to work.

    APLL APLL_inst (
        .areset (rst    ),
        .inclk0 (clk    ),
        .c0     (c45    ),
        .c1     (c90    ),
        .c2     (c135   ),
        .locked (locked )
    );

`endif

endmodule