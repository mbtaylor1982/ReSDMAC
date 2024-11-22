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

	reg CLK_6_25M;
	reg Clk_12_5M;

	always @(posedge CLK or negedge nRST) begin
		if (~nRST) begin
			CLK_6_25M <= 0;
			Clk_12_5M <= 0;
		end
		else begin
			Clk_12_5M <= ~Clk_12_5M;
			if (Clk_12_5M)
				CLK_6_25M <= ~CLK_6_25M;
		end
	end


`ifdef ALTERA_RESERVED_QIS

	localparam four_byte_transfer = 4'b1111;

	reg [31:0] LATCHED_FLASH_DATA_OUT;
	reg LATCHED_FLASH_DATA_WR;
	reg [2:0] WriteCycleClks;
	wire [31:0] data;

	always @(posedge CLK or negedge nRST) begin
		if (~nRST) begin
			LATCHED_FLASH_DATA_WR <= 1'b0;
			WriteCycleClks <= 3'b0;
		end
		else begin
			if (FLASH_DATA_WR) begin
				WriteCycleClks <= WriteCycleClks + 1;
				if (WriteCycleClks >= 3)
					LATCHED_FLASH_DATA_WR <= FLASH_DATA_WR;
			end
			else begin
				WriteCycleClks <= 3'b0;
				LATCHED_FLASH_DATA_WR <= 1'b0;
			end
		end
	end

	always @(negedge CLK or negedge nRST) begin
		if (~nRST)
			LATCHED_FLASH_DATA_OUT <= 32'h00000000;
		else if(Term)
			LATCHED_FLASH_DATA_OUT <= data;
	end

	assign FLASH_DATA_OUT = LATCHED_FLASH_DATA_OUT;

	generate
		case(`DEVICE)
			"10M02SCU169C8G" : begin
				flash_interface_10M02SCU169C8G flash_interface (
					.clk_clk                        (CLK_6_25M), //10M02 requires a clk rate of 7MHz or less.
					.reset_reset_n                  (nRST),
					.external_interface_address     (FLASH_ADDR),
					.external_interface_read        (~FLASH_DATA_RD_),
					.external_interface_read_data   (data),
					.external_interface_write       (LATCHED_FLASH_DATA_WR),
					.external_interface_write_data  (FLASH_DATA_IN),
					.external_interface_acknowledge (Term),
					.external_interface_byte_enable (four_byte_transfer)
				);
			end
			"10M04SCU169C8G" : begin
				flash_interface_10M04SCU169C8G flash_interface (
					.clk_clk                        (CLK),
					.reset_reset_n                  (nRST),
					.external_interface_address     (FLASH_ADDR),
					.external_interface_read        (~FLASH_DATA_RD_),
					.external_interface_read_data   (data),
					.external_interface_write       (LATCHED_FLASH_DATA_WR),
					.external_interface_write_data  (FLASH_DATA_IN),
					.external_interface_acknowledge (Term),
					.external_interface_byte_enable (four_byte_transfer)
				);
			end
			"10M16SCU169C8G" : begin
				flash_interface_10M16SCU169C8G flash_interface (
					.clk_clk                        (CLK),
					.reset_reset_n                  (nRST),
					.external_interface_address     (FLASH_ADDR),
					.external_interface_read        (~FLASH_DATA_RD_),
					.external_interface_read_data   (data),
					.external_interface_write       (LATCHED_FLASH_DATA_WR),
					.external_interface_write_data  (FLASH_DATA_IN),
					.external_interface_acknowledge (Term),
					.external_interface_byte_enable (four_byte_transfer)
				);
			end
		endcase
	endgenerate

`elsif __ICARUS__

	reg [31:0] FLASHDATA;
	reg [31:0] FLASH_CONTROL;

	reg [31:0] data_out;
	reg [2:0] TERM_COUNTER;
	reg Term_Int;
	wire CYCLE_ACTIVE;

	localparam FLASH_DATA_REG = {4'h0, 4'b0xxx , 16'hxxxx}; //	$000000 -> $07FFFF
	localparam FLASH_CONTROL_REG = {20'h08000, 4'b0xxx}; 	//	$080000 -> $080007

	assign nCYCLE_ACTIVE = ~FLASH_DATA_WR & FLASH_DATA_RD_;
	assign Term = Term_Int;
	assign FLASH_DATA_OUT = data_out;

	always @(posedge CLK or negedge nRST) begin
		if (~nRST) begin
			FLASHDATA 		<= 32'h00000000;
			FLASH_CONTROL 	<= 32'h00000000;
			data_out		<= 32'h00000000;
		end

		if (FLASH_DATA_WR) begin
			casex (FLASH_ADDR)
				FLASH_DATA_REG		: FLASHDATA 	<= FLASH_DATA_IN;
				FLASH_CONTROL_REG	: FLASH_CONTROL <= FLASH_DATA_IN;
			endcase
		end

		if (~FLASH_DATA_RD_) begin
			casex (FLASH_ADDR)
				FLASH_DATA_REG		: data_out <= FLASHDATA;
				FLASH_CONTROL_REG	: data_out <= FLASH_CONTROL;
			endcase
		end

	end

	always @(posedge CLK or negedge nRST) begin
		if (~nRST) begin
			TERM_COUNTER 	<= 3'b0;
			Term_Int 		<= 1'b0;
		end

		if (~nCYCLE_ACTIVE) begin
			if (TERM_COUNTER == 3'd3)
				Term_Int <= 1'b1;
			else
				TERM_COUNTER <= TERM_COUNTER + 1;
		end
		else begin
			Term_Int <= 0;
			TERM_COUNTER 	<= 3'b0;
		end
	end
`endif

endmodule