//ReSDMAC © 2024 by Michael Taylor is licensed under Creative Commons Attribution-ShareAlike 4.0 International. To view a copy of this license, visit https://creativecommons.org/licenses/by-sa/4.0/

// phase_defs.vh
// Phase counter value definitions for 100MHz clock timing
// Include this file in any module that needs to check phase values
//
// These correspond to the phase counter output in phase_counter.v
// See phase_counter.v for detailed timing diagrams and clock mappings

`ifndef PHASE_DEFS_VH
`define PHASE_DEFS_VH

// Phase counter values - each phase covers one quarter of the 25MHz cycle
`define PHASE_0 2'b00  // Phase 0: 0-10ns interval (0-89° of 25MHz cycle)
`define PHASE_1 2'b01  // Phase 1: 10-20ns interval (90-179° of 25MHz cycle)
`define PHASE_2 2'b10  // Phase 2: 20-30ns interval (180-269° of 25MHz cycle)
`define PHASE_3 2'b11  // Phase 3: 30-40ns interval (270-359° of 25MHz cycle)

`endif // PHASE_DEFS_VH
