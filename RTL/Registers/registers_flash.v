//ReSDMAC © 2024 by Michael Taylor is licensed under Creative Commons Attribution-ShareAlike 4.0 International. To view a copy of this license, visit https://creativecommons.org/licenses/by-sa/4.0/
module registers_flash(
    input CLK,
    input nRST,
    input [23:0] FLASH_ADDR,
    input [31:0] FLASH_DATA_IN,
    input FLASH_DATA_RD_,
    input FLASH_DATA_WR,
    output [31:0] FLASH_DATA_OUT,
    output Term
);

`ifdef __ICARUS__

reg [31:0] FLASHDATA;
reg [31:0] FLASH_CONTROL;

reg [31:0] data_out;
reg [2:0] TERM_COUNTER;
reg Term_Int;
wire CYCLE_ACTIVE;

localparam FLASH_CONTROL_REG = 24'h080000;
localparam FLASH_DATA_REG = 24'h000000;

assign nCYCLE_ACTIVE = ~FLASH_DATA_WR & FLASH_DATA_RD_;
assign Term = Term_Int;

always @(posedge CLK or negedge nRST) begin

	if (~nRST) begin
		FLASHDATA <= 32'h00000000;
		FLASH_CONTROL <= 32'h00000000;
		TERM_COUNTER <= 0;
		Term_Int <= 0;
	end

	if (FLASH_DATA_RD_) begin
		case (FLASH_ADDR)
			FLASH_DATA_REG		: FLASHDATA 	<= FLASH_DATA_IN;
			FLASH_CONTROL_REG	: FLASH_CONTROL <= FLASH_DATA_IN;
		endcase
	end

	if (FLASH_DATA_WR) begin
		case (FLASH_ADDR)
			FLASH_DATA_REG		: data_out <= FLASHDATA;
			FLASH_CONTROL_REG	: data_out <= FLASH_CONTROL;
		endcase
	end

	if (~nCYCLE_ACTIVE) begin
		if (TERM_COUNTER == 3'd3)
      		Term_Int <= 1'b1;
		else
			TERM_COUNTER <= TERM_COUNTER + 1;
	end
	else
		Term_Int <= 0;
end

`elsif ALTERA_RESERVED_QIS

 test u0 (
		.clk_clk                                 (SCCLK),
		.reset_reset_n                           (nRST),
		.bridge_0_external_interface_address     (FLASH_ADDR),
		.bridge_0_external_interface_byte_enable (4'b1111),
		.bridge_0_external_interface_read        (~FLASH_DATA_RD_),
		.bridge_0_external_interface_write       (FLASH_DATA_WR),
		.bridge_0_external_interface_write_data  (FLASH_DATA_IN),
		.bridge_0_external_interface_acknowledge (Term),
		.bridge_0_external_interface_read_data   (FLASH_DATA_OUT)
	);
`endif

endmodule