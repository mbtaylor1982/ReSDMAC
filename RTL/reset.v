/*
ReSDMAC © 2026 by Michael Taylor is licensed under Creative Commons Attribution-ShareAlike 4.0 International. 
To view a copy of this license, visit https://creativecommons.org/licenses/by-sa/4.0/
*/

module global_reset_with_pll #(
    parameter integer LOCK_SYNC_STAGES = 2,  // sync PLL locked into clk domain
    parameter integer RESET_STAGES     = 2   // sync deassertion depth for reset
)(
    input  wire clk,              // clk100 from PLL
    input  wire reset_n_async,     // external reset pin (active-low)
    input  wire pll_locked,        // PLL lock indicator (often async)
    output wire reset_n_sync       // global reset (active-low), sync deassert
);

    // 1) Synchronize pll_locked into clk domain
    (* ASYNC_REG = "TRUE" *) reg [LOCK_SYNC_STAGES-1:0] lock_sr;

    always @(posedge clk or negedge reset_n_async) begin
        if (!reset_n_async)
            lock_sr <= {LOCK_SYNC_STAGES{1'b0}};
        else
            lock_sr <= {lock_sr[LOCK_SYNC_STAGES-2:0], pll_locked};
    end

    wire pll_locked_sync = lock_sr[LOCK_SYNC_STAGES-1];

    // 2) Allow reset release only when:
    //    - external reset is deasserted AND
    //    - PLL is locked (synchronized)
    wire reset_release_ok = reset_n_async & pll_locked_sync;

    // 3) Async assert, sync deassert reset generator
    (* ASYNC_REG = "TRUE" *) reg [RESET_STAGES-1:0] rst_sr;

    always @(posedge clk or negedge reset_release_ok) begin
        if (!reset_release_ok)
            rst_sr <= {RESET_STAGES{1'b0}}; // assert reset immediately
        else
            rst_sr <= {rst_sr[RESET_STAGES-2:0], 1'b1}; // release synchronously
    end

    assign reset_n_sync = rst_sr[RESET_STAGES-1];

endmodule