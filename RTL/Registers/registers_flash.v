//ReSDMAC © 2024 by Michael Taylor is licensed under Creative Commons Attribution-ShareAlike 4.0 International. To view a copy of this license, visit https://creativecommons.org/licenses/by-sa/4.0/
module registers_flash(
    input CLK,
    input nRST,
	input n_DS,
	input n_AS,
    input [23:0] FLASH_ADDR,
    input [31:0] FLASH_DATA_IN,
    input FLASH_DATA_RD_,
    input FLASH_DATA_WR,
    output [31:0] FLASH_DATA_OUT,
    output reg Term
);



`ifdef ALTERA_RESERVED_QIS
	localparam four_byte_transfer = 4'b1111;

	reg [31:0] LATCHED_FLASH_DATA_OUT;
	reg [31:0] LATCHED_FLASH_DATA_IN;
	reg [23:0] LATCHED_ADDR;
	reg write;
	reg read;
	wire [31:0] data;
	wire ack;

	always @(posedge CLK or negedge nRST) begin
	if (~nRST)
		LATCHED_ADDR <= 32'h00000000;
	else if(~n_AS)
		LATCHED_ADDR <= FLASH_ADDR;
	end

	always @(posedge CLK or negedge nRST) begin
	if (~nRST)
		LATCHED_FLASH_DATA_OUT <= 32'h00000000;
	else if(~FLASH_DATA_RD_ & ack)
		LATCHED_FLASH_DATA_OUT <= data;
	end

	always @(posedge CLK or negedge nRST) begin
	if (~nRST)
		LATCHED_FLASH_DATA_IN <= 32'h00000000;
	else if(FLASH_DATA_WR & ~n_DS)
		LATCHED_FLASH_DATA_IN <= FLASH_DATA_IN;
	end

	always @(posedge CLK or negedge nRST) begin
	if (~nRST)
		Term <= 1'b0;
	else begin
		Term <= ack;
	end;
	end

	always @(posedge CLK or negedge nRST) begin
	if (~nRST) begin
		write 	<= 1'b0;
		read 	<= 1'b0;
	end
	else begin
		read 	<= (~FLASH_DATA_RD_ & ~n_DS);
		write 	<= (FLASH_DATA_WR 	& ~n_DS);
	end
	end

	assign FLASH_DATA_OUT = LATCHED_FLASH_DATA_OUT;

	generate
		case(`DEVICE)
			"10M02SCU169C8G" : assign data = LATCHED_FLASH_DATA_IN;
			"10M04SCU169C8G" : begin
				flash_interface_10M04SCU169C8G flash_interface (
					.clk_clk                        (CLK),
					.reset_reset_n                  (nRST),
					.external_interface_address     (LATCHED_ADDR),
					.external_interface_read        (read),
					.external_interface_read_data   (data),
					.external_interface_write       (write),
					.external_interface_write_data  (LATCHED_FLASH_DATA_IN),
					.external_interface_acknowledge (ack),
					.external_interface_byte_enable (four_byte_transfer)
				);
			end
			"10M16SCU169C8G" : begin
				flash_interface_10M16SCU169C8G flash_interface (
					.clk_clk                        (CLK),
					.reset_reset_n                  (nRST),
					.external_interface_address     (LATCHED_ADDR),
					.external_interface_read        (read),
					.external_interface_read_data   (data),
					.external_interface_write       (write),
					.external_interface_write_data  (LATCHED_FLASH_DATA_IN),
					.external_interface_acknowledge (ack),
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

	wire CYCLE_ACTIVE;

	localparam FLASH_DATA_REG = {4'h0, 4'b0xxx , 16'hxxxx}; //	$000000 -> $07FFFF
	localparam FLASH_CONTROL_REG = {20'h08000, 4'b0xxx}; 	//	$080000 -> $080007

	assign nCYCLE_ACTIVE = ~FLASH_DATA_WR & FLASH_DATA_RD_;
	
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
			Term 		<= 1'b0;
		end

		if (~nCYCLE_ACTIVE) begin
			if (TERM_COUNTER == 3'd3)
				Term <= 1'b1;
			else
				TERM_COUNTER <= TERM_COUNTER + 1;
		end
		else begin
			Term <= 0;
			TERM_COUNTER 	<= 3'b0;
		end
	end
`endif



endmodule