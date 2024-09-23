## Generated SDC file "RESDMAC.out.sdc"

## Copyright (C) 2023  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions 
## and other software and tools, and any partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Intel Program License 
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel FPGA IP License Agreement, or other applicable license
## agreement, including, without limitation, that your use is for
## the sole purpose of programming logic devices manufactured by
## Intel and sold by Intel or its authorized distributors.  Please
## refer to the applicable agreement for further details, at
## https://fpgasoftware.intel.com/eula.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 22.1std.2 Build 922 07/20/2023 SC Lite Edition"

## DATE    "Tue Sep  3 18:44:21 2024"

##
## DEVICE  "10M16SCU169C8G"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {altera_reserved_tck} -period 100.000 -waveform { 0.000 50.000 } [get_ports {altera_reserved_tck}]
create_clock -name {SCLK} -period 40.000 -waveform { 0.000 20.000 } [get_ports {SCLK}]


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name {PLL:u_PLL|attpll:attpll_inst|altpll:altpll_component|attpll_altpll:auto_generated|wire_pll1_clk[0]} -source [get_pins {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50/1 -multiply_by 1 -phase 45/1 -master_clock {SCLK} [get_pins {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[0]}] 
create_generated_clock -name {PLL:u_PLL|attpll:attpll_inst|altpll:altpll_component|attpll_altpll:auto_generated|wire_pll1_clk[1]} -source [get_pins {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50/1 -multiply_by 1 -phase 90/1 -master_clock {SCLK} [get_pins {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[1]}] 
create_generated_clock -name {PLL:u_PLL|attpll:attpll_inst|altpll:altpll_component|attpll_altpll:auto_generated|wire_pll1_clk[2]} -source [get_pins {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50/1 -multiply_by 1 -phase 135/1 -master_clock {SCLK} [get_pins {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[2]}] 


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************



#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************

set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 


#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

