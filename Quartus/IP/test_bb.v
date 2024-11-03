
module test (
	bridge_0_external_interface_address,
	bridge_0_external_interface_byte_enable,
	bridge_0_external_interface_read,
	bridge_0_external_interface_write,
	bridge_0_external_interface_write_data,
	bridge_0_external_interface_acknowledge,
	bridge_0_external_interface_read_data,
	clk_clk,
	reset_reset_n);	

	input	[23:0]	bridge_0_external_interface_address;
	input	[3:0]	bridge_0_external_interface_byte_enable;
	input		bridge_0_external_interface_read;
	input		bridge_0_external_interface_write;
	input	[31:0]	bridge_0_external_interface_write_data;
	output		bridge_0_external_interface_acknowledge;
	output	[31:0]	bridge_0_external_interface_read_data;
	input		clk_clk;
	input		reset_reset_n;
endmodule
