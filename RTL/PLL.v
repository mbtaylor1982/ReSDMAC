module PLL (
	input rst,
	input  clk,
	output c45,
	output c90,
	output c135,
	output reg locked);

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

endmodule