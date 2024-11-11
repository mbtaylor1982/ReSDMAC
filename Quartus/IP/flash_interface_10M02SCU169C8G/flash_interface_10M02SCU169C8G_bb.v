
module flash_interface_10M02SCU169C8G (
	clk_clk,
	external_interface_address,
	external_interface_byte_enable,
	external_interface_read,
	external_interface_write,
	external_interface_write_data,
	external_interface_acknowledge,
	external_interface_read_data,
	reset_reset_n);	

	input		clk_clk;
	input	[23:0]	external_interface_address;
	input	[3:0]	external_interface_byte_enable;
	input		external_interface_read;
	input		external_interface_write;
	input	[31:0]	external_interface_write_data;
	output		external_interface_acknowledge;
	output	[31:0]	external_interface_read_data;
	input		reset_reset_n;
endmodule
