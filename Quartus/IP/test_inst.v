	test u0 (
		.bridge_0_external_interface_address     (<connected-to-bridge_0_external_interface_address>),     // bridge_0_external_interface.address
		.bridge_0_external_interface_byte_enable (<connected-to-bridge_0_external_interface_byte_enable>), //                            .byte_enable
		.bridge_0_external_interface_read        (<connected-to-bridge_0_external_interface_read>),        //                            .read
		.bridge_0_external_interface_write       (<connected-to-bridge_0_external_interface_write>),       //                            .write
		.bridge_0_external_interface_write_data  (<connected-to-bridge_0_external_interface_write_data>),  //                            .write_data
		.bridge_0_external_interface_acknowledge (<connected-to-bridge_0_external_interface_acknowledge>), //                            .acknowledge
		.bridge_0_external_interface_read_data   (<connected-to-bridge_0_external_interface_read_data>),   //                            .read_data
		.clk_clk                                 (<connected-to-clk_clk>),                                 //                         clk.clk
		.reset_reset_n                           (<connected-to-reset_reset_n>)                            //                       reset.reset_n
	);

