//ReSDMAC © 2024 by Michael Taylor is licensed under Creative Commons Attribution-ShareAlike 4.0 International. To view a copy of this license, visit https://creativecommons.org/licenses/by-sa/4.0/

// Phase Counter Module
// Tracks position within 25MHz cycle when running at 100MHz
// Provides phase indicators equivalent to original CLK0/45/90/135 degree clocks

module phase_counter (
    input CLK100,           // 100MHz clock input
    input nRESET,           // Active-low reset

    output reg [1:0] phase, // Current phase (0-3)
    output phase_0,         // Phase 0 indicator (equivalent to CLK at 0°)
    output phase_90,        // Phase 1 indicator (equivalent to CLK at 90°)
    output phase_180,       // Phase 2 indicator (equivalent to CLK at 180°)
    output phase_270        // Phase 3 indicator (equivalent to CLK at 270°)
);

// 2-bit counter that cycles 0->1->2->3->0
// At 100MHz, this creates 4 phases per 25MHz cycle:
// phase_0:   edges at 0ns, 40ns, 80ns...   (original CLK)
// phase_90:  edges at 10ns, 50ns, 90ns...  (original CLK45)
// phase_180: edges at 20ns, 60ns, 100ns... (original CLK90)
// phase_270: edges at 30ns, 70ns, 110ns... (original CLK135)

always @(posedge CLK100 or negedge nRESET) begin
    if (~nRESET)
        phase <= 2'b00;
    else
        phase <= phase + 2'b01;  // Wraps automatically at 2'b11 + 1 = 2'b00
end

// Decode phase indicators
assign phase_0   = (phase == 2'b00);
assign phase_90  = (phase == 2'b01);
assign phase_180 = (phase == 2'b10);
assign phase_270 = (phase == 2'b11);

endmodule
