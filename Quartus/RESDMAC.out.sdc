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

## DATE    "Tue Nov 26 23:45:04 2024"

##
## DEVICE  "10M02SCU169C8G"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {u_registers|u_registers_flash|flash_interface|onchip_flash|altera_onchip_flash_block|ufm_block|osc} -period 181.818 -waveform { 0.000 90.909 } [get_pins {u_registers|u_registers_flash|flash_interface|onchip_flash|altera_onchip_flash_block|ufm_block|osc}]
create_clock -name {SCLK} -period 40.000 -waveform { 0.000 20.000 } [get_ports {SCLK}]
create_clock -name {CLK_6_25M} -period 160.000 -waveform { 0.000 80.000 } [get_registers {registers:u_registers|registers_flash:u_registers_flash|CLK_6_25M}]


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[1]} -source [get_pins {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50/1 -multiply_by 1 -phase 90/1 -master_clock {SCLK} [get_pins { u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[1] }] 
create_generated_clock -name {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[2]} -source [get_pins {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50/1 -multiply_by 1 -phase 135/1 -master_clock {SCLK} [get_pins {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[2]}] 


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[2]}] -rise_to [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[2]}]  0.070  
set_clock_uncertainty -rise_from [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[2]}] -fall_to [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[2]}]  0.070  
set_clock_uncertainty -rise_from [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[2]}] -rise_to [get_clocks {SCLK}] -setup 0.170  
set_clock_uncertainty -rise_from [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[2]}] -rise_to [get_clocks {SCLK}] -hold 0.150  
set_clock_uncertainty -rise_from [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[2]}] -fall_to [get_clocks {SCLK}] -setup 0.170  
set_clock_uncertainty -rise_from [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[2]}] -fall_to [get_clocks {SCLK}] -hold 0.150  
set_clock_uncertainty -rise_from [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[2]}] -rise_to [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[1]}]  0.070  
set_clock_uncertainty -rise_from [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[2]}] -fall_to [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[1]}]  0.070  
set_clock_uncertainty -fall_from [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[2]}] -rise_to [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[2]}]  0.070  
set_clock_uncertainty -fall_from [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[2]}] -fall_to [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[2]}]  0.070  
set_clock_uncertainty -fall_from [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[2]}] -rise_to [get_clocks {SCLK}] -setup 0.170  
set_clock_uncertainty -fall_from [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[2]}] -rise_to [get_clocks {SCLK}] -hold 0.150  
set_clock_uncertainty -fall_from [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[2]}] -fall_to [get_clocks {SCLK}] -setup 0.170  
set_clock_uncertainty -fall_from [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[2]}] -fall_to [get_clocks {SCLK}] -hold 0.150  
set_clock_uncertainty -fall_from [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[2]}] -rise_to [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[1]}]  0.070  
set_clock_uncertainty -fall_from [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[2]}] -fall_to [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[1]}]  0.070  
set_clock_uncertainty -rise_from [get_clocks {CLK_6_25M}] -rise_to [get_clocks {CLK_6_25M}]  0.070  
set_clock_uncertainty -rise_from [get_clocks {CLK_6_25M}] -fall_to [get_clocks {CLK_6_25M}]  0.070  
set_clock_uncertainty -rise_from [get_clocks {CLK_6_25M}] -rise_to [get_clocks {u_registers|u_registers_flash|flash_interface|onchip_flash|altera_onchip_flash_block|ufm_block|osc}]  0.070  
set_clock_uncertainty -rise_from [get_clocks {CLK_6_25M}] -fall_to [get_clocks {u_registers|u_registers_flash|flash_interface|onchip_flash|altera_onchip_flash_block|ufm_block|osc}]  0.070  
set_clock_uncertainty -rise_from [get_clocks {CLK_6_25M}] -rise_to [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[1]}] -setup 0.160  
set_clock_uncertainty -rise_from [get_clocks {CLK_6_25M}] -rise_to [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[1]}] -hold 0.170  
set_clock_uncertainty -rise_from [get_clocks {CLK_6_25M}] -fall_to [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[1]}] -setup 0.160  
set_clock_uncertainty -rise_from [get_clocks {CLK_6_25M}] -fall_to [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[1]}] -hold 0.170  
set_clock_uncertainty -fall_from [get_clocks {CLK_6_25M}] -rise_to [get_clocks {CLK_6_25M}]  0.070  
set_clock_uncertainty -fall_from [get_clocks {CLK_6_25M}] -fall_to [get_clocks {CLK_6_25M}]  0.070  
set_clock_uncertainty -fall_from [get_clocks {CLK_6_25M}] -rise_to [get_clocks {u_registers|u_registers_flash|flash_interface|onchip_flash|altera_onchip_flash_block|ufm_block|osc}]  0.070  
set_clock_uncertainty -fall_from [get_clocks {CLK_6_25M}] -fall_to [get_clocks {u_registers|u_registers_flash|flash_interface|onchip_flash|altera_onchip_flash_block|ufm_block|osc}]  0.070  
set_clock_uncertainty -fall_from [get_clocks {CLK_6_25M}] -rise_to [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[1]}] -setup 0.160  
set_clock_uncertainty -fall_from [get_clocks {CLK_6_25M}] -rise_to [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[1]}] -hold 0.170  
set_clock_uncertainty -fall_from [get_clocks {CLK_6_25M}] -fall_to [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[1]}] -setup 0.160  
set_clock_uncertainty -fall_from [get_clocks {CLK_6_25M}] -fall_to [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[1]}] -hold 0.170  
set_clock_uncertainty -rise_from [get_clocks {SCLK}] -rise_to [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[2]}] -setup 0.150  
set_clock_uncertainty -rise_from [get_clocks {SCLK}] -rise_to [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[2]}] -hold 0.170  
set_clock_uncertainty -rise_from [get_clocks {SCLK}] -fall_to [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[2]}] -setup 0.150  
set_clock_uncertainty -rise_from [get_clocks {SCLK}] -fall_to [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[2]}] -hold 0.170  
set_clock_uncertainty -rise_from [get_clocks {SCLK}] -rise_to [get_clocks {SCLK}]  0.070  
set_clock_uncertainty -rise_from [get_clocks {SCLK}] -fall_to [get_clocks {SCLK}]  0.070  
set_clock_uncertainty -rise_from [get_clocks {SCLK}] -rise_to [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[1]}] -setup 0.150  
set_clock_uncertainty -rise_from [get_clocks {SCLK}] -rise_to [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[1]}] -hold 0.170  
set_clock_uncertainty -rise_from [get_clocks {SCLK}] -fall_to [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[1]}] -setup 0.150  
set_clock_uncertainty -rise_from [get_clocks {SCLK}] -fall_to [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[1]}] -hold 0.170  
set_clock_uncertainty -fall_from [get_clocks {SCLK}] -rise_to [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[2]}] -setup 0.150  
set_clock_uncertainty -fall_from [get_clocks {SCLK}] -rise_to [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[2]}] -hold 0.170  
set_clock_uncertainty -fall_from [get_clocks {SCLK}] -fall_to [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[2]}] -setup 0.150  
set_clock_uncertainty -fall_from [get_clocks {SCLK}] -fall_to [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[2]}] -hold 0.170  
set_clock_uncertainty -fall_from [get_clocks {SCLK}] -rise_to [get_clocks {SCLK}]  0.070  
set_clock_uncertainty -fall_from [get_clocks {SCLK}] -fall_to [get_clocks {SCLK}]  0.070  
set_clock_uncertainty -fall_from [get_clocks {SCLK}] -rise_to [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[1]}] -setup 0.150  
set_clock_uncertainty -fall_from [get_clocks {SCLK}] -rise_to [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[1]}] -hold 0.170  
set_clock_uncertainty -fall_from [get_clocks {SCLK}] -fall_to [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[1]}] -setup 0.150  
set_clock_uncertainty -fall_from [get_clocks {SCLK}] -fall_to [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[1]}] -hold 0.170  
set_clock_uncertainty -rise_from [get_clocks {u_registers|u_registers_flash|flash_interface|onchip_flash|altera_onchip_flash_block|ufm_block|osc}] -rise_to [get_clocks {CLK_6_25M}]  0.070  
set_clock_uncertainty -rise_from [get_clocks {u_registers|u_registers_flash|flash_interface|onchip_flash|altera_onchip_flash_block|ufm_block|osc}] -fall_to [get_clocks {CLK_6_25M}]  0.070  
set_clock_uncertainty -rise_from [get_clocks {u_registers|u_registers_flash|flash_interface|onchip_flash|altera_onchip_flash_block|ufm_block|osc}] -rise_to [get_clocks {u_registers|u_registers_flash|flash_interface|onchip_flash|altera_onchip_flash_block|ufm_block|osc}]  0.070  
set_clock_uncertainty -rise_from [get_clocks {u_registers|u_registers_flash|flash_interface|onchip_flash|altera_onchip_flash_block|ufm_block|osc}] -fall_to [get_clocks {u_registers|u_registers_flash|flash_interface|onchip_flash|altera_onchip_flash_block|ufm_block|osc}]  0.070  
set_clock_uncertainty -fall_from [get_clocks {u_registers|u_registers_flash|flash_interface|onchip_flash|altera_onchip_flash_block|ufm_block|osc}] -rise_to [get_clocks {CLK_6_25M}]  0.070  
set_clock_uncertainty -fall_from [get_clocks {u_registers|u_registers_flash|flash_interface|onchip_flash|altera_onchip_flash_block|ufm_block|osc}] -fall_to [get_clocks {CLK_6_25M}]  0.070  
set_clock_uncertainty -fall_from [get_clocks {u_registers|u_registers_flash|flash_interface|onchip_flash|altera_onchip_flash_block|ufm_block|osc}] -rise_to [get_clocks {u_registers|u_registers_flash|flash_interface|onchip_flash|altera_onchip_flash_block|ufm_block|osc}]  0.070  
set_clock_uncertainty -fall_from [get_clocks {u_registers|u_registers_flash|flash_interface|onchip_flash|altera_onchip_flash_block|ufm_block|osc}] -fall_to [get_clocks {u_registers|u_registers_flash|flash_interface|onchip_flash|altera_onchip_flash_block|ufm_block|osc}]  0.070  
set_clock_uncertainty -rise_from [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[2]}]  0.070  
set_clock_uncertainty -rise_from [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[2]}]  0.070  
set_clock_uncertainty -rise_from [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {CLK_6_25M}] -setup 0.170  
set_clock_uncertainty -rise_from [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {CLK_6_25M}] -hold 0.160  
set_clock_uncertainty -rise_from [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {CLK_6_25M}] -setup 0.170  
set_clock_uncertainty -rise_from [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {CLK_6_25M}] -hold 0.160  
set_clock_uncertainty -rise_from [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {SCLK}] -setup 0.170  
set_clock_uncertainty -rise_from [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {SCLK}] -hold 0.150  
set_clock_uncertainty -rise_from [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {SCLK}] -setup 0.170  
set_clock_uncertainty -rise_from [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {SCLK}] -hold 0.150  
set_clock_uncertainty -rise_from [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[1]}]  0.070  
set_clock_uncertainty -rise_from [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[1]}]  0.070  
set_clock_uncertainty -fall_from [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[2]}]  0.070  
set_clock_uncertainty -fall_from [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[2]}]  0.070  
set_clock_uncertainty -fall_from [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {CLK_6_25M}] -setup 0.170  
set_clock_uncertainty -fall_from [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {CLK_6_25M}] -hold 0.160  
set_clock_uncertainty -fall_from [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {CLK_6_25M}] -setup 0.170  
set_clock_uncertainty -fall_from [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {CLK_6_25M}] -hold 0.160  
set_clock_uncertainty -fall_from [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {SCLK}] -setup 0.170  
set_clock_uncertainty -fall_from [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {SCLK}] -hold 0.150  
set_clock_uncertainty -fall_from [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {SCLK}] -setup 0.170  
set_clock_uncertainty -fall_from [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {SCLK}] -hold 0.150  
set_clock_uncertainty -fall_from [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[1]}] -rise_to [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[1]}]  0.070  
set_clock_uncertainty -fall_from [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[1]}] -fall_to [get_clocks {u_PLL|attpll_inst|altpll_component|auto_generated|pll1|clk[1]}]  0.070  


#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************

set_false_path -to [get_keepers {*altera_std_synchronizer:*|din_s1}]
set_false_path -to [get_pins -nocase -compatibility_mode {*|alt_rst_sync_uq1|altera_reset_synchronizer_int_chain*|clrn}]
set_false_path -to [get_registers {*|flash_busy_reg}]
set_false_path -to [get_registers {*|flash_busy_clear_reg}]


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

