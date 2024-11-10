	flash_interface u0 (
		.clk_clk                        (<connected-to-clk_clk>),                        //                clk.clk
		.external_interface_address     (<connected-to-external_interface_address>),     // external_interface.address
		.external_interface_byte_enable (<connected-to-external_interface_byte_enable>), //                   .byte_enable
		.external_interface_read        (<connected-to-external_interface_read>),        //                   .read
		.external_interface_write       (<connected-to-external_interface_write>),       //                   .write
		.external_interface_write_data  (<connected-to-external_interface_write_data>),  //                   .write_data
		.external_interface_acknowledge (<connected-to-external_interface_acknowledge>), //                   .acknowledge
		.external_interface_read_data   (<connected-to-external_interface_read_data>),   //                   .read_data
		.reset_reset_n                  (<connected-to-reset_reset_n>)                   //              reset.reset_n
	);

