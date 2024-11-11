	component flash_interface_10M16SCU169C8G is
		port (
			clk_clk                        : in  std_logic                     := 'X';             -- clk
			external_interface_address     : in  std_logic_vector(23 downto 0) := (others => 'X'); -- address
			external_interface_byte_enable : in  std_logic_vector(3 downto 0)  := (others => 'X'); -- byte_enable
			external_interface_read        : in  std_logic                     := 'X';             -- read
			external_interface_write       : in  std_logic                     := 'X';             -- write
			external_interface_write_data  : in  std_logic_vector(31 downto 0) := (others => 'X'); -- write_data
			external_interface_acknowledge : out std_logic;                                        -- acknowledge
			external_interface_read_data   : out std_logic_vector(31 downto 0);                    -- read_data
			reset_reset_n                  : in  std_logic                     := 'X'              -- reset_n
		);
	end component flash_interface_10M16SCU169C8G;

	u0 : component flash_interface_10M16SCU169C8G
		port map (
			clk_clk                        => CONNECTED_TO_clk_clk,                        --                clk.clk
			external_interface_address     => CONNECTED_TO_external_interface_address,     -- external_interface.address
			external_interface_byte_enable => CONNECTED_TO_external_interface_byte_enable, --                   .byte_enable
			external_interface_read        => CONNECTED_TO_external_interface_read,        --                   .read
			external_interface_write       => CONNECTED_TO_external_interface_write,       --                   .write
			external_interface_write_data  => CONNECTED_TO_external_interface_write_data,  --                   .write_data
			external_interface_acknowledge => CONNECTED_TO_external_interface_acknowledge, --                   .acknowledge
			external_interface_read_data   => CONNECTED_TO_external_interface_read_data,   --                   .read_data
			reset_reset_n                  => CONNECTED_TO_reset_reset_n                   --              reset.reset_n
		);

