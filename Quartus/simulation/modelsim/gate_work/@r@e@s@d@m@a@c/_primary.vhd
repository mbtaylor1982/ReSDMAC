library verilog;
use verilog.vl_types.all;
entity RESDMAC is
    port(
        \_INT\          : out    vl_logic;
        SIZ1            : out    vl_logic;
        R_W             : inout  vl_logic;
        \_AS\           : inout  vl_logic;
        \_DS\           : inout  vl_logic;
        \_DSACK_O\      : out    vl_logic_vector(1 downto 0);
        \_DSACK_I\      : in     vl_logic_vector(1 downto 0);
        DATA            : inout  vl_logic_vector(31 downto 0);
        \_STERM\        : in     vl_logic;
        SCLK            : in     vl_logic;
        \_CS\           : in     vl_logic;
        \_RST\          : in     vl_logic;
        \_BERR\         : in     vl_logic;
        ADDR            : in     vl_logic_vector(6 downto 2);
        \_BR\           : out    vl_logic;
        \_BG\           : in     vl_logic;
        \_BGACK_O\      : out    vl_logic;
        \_BGACK_I\      : in     vl_logic;
        \_DMAEN\        : out    vl_logic;
        \_DREQ\         : in     vl_logic;
        \_DACK\         : out    vl_logic;
        INTA            : in     vl_logic;
        \_IOR\          : out    vl_logic;
        \_IOW\          : out    vl_logic;
        \_CSS\          : out    vl_logic;
        PD_PORT         : inout  vl_logic_vector(7 downto 0);
        \_LED_RD\       : out    vl_logic;
        \_LED_WR\       : out    vl_logic;
        \_LED_DMA\      : out    vl_logic;
        \OWN_\          : out    vl_logic;
        \DATA_OE_\      : out    vl_logic;
        \PDATA_OE_\     : out    vl_logic
    );
end RESDMAC;
