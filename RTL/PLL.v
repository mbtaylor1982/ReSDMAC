module PLL (
	input RST,
	input CLK,
    
	output CLK45,
	output CLK90,
	output CLK135,
    output LOCKED);

`ifdef __ICARUS__ 
// simulate a PLL with 25MHZ input clk
// and 3 output 45,90 and 135 deg phase shifted clks
    reg c1 = 1'b0;
    reg c2 = 1'b0;
    reg c3 = 1'b0;
	reg Slocked;
 
    always @(CLK) begin
            c1 <= #5 CLK;   //45 deg
            c2 <= #10 CLK;  //90 deg
            c3 <= #15 CLK;  //135 deg
    end

    always @(posedge c2, posedge RST) begin
        if (RST == 1'b1)
            Slocked <= 1'b0;
        else 
            Slocked <= 1'b1;
    end

    assign CLK45 =  c1;
    assign CLK90 =  c2;
    assign CLK135 = c3;
    assign LOCKED = Slocked;
	 
`elsif ALTERA_RESERVED_QIS
//Need to have ALTPLL IP Component installed in Quartus for this to work.
//Setup with 25Mhz input and 3 clks at 45,90 and 135 degrees phase shift.

wire c1, c2, c3;

    atpll APLL_inst (
        .areset (RST),
        .inclk0 (CLK),
        .c0     (CLK45),
        .c1     (CLK90),
        .c2     (CLK135),
        .locked (LOCKED)
    );

`endif



endmodule