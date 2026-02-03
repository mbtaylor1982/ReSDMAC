//ReSDMAC © 2024 by Michael Taylor is licensed under Creative Commons Attribution-ShareAlike 4.0 International. To view a copy of this license, visit https://creativecommons.org/licenses/by-sa/4.0/

// Phase Counter Module
// Tracks position within 25MHz cycle when running at 100MHz
// Counter increments every 10ns, dividing the 40ns 25MHz period into 4 phases

module phase_counter (
    input CLK100,           // 100MHz clock input
    input nRESET,           // Active-low reset

    output reg [1:0] phase  // Current phase (0-3), indicates which quarter-cycle we're in
);

// 2-bit counter cycles 0→1→2→3→0 every 40ns (one 25MHz period)
// Phase value indicates which quarter-cycle we're in:
//   phase=0: 0-10ns (0-89°)  |  phase=1: 10-20ns (90-179°)
//   phase=2: 20-30ns (180-269°)  |  phase=3: 30-40ns (270-359°)
//
// Phase transitions on posedge CLK100: 0→1@10ns, 1→2@20ns, 2→3@30ns, 3→0@40ns
//
// Note: "phase==N" in clocked logic sees the value BEFORE the edge.
//       Example: at 10ns posedge, "phase==0" is true (value from 0-10ns interval)
//
// Original 25MHz clock mappings:
//   posedge CLK    (0°/360°)  → posedge CLK100 when phase==3  (0ns, 40ns...)
//   posedge CLK45  (45°)      → negedge CLK100 when phase==0  (5ns, 45ns...)
//   posedge CLK90  (90°)      → posedge CLK100 when phase==0  (10ns, 50ns...)
//   posedge CLK135 (135°)     → negedge CLK100 when phase==1  (15ns, 55ns...)
//   negedge CLK    (180°)     → posedge CLK100 when phase==1  (20ns, 60ns...)
//   negedge CLK45  (225°)     → negedge CLK100 when phase==2  (25ns, 65ns...)
//   negedge CLK90  (270°)     → posedge CLK100 when phase==2  (30ns, 70ns...)
//   negedge CLK135 (315°)     → negedge CLK100 when phase==3  (35ns, 75ns...)

always @(posedge CLK100 or negedge nRESET) begin
    if (~nRESET)
        phase <= 2'b11;  // Initialize to phase 3 to align with 0° of 25MHz cycle
    else
        phase <= phase + 2'b01;  // Wraps automatically at 2'b11 + 1 = 2'b00
end

endmodule
