//ReSDMAC © 2024 by Michael Taylor is licensed under Creative Commons Attribution-ShareAlike 4.0 International. To view a copy of this license, visit https://creativecommons.org/licenses/by-sa/4.0/

`include "../phase_defs.vh"

module registers_flash(
    input         i_CLK100,
    input  [1:0]  i_PHASE,
    input         i_RST_n,
    input         i_DS_n,
    input         i_AS_n,
    input  [23:0] i_FLASH_ADDR,
    input  [31:0] i_FLASH_DATA_IN,
    input         i_FLASH_DATA_RD_n,
    input         i_FLASH_DATA_WR,
    output [31:0] o_FLASH_DATA_OUT,
    output reg    o_TERM
);

`ifdef ALTERA_RESERVED_QIS

    localparam four_byte_transfer = 4'b1111;

    reg [31:0] latched_flash_data_out;
    reg [31:0] latched_flash_data_in;
    reg [23:0] latched_addr;
    reg        write;
    reg        read;
    wire [31:0] data;
    wire        ack;

    always @(posedge i_CLK100 or negedge i_RST_n) begin
        if (~i_RST_n) begin
            latched_addr           <= 24'h000000;
            latched_flash_data_out <= 32'h00000000;
            latched_flash_data_in  <= 32'h00000000;
            o_TERM                 <= 1'b0;
        end
        else if (i_PHASE == `PHASE_3) begin
            o_TERM <= ack;
            if (~i_AS_n)
                latched_addr <= i_FLASH_ADDR;
            if (~i_FLASH_DATA_RD_n && ack)
                latched_flash_data_out <= data;
            if (i_FLASH_DATA_WR && ~i_DS_n)
                latched_flash_data_in <= i_FLASH_DATA_IN;
        end
    end

    always @(posedge i_CLK100 or negedge i_RST_n) begin
        if (~i_RST_n) begin
            write <= 1'b0;
            read  <= 1'b0;
        end
        else if (i_PHASE == `PHASE_1) begin
            read  <= (~i_FLASH_DATA_RD_n && ~i_DS_n);
            write <= (i_FLASH_DATA_WR    && ~i_DS_n);
        end
    end

    assign o_FLASH_DATA_OUT = latched_flash_data_out;

    generate
        case(`DEVICE)
            "10M02SCU169C8G" : assign data = latched_flash_data_in;
            "10M04SCU169C8G" : begin
                flash_interface_10M04SCU169C8G flash_interface (
                    .clk_clk                        (i_CLK100),
                    .reset_reset_n                  (i_RST_n),
                    .external_interface_address     (latched_addr),
                    .external_interface_read        (read),
                    .external_interface_read_data   (data),
                    .external_interface_write       (write),
                    .external_interface_write_data  (latched_flash_data_in),
                    .external_interface_acknowledge (ack),
                    .external_interface_byte_enable (four_byte_transfer)
                );
            end
            "10M16SCU169C8G" : begin
                flash_interface_10M16SCU169C8G flash_interface (
                    .clk_clk                        (i_CLK100),
                    .reset_reset_n                  (i_RST_n),
                    .external_interface_address     (latched_addr),
                    .external_interface_read        (read),
                    .external_interface_read_data   (data),
                    .external_interface_write       (write),
                    .external_interface_write_data  (latched_flash_data_in),
                    .external_interface_acknowledge (ack),
                    .external_interface_byte_enable (four_byte_transfer)
                );
            end
        endcase
    endgenerate

`elsif __ICARUS__

    reg [31:0] flashdata;
    reg [31:0] flash_control;
    reg [31:0] data_out;
    reg [2:0]  term_counter;

    wire ncycle_active;

    localparam FLASH_DATA_REG    = {4'h0, 4'b0xxx, 16'hxxxx}; // $000000 -> $07FFFF
    localparam FLASH_CONTROL_REG = {20'h08000, 4'b0xxx};       // $080000 -> $080007

    assign ncycle_active    = ~i_FLASH_DATA_WR & i_FLASH_DATA_RD_n;
    assign o_FLASH_DATA_OUT = data_out;

    always @(posedge i_CLK100 or negedge i_RST_n) begin
        if (~i_RST_n) begin
            flashdata     <= 32'h00000000;
            flash_control <= 32'h00000000;
            data_out      <= 32'h00000000;
        end
        else if (i_PHASE == `PHASE_3) begin
            if (i_FLASH_DATA_WR) begin
                casex (i_FLASH_ADDR)
                    FLASH_DATA_REG    : flashdata     <= i_FLASH_DATA_IN;
                    FLASH_CONTROL_REG : flash_control <= i_FLASH_DATA_IN;
                endcase
            end
            else if (~i_FLASH_DATA_RD_n) begin
                casex (i_FLASH_ADDR)
                    FLASH_DATA_REG    : data_out <= flashdata;
                    FLASH_CONTROL_REG : data_out <= flash_control;
                endcase
            end
        end
    end

    always @(posedge i_CLK100 or negedge i_RST_n) begin
        if (~i_RST_n) begin
            term_counter <= 3'b0;
            o_TERM       <= 1'b0;
        end
        else if (i_PHASE == `PHASE_3) begin
            if (~ncycle_active) begin
                if (term_counter == 3'd3)
                    o_TERM <= 1'b1;
                else
                    term_counter <= term_counter + 1;
            end
            else begin
                o_TERM       <= 1'b0;
                term_counter <= 3'b0;
            end
        end
    end

`endif

endmodule
