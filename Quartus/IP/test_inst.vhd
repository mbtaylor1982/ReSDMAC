	component test is
		port (
			bridge_0_external_interface_address     : in  std_logic_vector(23 downto 0) := (others => 'X'); -- address
			bridge_0_external_interface_byte_enable : in  std_logic_vector(3 downto 0)  := (others => 'X'); -- byte_enable
			bridge_0_external_interface_read        : in  std_logic                     := 'X';             -- read
			bridge_0_external_interface_write       : in  std_logic                     := 'X';             -- write
			bridge_0_external_interface_write_data  : in  std_logic_vector(31 downto 0) := (others => 'X'); -- write_data
			bridge_0_external_interface_acknowledge : out std_logic;                                        -- acknowledge
			bridge_0_external_interface_read_data   : out std_logic_vector(31 downto 0);                    -- read_data
			clk_clk                                 : in  std_logic                     := 'X';             -- clk
			reset_reset_n                           : in  std_logic                     := 'X'              -- reset_n
		);
	end component test;

	u0 : component test
		port map (
			bridge_0_external_interface_address     => CONNECTED_TO_bridge_0_external_interface_address,     -- bridge_0_external_interface.address
			bridge_0_external_interface_byte_enable => CONNECTED_TO_bridge_0_external_interface_byte_enable, --                            .byte_enable
			bridge_0_external_interface_read        => CONNECTED_TO_bridge_0_external_interface_read,        --                            .read
			bridge_0_external_interface_write       => CONNECTED_TO_bridge_0_external_interface_write,       --                            .write
			bridge_0_external_interface_write_data  => CONNECTED_TO_bridge_0_external_interface_write_data,  --                            .write_data
			bridge_0_external_interface_acknowledge => CONNECTED_TO_bridge_0_external_interface_acknowledge, --                            .acknowledge
			bridge_0_external_interface_read_data   => CONNECTED_TO_bridge_0_external_interface_read_data,   --                            .read_data
			clk_clk                                 => CONNECTED_TO_clk_clk,                                 --                         clk.clk
			reset_reset_n                           => CONNECTED_TO_reset_reset_n                            --                       reset.reset_n
		);

