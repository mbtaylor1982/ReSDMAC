# Copyright (C) 2021  Intel Corporation. All rights reserved.
# Your use of Intel Corporation's design tools, logic functions 
# and other software and tools, and any partner logic 
# functions, and any output files from any of the foregoing 
# (including device programming or simulation files), and any 
# associated documentation or information are expressly subject 
# to the terms and conditions of the Intel Program License 
# Subscription Agreement, the Intel Quartus Prime License Agreement,
# the Intel FPGA IP License Agreement, or other applicable license
# agreement, including, without limitation, that your use is for
# the sole purpose of programming logic devices manufactured by
# Intel and sold by Intel or its authorized distributors.  Please
# refer to the applicable agreement for further details, at
# https://fpgasoftware.intel.com/eula.

# Quartus Prime: Generate Tcl File for Project
# File: RESDMAC.tcl
# Generated on: Sun Aug 11 22:09:13 2024

# Load Quartus Prime Tcl Project package
package require ::quartus::project
package require ::quartus::flow

project_new -overwrite RESDMAC
project_clean
project_open RESDMAC

set make_assignments 1

# Make assignments
if {$make_assignments} {
	set_global_assignment -name ORIGINAL_QUARTUS_VERSION "13.0 SP1"
	set_global_assignment -name PROJECT_CREATION_TIME_DATE "23:14:24  DECEMBER 29, 2022"
	set_global_assignment -name LAST_QUARTUS_VERSION "21.1.0 Lite Edition"
	set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files_$quartus(args)
	set_global_assignment -name SMART_RECOMPILE OFF
	set_global_assignment -name VERILOG_FILE ../RTL/CPU_SM/CPU_SM_INTERNALS1.v
	set_global_assignment -name VERILOG_FILE ../RTL/mux2.v
	set_global_assignment -name TCL_SCRIPT_FILE generate_jic_programming_file.tcl
	set_global_assignment -name VERILOG_FILE ../RTL/SCSI_SM/scsi_sm_internals1.v
	set_global_assignment -name VERILOG_FILE ../RTL/SCSI_SM/SCSI_SM_INTERNALS.v
	set_global_assignment -name VERILOG_FILE ../RTL/PLL.v
	set_global_assignment -name VERILOG_FILE ../RTL/SCSI_SM/scsi_sm_outputs.v
	set_global_assignment -name VERILOG_FILE ../RTL/SCSI_SM/scsi_sm_inputs.v
	set_global_assignment -name VERILOG_FILE ../RTL/SCSI_SM/SCSI_SM.v
	set_global_assignment -name VERILOG_FILE ../RTL/Registers/registers_term.v
	set_global_assignment -name VERILOG_FILE ../RTL/Registers/registers_istr.v
	set_global_assignment -name VERILOG_FILE ../RTL/Registers/registers_cntr.v
	set_global_assignment -name VERILOG_FILE ../RTL/Registers/registers.v
	set_global_assignment -name VERILOG_FILE ../RTL/Registers/addr_decoder.v
	set_global_assignment -name VERILOG_FILE ../RTL/FIFO/fifo_write_strobes.v
	set_global_assignment -name VERILOG_FILE ../RTL/FIFO/fifo_full_empty_ctr.v
	set_global_assignment -name VERILOG_FILE ../RTL/FIFO/fifo_byte_ptr.v
	set_global_assignment -name VERILOG_FILE ../RTL/FIFO/fifo_3bit_cntr.v
	set_global_assignment -name VERILOG_FILE ../RTL/FIFO/fifo.v
	set_global_assignment -name VERILOG_FILE ../RTL/datapath/datapath_scsi.v
	set_global_assignment -name VERILOG_FILE ../RTL/datapath/datapath_output.v
	set_global_assignment -name VERILOG_FILE ../RTL/datapath/datapath_input.v
	set_global_assignment -name VERILOG_FILE ../RTL/datapath/datapath_24dec.v
	set_global_assignment -name VERILOG_FILE ../RTL/datapath/datapath_8b_MUX.v
	set_global_assignment -name VERILOG_FILE ../RTL/datapath/datapath.v
	set_global_assignment -name VERILOG_FILE ../RTL/CPU_SM/CPU_SM_output.v
	set_global_assignment -name VERILOG_FILE ../RTL/CPU_SM/CPU_SM_inputs.v
	set_global_assignment -name VERILOG_FILE ../RTL/CPU_SM/CPU_SM.v
	set_global_assignment -name VERILOG_FILE ../RTL/RESDMAC.v
	set_global_assignment -name SIGNALTAP_FILE ReSDMAC.stp
	set_global_assignment -name QIP_FILE attpll.qip
	set_global_assignment -name FLOW_ENABLE_POWER_ANALYZER ON
	set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
	set_global_assignment -name MAX_CORE_JUNCTION_TEMP 85
	set_global_assignment -name TIMING_ANALYZER_MULTICORNER_ANALYSIS ON
	set_global_assignment -name FAMILY "MAX 10"
	set_global_assignment -name DEVICE_FILTER_PACKAGE UFBGA
	set_global_assignment -name DEVICE_FILTER_PIN_COUNT 169
	set_global_assignment -name DEVICE_FILTER_SPEED_GRADE 8
	set_global_assignment -name DEVICE $quartus(args)
	set_global_assignment -name STRATIX_DEVICE_IO_STANDARD "3.3-V LVTTL"
	set_global_assignment -name FITTER_EFFORT "STANDARD FIT"
	set_global_assignment -name ENABLE_BOOT_SEL_PIN OFF
	set_global_assignment -name CRC_ERROR_OPEN_DRAIN OFF
	set_global_assignment -name RESERVE_ALL_UNUSED_PINS_WEAK_PULLUP "AS INPUT TRI-STATED"
	set_global_assignment -name EDA_SIMULATION_TOOL "Questa Intel FPGA (Verilog)"
	set_global_assignment -name USE_CONFIGURATION_DEVICE OFF
	set_global_assignment -name STRATIX_CONFIGURATION_DEVICE EPCS4
	set_global_assignment -name ENABLE_OCT_DONE OFF
	set_global_assignment -name EXTERNAL_FLASH_FALLBACK_ADDRESS 00000000
	set_global_assignment -name ENABLE_DRC_SETTINGS OFF
	set_global_assignment -name POWER_PRESET_COOLING_SOLUTION "NO HEAT SINK WITH STILL AIR"
	set_global_assignment -name POWER_BOARD_THERMAL_MODEL "NONE (CONSERVATIVE)"
	set_global_assignment -name POWER_DEFAULT_INPUT_IO_TOGGLE_RATE "12.5 %"
	set_global_assignment -name OUTPUT_IO_TIMING_NEAR_END_VMEAS "HALF VCCIO" -rise
	set_global_assignment -name OUTPUT_IO_TIMING_NEAR_END_VMEAS "HALF VCCIO" -fall
	set_global_assignment -name OUTPUT_IO_TIMING_FAR_END_VMEAS "HALF SIGNAL SWING" -rise
	set_global_assignment -name OUTPUT_IO_TIMING_FAR_END_VMEAS "HALF SIGNAL SWING" -fall
	set_global_assignment -name EDA_TIME_SCALE "1 ps" -section_id eda_simulation
	set_global_assignment -name EDA_OUTPUT_DATA_FORMAT "VERILOG HDL" -section_id eda_simulation
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER SCLK -section_id GlobalSignals
	set_global_assignment -name ASSIGNMENT_GROUP_MEMBER _RST -section_id GlobalSignals
	set_global_assignment -name PARTITION_NETLIST_TYPE SOURCE -section_id Top
	set_global_assignment -name PARTITION_FITTER_PRESERVATION_LEVEL PLACEMENT_AND_ROUTING -section_id Top
	set_global_assignment -name PARTITION_COLOR 16764057 -section_id Top
	set_global_assignment -name NUM_PARALLEL_PROCESSORS ALL
	set_global_assignment -name EDA_GENERATE_FUNCTIONAL_NETLIST OFF -section_id eda_board_design_timing
	set_global_assignment -name EDA_GENERATE_FUNCTIONAL_NETLIST OFF -section_id eda_board_design_symbol
	set_global_assignment -name EDA_GENERATE_FUNCTIONAL_NETLIST OFF -section_id eda_board_design_signal_integrity
	set_global_assignment -name EDA_GENERATE_FUNCTIONAL_NETLIST OFF -section_id eda_board_design_boundary_scan
	set_global_assignment -name EN_USER_IO_WEAK_PULLUP OFF
	set_global_assignment -name EN_SPI_IO_WEAK_PULLUP OFF
	set_global_assignment -name ENABLE_SIGNALTAP ON
	set_global_assignment -name USE_SIGNALTAP_FILE stp1.stp
	set_global_assignment -name SIGNALTAP_FILE stp1.stp
	set_global_assignment -name SLD_NODE_CREATOR_ID 110 -section_id auto_signaltap_0
	set_global_assignment -name SLD_NODE_ENTITY_NAME sld_signaltap -section_id auto_signaltap_0
	set_global_assignment -name SLD_NODE_PARAMETER_ASSIGNMENT "SLD_RAM_BLOCK_TYPE=AUTO" -section_id auto_signaltap_0
	set_global_assignment -name SLD_NODE_PARAMETER_ASSIGNMENT "SLD_NODE_INFO=805334528" -section_id auto_signaltap_0
	set_global_assignment -name SLD_NODE_PARAMETER_ASSIGNMENT "SLD_POWER_UP_TRIGGER=0" -section_id auto_signaltap_0
	set_global_assignment -name SLD_NODE_PARAMETER_ASSIGNMENT "SLD_STORAGE_QUALIFIER_INVERSION_MASK_LENGTH=0" -section_id auto_signaltap_0
	set_global_assignment -name SLD_NODE_PARAMETER_ASSIGNMENT "SLD_ATTRIBUTE_MEM_MODE=OFF" -section_id auto_signaltap_0
	set_global_assignment -name SLD_NODE_PARAMETER_ASSIGNMENT "SLD_STATE_FLOW_USE_GENERATED=0" -section_id auto_signaltap_0
	set_global_assignment -name SLD_NODE_PARAMETER_ASSIGNMENT "SLD_STATE_BITS=11" -section_id auto_signaltap_0
	set_global_assignment -name SLD_NODE_PARAMETER_ASSIGNMENT "SLD_BUFFER_FULL_STOP=1" -section_id auto_signaltap_0
	set_global_assignment -name SLD_NODE_PARAMETER_ASSIGNMENT "SLD_CURRENT_RESOURCE_WIDTH=1" -section_id auto_signaltap_0
	set_global_assignment -name SLD_NODE_PARAMETER_ASSIGNMENT "SLD_INCREMENTAL_ROUTING=1" -section_id auto_signaltap_0
	set_global_assignment -name SLD_NODE_PARAMETER_ASSIGNMENT "SLD_TRIGGER_LEVEL=1" -section_id auto_signaltap_0
	set_global_assignment -name SLD_NODE_PARAMETER_ASSIGNMENT "SLD_TRIGGER_IN_ENABLED=0" -section_id auto_signaltap_0
	set_global_assignment -name SLD_NODE_PARAMETER_ASSIGNMENT "SLD_TRIGGER_PIPELINE=0" -section_id auto_signaltap_0
	set_global_assignment -name SLD_NODE_PARAMETER_ASSIGNMENT "SLD_COUNTER_PIPELINE=0" -section_id auto_signaltap_0
	set_global_assignment -name SLD_NODE_PARAMETER_ASSIGNMENT "SLD_TRIGGER_LEVEL_PIPELINE=1" -section_id auto_signaltap_0
	set_global_assignment -name SLD_NODE_PARAMETER_ASSIGNMENT "SLD_RAM_PIPELINE=1" -section_id auto_signaltap_0
	set_global_assignment -name PARTITION_NETLIST_TYPE SOURCE -entity test -section_id Top
	set_global_assignment -name PARTITION_FITTER_PRESERVATION_LEVEL PLACEMENT_AND_ROUTING -entity test -section_id Top
	set_global_assignment -name PARTITION_COLOR 16764057 -entity test -section_id Top
	set_global_assignment -name SLD_NODE_PARAMETER_ASSIGNMENT "SLD_ADVANCED_TRIGGER_ENTITY=basic,1," -section_id auto_signaltap_0
	set_global_assignment -name SLD_NODE_PARAMETER_ASSIGNMENT "SLD_ENABLE_ADVANCED_TRIGGER=0" -section_id auto_signaltap_0
	set_global_assignment -name SLD_NODE_PARAMETER_ASSIGNMENT "SLD_SEGMENT_SIZE=4096" -section_id auto_signaltap_0
	set_global_assignment -name SLD_NODE_PARAMETER_ASSIGNMENT "SLD_SAMPLE_DEPTH=4096" -section_id auto_signaltap_0
	set_global_assignment -name SLD_NODE_PARAMETER_ASSIGNMENT "SLD_DATA_BITS=96" -section_id auto_signaltap_0
	set_global_assignment -name SLD_NODE_PARAMETER_ASSIGNMENT "SLD_TRIGGER_BITS=58" -section_id auto_signaltap_0
	set_global_assignment -name SLD_NODE_PARAMETER_ASSIGNMENT "SLD_STORAGE_QUALIFIER_BITS=96" -section_id auto_signaltap_0
	set_global_assignment -name SLD_NODE_PARAMETER_ASSIGNMENT "SLD_INVERSION_MASK=00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" -section_id auto_signaltap_0
	set_global_assignment -name SLD_NODE_PARAMETER_ASSIGNMENT "SLD_INVERSION_MASK_LENGTH=200" -section_id auto_signaltap_0
	set_global_assignment -name SLD_FILE db/stp1_auto_stripped.stp
	set_global_assignment -name VCCA_USER_VOLTAGE 3.3V
	set_global_assignment -name NOMINAL_CORE_SUPPLY_VOLTAGE 3.3V
	set_location_assignment PIN_M9 -to DATA_IO[31]
	set_location_assignment PIN_A5 -to DATA_IO[0]
	set_location_assignment PIN_M3 -to DATA_IO[1]
	set_location_assignment PIN_M8 -to DATA_IO[30]
	set_location_assignment PIN_K8 -to DATA_IO[29]
	set_location_assignment PIN_M7 -to DATA_IO[28]
	set_location_assignment PIN_M5 -to DATA_IO[27]
	set_location_assignment PIN_M4 -to DATA_IO[26]
	set_location_assignment PIN_L5 -to DATA_IO[25]
	set_location_assignment PIN_L4 -to DATA_IO[24]
	set_location_assignment PIN_L2 -to DATA_IO[23]
	set_location_assignment PIN_H2 -to DATA_IO[22]
	set_location_assignment PIN_J2 -to DATA_IO[21]
	set_location_assignment PIN_K1 -to DATA_IO[20]
	set_location_assignment PIN_J1 -to DATA_IO[19]
	set_location_assignment PIN_N4 -to DATA_IO[2]
	set_location_assignment PIN_N5 -to DATA_IO[3]
	set_location_assignment PIN_N6 -to DATA_IO[4]
	set_location_assignment PIN_N7 -to DATA_IO[5]
	set_location_assignment PIN_N9 -to DATA_IO[6]
	set_location_assignment PIN_L12 -to DATA_IO[7]
	set_location_assignment PIN_M12 -to DATA_IO[8]
	set_location_assignment PIN_N12 -to DATA_IO[9]
	set_location_assignment PIN_N11 -to DATA_IO[10]
	set_location_assignment PIN_M11 -to DATA_IO[11]
	set_location_assignment PIN_N10 -to DATA_IO[12]
	set_location_assignment PIN_M10 -to DATA_IO[13]
	set_location_assignment PIN_M2 -to DATA_IO[15]
	set_location_assignment PIN_M1 -to DATA_IO[16]
	set_location_assignment PIN_L1 -to DATA_IO[17]
	set_location_assignment PIN_K2 -to DATA_IO[18]
	set_location_assignment PIN_F13 -to SCLK
	set_location_assignment PIN_A11 -to ADDR[2]
	set_location_assignment PIN_B12 -to ADDR[3]
	set_location_assignment PIN_A12 -to ADDR[4]
	set_location_assignment PIN_B11 -to ADDR[5]
	set_location_assignment PIN_B10 -to ADDR[6]
	set_location_assignment PIN_B9 -to PD_PORT[7]
	set_location_assignment PIN_C10 -to PD_PORT[6]
	set_location_assignment PIN_F10 -to PD_PORT[5]
	set_location_assignment PIN_C11 -to PD_PORT[4]
	set_location_assignment PIN_D12 -to PD_PORT[3]
	set_location_assignment PIN_B13 -to PD_PORT[2]
	set_location_assignment PIN_C13 -to PD_PORT[1]
	set_location_assignment PIN_C12 -to PD_PORT[0]
	set_location_assignment PIN_E3 -to PD_PORT[15]
	set_location_assignment PIN_B4 -to PD_PORT[14]
	set_location_assignment PIN_F4 -to PD_PORT[13]
	set_location_assignment PIN_B5 -to PD_PORT[12]
	set_location_assignment PIN_D6 -to PD_PORT[11]
	set_location_assignment PIN_F9 -to PD_PORT[9]
	set_location_assignment PIN_C9 -to PD_PORT[8]
	set_location_assignment PIN_G13 -to _RST
	set_location_assignment PIN_L10 -to _STERM
	set_location_assignment PIN_J13 -to R_W_IO
	set_location_assignment PIN_A7 -to INTA
	set_location_assignment PIN_H13 -to _AS_IO
	set_location_assignment PIN_F12 -to _BERR
	set_location_assignment PIN_A6 -to _BGACK_IO
	set_location_assignment PIN_D13 -to _CS
	set_location_assignment PIN_C1 -to _CSS
	set_location_assignment PIN_D1 -to _DACK
	set_location_assignment PIN_A9 -to _DMAEN
	set_location_assignment PIN_F1 -to _DREQ
	set_location_assignment PIN_K13 -to _DS_IO
	set_location_assignment PIN_B2 -to _IOR
	set_location_assignment PIN_C2 -to _IOW
	set_location_assignment PIN_M13 -to _SIZ1
	set_location_assignment PIN_B6 -to PD_PORT[10]
	set_location_assignment PIN_N8 -to DATA_IO[14]
	set_location_assignment PIN_B7 -to _BG
	set_location_assignment PIN_A10 -to _BR
	set_location_assignment PIN_L13 -to _INT
	set_location_assignment PIN_K10 -to _DSACK_IO[0]
	set_location_assignment PIN_K12 -to _DSACK_IO[1]
	set_location_assignment PIN_B1 -to JP
	set_instance_assignment -name RESERVE_PIN AS_INPUT_TRI_STATED -to JP
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_clk -to SCLK -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[0] -to ADDR[2] -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[1] -to ADDR[3] -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[2] -to ADDR[4] -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[3] -to ADDR[5] -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[4] -to ADDR[6] -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[5] -to DATA_IO[0] -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[6] -to DATA_IO[10] -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[7] -to DATA_IO[11] -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[8] -to DATA_IO[12] -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[9] -to DATA_IO[13] -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[10] -to DATA_IO[14] -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[11] -to DATA_IO[15] -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[12] -to DATA_IO[16] -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[13] -to DATA_IO[17] -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[14] -to DATA_IO[18] -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[15] -to DATA_IO[19] -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[16] -to DATA_IO[1] -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[17] -to DATA_IO[20] -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[18] -to DATA_IO[21] -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[19] -to DATA_IO[22] -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[20] -to DATA_IO[23] -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[21] -to DATA_IO[24] -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[22] -to DATA_IO[25] -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[23] -to DATA_IO[26] -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[24] -to DATA_IO[27] -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[25] -to DATA_IO[28] -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[26] -to DATA_IO[29] -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[27] -to DATA_IO[2] -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[28] -to DATA_IO[30] -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[29] -to DATA_IO[31] -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[30] -to DATA_IO[3] -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[31] -to DATA_IO[4] -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[32] -to DATA_IO[5] -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[33] -to DATA_IO[6] -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[34] -to DATA_IO[7] -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[35] -to DATA_IO[8] -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[36] -to DATA_IO[9] -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[37] -to INTA -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[38] -to PD_PORT[0] -section_id auto_signaltap_0
	set_instance_assignment -name POST_FIT_CONNECT_TO_SLD_NODE_ENTITY_PORT crc[9] -to auto_signaltap_0|gnd -section_id auto_signaltap_0
	set_instance_assignment -name GLOBAL_SIGNAL GLOBAL_CLOCK -to SCLK
	set_location_assignment PIN_D8 -to PIN_D8
	set_instance_assignment -name RESERVE_PIN AS_INPUT_TRI_STATED -to PIN_D8
	set_location_assignment PIN_A8 -to INC_ADD
	set_location_assignment PIN_A4 -to IORDY
	set_location_assignment PIN_A3 -to CSX1
	set_location_assignment PIN_A2 -to CSX0
	set_location_assignment PIN_G9 -to INTB
	set_instance_assignment -name PARTITION_HIERARCHY root_partition -to | -entity test -section_id Top
	set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to PD_PORT[8]
	set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to PD_PORT[9]
	set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to PD_PORT[10]
	set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to PD_PORT[11]
	set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to PD_PORT[12]
	set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to PD_PORT[13]
	set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to PD_PORT[14]
	set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to PD_PORT[15]
	set_instance_assignment -name RESERVE_PIN AS_INPUT_TRI_STATED -to INTB
	set_instance_assignment -name RESERVE_PIN AS_INPUT_TRI_STATED -to IORDY
	set_instance_assignment -name RESERVE_PIN AS_INPUT_TRI_STATED -to INC_ADD
	set_instance_assignment -name RESERVE_PIN AS_INPUT_TRI_STATED -to CSX1
	set_instance_assignment -name RESERVE_PIN AS_INPUT_TRI_STATED -to CSX0
	set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to _DREQ
	set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to IORDY
	set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to _BR
	set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to R_W_IO
	set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to _AS_IO
	set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to _DS_IO
	set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to _DSACK_IO[0]
	set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to _DSACK_IO[1]
	set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to _STERM
	set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to _SIZ1
	set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to _INT
	set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to _DMAEN
	set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to _DACK
	set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to _CSS
	set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to _BGACK_IO
	set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to _BERR
	set_instance_assignment -name ENABLE_BUS_HOLD_CIRCUITRY ON -to DATA_IO[0]
	set_instance_assignment -name ENABLE_BUS_HOLD_CIRCUITRY ON -to DATA_IO[1]
	set_instance_assignment -name ENABLE_BUS_HOLD_CIRCUITRY ON -to DATA_IO[2]
	set_instance_assignment -name ENABLE_BUS_HOLD_CIRCUITRY ON -to DATA_IO[3]
	set_instance_assignment -name ENABLE_BUS_HOLD_CIRCUITRY ON -to DATA_IO[4]
	set_instance_assignment -name ENABLE_BUS_HOLD_CIRCUITRY ON -to DATA_IO[5]
	set_instance_assignment -name ENABLE_BUS_HOLD_CIRCUITRY ON -to DATA_IO[6]
	set_instance_assignment -name ENABLE_BUS_HOLD_CIRCUITRY ON -to DATA_IO[7]
	set_instance_assignment -name ENABLE_BUS_HOLD_CIRCUITRY ON -to DATA_IO[8]
	set_instance_assignment -name ENABLE_BUS_HOLD_CIRCUITRY ON -to DATA_IO[9]
	set_instance_assignment -name ENABLE_BUS_HOLD_CIRCUITRY ON -to DATA_IO[10]
	set_instance_assignment -name ENABLE_BUS_HOLD_CIRCUITRY ON -to DATA_IO[11]
	set_instance_assignment -name ENABLE_BUS_HOLD_CIRCUITRY ON -to DATA_IO[12]
	set_instance_assignment -name ENABLE_BUS_HOLD_CIRCUITRY ON -to DATA_IO[13]
	set_instance_assignment -name ENABLE_BUS_HOLD_CIRCUITRY ON -to DATA_IO[14]
	set_instance_assignment -name ENABLE_BUS_HOLD_CIRCUITRY ON -to DATA_IO[15]
	set_instance_assignment -name ENABLE_BUS_HOLD_CIRCUITRY ON -to DATA_IO[16]
	set_instance_assignment -name ENABLE_BUS_HOLD_CIRCUITRY ON -to DATA_IO[17]
	set_instance_assignment -name ENABLE_BUS_HOLD_CIRCUITRY ON -to DATA_IO[18]
	set_instance_assignment -name ENABLE_BUS_HOLD_CIRCUITRY ON -to DATA_IO[19]
	set_instance_assignment -name ENABLE_BUS_HOLD_CIRCUITRY ON -to DATA_IO[20]
	set_instance_assignment -name ENABLE_BUS_HOLD_CIRCUITRY ON -to DATA_IO[21]
	set_instance_assignment -name ENABLE_BUS_HOLD_CIRCUITRY ON -to DATA_IO[22]
	set_instance_assignment -name ENABLE_BUS_HOLD_CIRCUITRY ON -to DATA_IO[23]
	set_instance_assignment -name ENABLE_BUS_HOLD_CIRCUITRY ON -to DATA_IO[24]
	set_instance_assignment -name ENABLE_BUS_HOLD_CIRCUITRY ON -to DATA_IO[25]
	set_instance_assignment -name ENABLE_BUS_HOLD_CIRCUITRY ON -to DATA_IO[26]
	set_instance_assignment -name ENABLE_BUS_HOLD_CIRCUITRY ON -to DATA_IO[27]
	set_instance_assignment -name ENABLE_BUS_HOLD_CIRCUITRY ON -to DATA_IO[28]
	set_instance_assignment -name ENABLE_BUS_HOLD_CIRCUITRY ON -to DATA_IO[29]
	set_instance_assignment -name ENABLE_BUS_HOLD_CIRCUITRY ON -to DATA_IO[30]
	set_instance_assignment -name ENABLE_BUS_HOLD_CIRCUITRY ON -to DATA_IO[31]
	set_instance_assignment -name ENABLE_BUS_HOLD_CIRCUITRY ON -to ADDR[2]
	set_instance_assignment -name ENABLE_BUS_HOLD_CIRCUITRY ON -to ADDR[3]
	set_instance_assignment -name ENABLE_BUS_HOLD_CIRCUITRY ON -to ADDR[4]
	set_instance_assignment -name ENABLE_BUS_HOLD_CIRCUITRY ON -to ADDR[5]
	set_instance_assignment -name ENABLE_BUS_HOLD_CIRCUITRY ON -to ADDR[6]
	set_instance_assignment -name ENABLE_BUS_HOLD_CIRCUITRY ON -to PD_PORT[0]
	set_instance_assignment -name ENABLE_BUS_HOLD_CIRCUITRY ON -to PD_PORT[1]
	set_instance_assignment -name ENABLE_BUS_HOLD_CIRCUITRY ON -to PD_PORT[2]
	set_instance_assignment -name ENABLE_BUS_HOLD_CIRCUITRY ON -to PD_PORT[3]
	set_instance_assignment -name ENABLE_BUS_HOLD_CIRCUITRY ON -to PD_PORT[4]
	set_instance_assignment -name ENABLE_BUS_HOLD_CIRCUITRY ON -to PD_PORT[5]
	set_instance_assignment -name ENABLE_BUS_HOLD_CIRCUITRY ON -to PD_PORT[6]
	set_instance_assignment -name ENABLE_BUS_HOLD_CIRCUITRY ON -to PD_PORT[7]
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[39] -to PD_PORT[1] -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[40] -to PD_PORT[2] -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[41] -to PD_PORT[3] -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[42] -to PD_PORT[4] -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[43] -to PD_PORT[5] -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[44] -to PD_PORT[6] -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[45] -to PD_PORT[7] -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[46] -to R_W_IO -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[47] -to _AS_IO -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[48] -to _BGACK_IO -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[49] -to _CS -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[50] -to _CSS -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[51] -to _DACK -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[52] -to _DREQ -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[53] -to _DSACK_IO[0] -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[54] -to _DSACK_IO[1] -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[55] -to _DS_IO -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[56] -to _INT -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[57] -to _IOR -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[58] -to _IOW -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[59] -to _STERM -section_id auto_signaltap_0
	set_instance_assignment -name POST_FIT_CONNECT_TO_SLD_NODE_ENTITY_PORT crc[19] -to auto_signaltap_0|vcc -section_id auto_signaltap_0
	set_instance_assignment -name POST_FIT_CONNECT_TO_SLD_NODE_ENTITY_PORT crc[23] -to auto_signaltap_0|gnd -section_id auto_signaltap_0
	set_instance_assignment -name POST_FIT_CONNECT_TO_SLD_NODE_ENTITY_PORT crc[16] -to auto_signaltap_0|vcc -section_id auto_signaltap_0
	set_instance_assignment -name POST_FIT_CONNECT_TO_SLD_NODE_ENTITY_PORT crc[7] -to auto_signaltap_0|gnd -section_id auto_signaltap_0
	set_instance_assignment -name POST_FIT_CONNECT_TO_SLD_NODE_ENTITY_PORT crc[13] -to auto_signaltap_0|gnd -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in[0] -to ADDR[2] -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in[1] -to ADDR[3] -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in[2] -to ADDR[4] -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in[3] -to ADDR[5] -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in[4] -to ADDR[6] -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in[5] -to INTA -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in[6] -to PD_PORT[0] -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in[7] -to PD_PORT[1] -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in[8] -to PD_PORT[2] -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in[9] -to PD_PORT[3] -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in[10] -to PD_PORT[4] -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in[11] -to PD_PORT[5] -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in[12] -to PD_PORT[6] -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in[13] -to PD_PORT[7] -section_id auto_signaltap_0
	set_instance_assignment -name POST_FIT_CONNECT_TO_SLD_NODE_ENTITY_PORT crc[10] -to auto_signaltap_0|vcc -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in[14] -to R_W_IO -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in[15] -to _BGACK_IO -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in[16] -to _CS -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in[17] -to _CSS -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in[18] -to _DACK -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in[19] -to _DREQ -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in[20] -to _IOR -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in[21] -to _IOW -section_id auto_signaltap_0
	set_instance_assignment -name POST_FIT_CONNECT_TO_SLD_NODE_ENTITY_PORT crc[0] -to auto_signaltap_0|vcc -section_id auto_signaltap_0
	set_instance_assignment -name POST_FIT_CONNECT_TO_SLD_NODE_ENTITY_PORT crc[2] -to auto_signaltap_0|vcc -section_id auto_signaltap_0
	set_instance_assignment -name POST_FIT_CONNECT_TO_SLD_NODE_ENTITY_PORT crc[12] -to auto_signaltap_0|vcc -section_id auto_signaltap_0
	set_instance_assignment -name POST_FIT_CONNECT_TO_SLD_NODE_ENTITY_PORT crc[15] -to auto_signaltap_0|vcc -section_id auto_signaltap_0
	set_instance_assignment -name POST_FIT_CONNECT_TO_SLD_NODE_ENTITY_PORT crc[17] -to auto_signaltap_0|gnd -section_id auto_signaltap_0
	set_instance_assignment -name POST_FIT_CONNECT_TO_SLD_NODE_ENTITY_PORT crc[18] -to auto_signaltap_0|gnd -section_id auto_signaltap_0
	set_instance_assignment -name POST_FIT_CONNECT_TO_SLD_NODE_ENTITY_PORT crc[21] -to auto_signaltap_0|vcc -section_id auto_signaltap_0
	set_instance_assignment -name POST_FIT_CONNECT_TO_SLD_NODE_ENTITY_PORT crc[22] -to auto_signaltap_0|gnd -section_id auto_signaltap_0
	set_instance_assignment -name POST_FIT_CONNECT_TO_SLD_NODE_ENTITY_PORT crc[26] -to auto_signaltap_0|vcc -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in[22] -to "fifo:int_fifo|fifo_3bit_cntr:u_next_in_cntr|COUNT[0]" -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in[23] -to "fifo:int_fifo|fifo_3bit_cntr:u_next_in_cntr|COUNT[1]" -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in[24] -to "fifo:int_fifo|fifo_3bit_cntr:u_next_in_cntr|COUNT[2]" -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in[25] -to "fifo:int_fifo|fifo_3bit_cntr:u_next_out_cntr|COUNT[0]" -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in[26] -to "fifo:int_fifo|fifo_3bit_cntr:u_next_out_cntr|COUNT[1]" -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in[27] -to "fifo:int_fifo|fifo_3bit_cntr:u_next_out_cntr|COUNT[2]" -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in[28] -to "fifo:int_fifo|fifo__full_empty_ctr:u_full_empty_ctr|DOWN[0]" -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in[29] -to "fifo:int_fifo|fifo__full_empty_ctr:u_full_empty_ctr|DOWN[1]" -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in[30] -to "fifo:int_fifo|fifo__full_empty_ctr:u_full_empty_ctr|DOWN[2]" -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in[31] -to "fifo:int_fifo|fifo__full_empty_ctr:u_full_empty_ctr|DOWN[3]" -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in[32] -to "fifo:int_fifo|fifo__full_empty_ctr:u_full_empty_ctr|DOWN[4]" -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in[33] -to "fifo:int_fifo|fifo__full_empty_ctr:u_full_empty_ctr|DOWN[5]" -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in[34] -to "fifo:int_fifo|fifo__full_empty_ctr:u_full_empty_ctr|DOWN[6]" -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in[35] -to "fifo:int_fifo|fifo__full_empty_ctr:u_full_empty_ctr|FIFOEMPTY~reg0" -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in[36] -to "fifo:int_fifo|fifo__full_empty_ctr:u_full_empty_ctr|FIFOFULL~reg0" -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in[37] -to "fifo:int_fifo|fifo__full_empty_ctr:u_full_empty_ctr|UP[0]" -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in[38] -to "fifo:int_fifo|fifo__full_empty_ctr:u_full_empty_ctr|UP[1]" -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in[39] -to "fifo:int_fifo|fifo__full_empty_ctr:u_full_empty_ctr|UP[2]" -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in[40] -to "fifo:int_fifo|fifo__full_empty_ctr:u_full_empty_ctr|UP[3]" -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in[41] -to "fifo:int_fifo|fifo__full_empty_ctr:u_full_empty_ctr|UP[4]" -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in[42] -to "fifo:int_fifo|fifo__full_empty_ctr:u_full_empty_ctr|UP[5]" -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in[43] -to "fifo:int_fifo|fifo__full_empty_ctr:u_full_empty_ctr|UP[6]" -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in[44] -to "fifo:int_fifo|fifo__full_empty_ctr:u_full_empty_ctr|UP[7]" -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in[45] -to "registers:u_registers|registers_istr:u_registers_istr|ISTR_O[0]" -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in[46] -to "registers:u_registers|registers_istr:u_registers_istr|ISTR_O[1]" -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in[47] -to "registers:u_registers|registers_istr:u_registers_istr|ISTR_O[2]" -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in[48] -to "registers:u_registers|registers_istr:u_registers_istr|ISTR_O[3]" -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in[49] -to "registers:u_registers|registers_istr:u_registers_istr|ISTR_O[4]" -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in[50] -to "registers:u_registers|registers_istr:u_registers_istr|ISTR_O[5]" -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in[51] -to "registers:u_registers|registers_istr:u_registers_istr|ISTR_O[6]" -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in[52] -to "registers:u_registers|registers_istr:u_registers_istr|ISTR_O[7]" -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in[53] -to "registers:u_registers|registers_istr:u_registers_istr|ISTR_O[8]" -section_id auto_signaltap_0
	set_instance_assignment -name POST_FIT_CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in[54] -to "CPU_SM:u_CPU_SM|STOPFLUSH" -section_id auto_signaltap_0
	set_instance_assignment -name POST_FIT_CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in[55] -to "fifo:int_fifo|fifo__full_empty_ctr:u_full_empty_ctr|FIFOEMPTY" -section_id auto_signaltap_0
	set_instance_assignment -name POST_FIT_CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in[56] -to "fifo:int_fifo|fifo__full_empty_ctr:u_full_empty_ctr|FIFOFULL" -section_id auto_signaltap_0
	set_instance_assignment -name POST_FIT_CONNECT_TO_SLD_NODE_ENTITY_PORT acq_trigger_in[57] -to "registers:u_registers|FLUSHFIFO" -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[60] -to "fifo:int_fifo|fifo_3bit_cntr:u_next_in_cntr|COUNT[0]" -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[61] -to "fifo:int_fifo|fifo_3bit_cntr:u_next_in_cntr|COUNT[1]" -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[62] -to "fifo:int_fifo|fifo_3bit_cntr:u_next_in_cntr|COUNT[2]" -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[63] -to "fifo:int_fifo|fifo_3bit_cntr:u_next_out_cntr|COUNT[0]" -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[64] -to "fifo:int_fifo|fifo_3bit_cntr:u_next_out_cntr|COUNT[1]" -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[65] -to "fifo:int_fifo|fifo_3bit_cntr:u_next_out_cntr|COUNT[2]" -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[66] -to "fifo:int_fifo|fifo__full_empty_ctr:u_full_empty_ctr|DOWN[0]" -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[67] -to "fifo:int_fifo|fifo__full_empty_ctr:u_full_empty_ctr|DOWN[1]" -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[68] -to "fifo:int_fifo|fifo__full_empty_ctr:u_full_empty_ctr|DOWN[2]" -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[69] -to "fifo:int_fifo|fifo__full_empty_ctr:u_full_empty_ctr|DOWN[3]" -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[70] -to "fifo:int_fifo|fifo__full_empty_ctr:u_full_empty_ctr|DOWN[4]" -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[71] -to "fifo:int_fifo|fifo__full_empty_ctr:u_full_empty_ctr|DOWN[5]" -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[72] -to "fifo:int_fifo|fifo__full_empty_ctr:u_full_empty_ctr|DOWN[6]" -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[73] -to "fifo:int_fifo|fifo__full_empty_ctr:u_full_empty_ctr|FIFOEMPTY~reg0" -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[74] -to "fifo:int_fifo|fifo__full_empty_ctr:u_full_empty_ctr|FIFOFULL~reg0" -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[75] -to "fifo:int_fifo|fifo__full_empty_ctr:u_full_empty_ctr|UP[0]" -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[76] -to "fifo:int_fifo|fifo__full_empty_ctr:u_full_empty_ctr|UP[1]" -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[77] -to "fifo:int_fifo|fifo__full_empty_ctr:u_full_empty_ctr|UP[2]" -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[78] -to "fifo:int_fifo|fifo__full_empty_ctr:u_full_empty_ctr|UP[3]" -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[79] -to "fifo:int_fifo|fifo__full_empty_ctr:u_full_empty_ctr|UP[4]" -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[80] -to "fifo:int_fifo|fifo__full_empty_ctr:u_full_empty_ctr|UP[5]" -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[81] -to "fifo:int_fifo|fifo__full_empty_ctr:u_full_empty_ctr|UP[6]" -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[82] -to "fifo:int_fifo|fifo__full_empty_ctr:u_full_empty_ctr|UP[7]" -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[83] -to "registers:u_registers|registers_istr:u_registers_istr|ISTR_O[0]" -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[84] -to "registers:u_registers|registers_istr:u_registers_istr|ISTR_O[1]" -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[85] -to "registers:u_registers|registers_istr:u_registers_istr|ISTR_O[2]" -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[86] -to "registers:u_registers|registers_istr:u_registers_istr|ISTR_O[3]" -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[87] -to "registers:u_registers|registers_istr:u_registers_istr|ISTR_O[4]" -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[88] -to "registers:u_registers|registers_istr:u_registers_istr|ISTR_O[5]" -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[89] -to "registers:u_registers|registers_istr:u_registers_istr|ISTR_O[6]" -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[90] -to "registers:u_registers|registers_istr:u_registers_istr|ISTR_O[7]" -section_id auto_signaltap_0
	set_instance_assignment -name CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[91] -to "registers:u_registers|registers_istr:u_registers_istr|ISTR_O[8]" -section_id auto_signaltap_0
	set_instance_assignment -name POST_FIT_CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[92] -to "CPU_SM:u_CPU_SM|STOPFLUSH" -section_id auto_signaltap_0
	set_instance_assignment -name POST_FIT_CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[93] -to "fifo:int_fifo|fifo__full_empty_ctr:u_full_empty_ctr|FIFOEMPTY" -section_id auto_signaltap_0
	set_instance_assignment -name POST_FIT_CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[94] -to "fifo:int_fifo|fifo__full_empty_ctr:u_full_empty_ctr|FIFOFULL" -section_id auto_signaltap_0
	set_instance_assignment -name POST_FIT_CONNECT_TO_SLD_NODE_ENTITY_PORT acq_data_in[95] -to "registers:u_registers|FLUSHFIFO" -section_id auto_signaltap_0
	set_instance_assignment -name POST_FIT_CONNECT_TO_SLD_NODE_ENTITY_PORT crc[1] -to auto_signaltap_0|vcc -section_id auto_signaltap_0
	set_instance_assignment -name POST_FIT_CONNECT_TO_SLD_NODE_ENTITY_PORT crc[3] -to auto_signaltap_0|gnd -section_id auto_signaltap_0
	set_instance_assignment -name POST_FIT_CONNECT_TO_SLD_NODE_ENTITY_PORT crc[4] -to auto_signaltap_0|vcc -section_id auto_signaltap_0
	set_instance_assignment -name POST_FIT_CONNECT_TO_SLD_NODE_ENTITY_PORT crc[5] -to auto_signaltap_0|gnd -section_id auto_signaltap_0
	set_instance_assignment -name POST_FIT_CONNECT_TO_SLD_NODE_ENTITY_PORT crc[6] -to auto_signaltap_0|gnd -section_id auto_signaltap_0
	set_instance_assignment -name POST_FIT_CONNECT_TO_SLD_NODE_ENTITY_PORT crc[8] -to auto_signaltap_0|gnd -section_id auto_signaltap_0
	set_instance_assignment -name POST_FIT_CONNECT_TO_SLD_NODE_ENTITY_PORT crc[11] -to auto_signaltap_0|gnd -section_id auto_signaltap_0
	set_instance_assignment -name POST_FIT_CONNECT_TO_SLD_NODE_ENTITY_PORT crc[14] -to auto_signaltap_0|gnd -section_id auto_signaltap_0
	set_instance_assignment -name POST_FIT_CONNECT_TO_SLD_NODE_ENTITY_PORT crc[20] -to auto_signaltap_0|vcc -section_id auto_signaltap_0
	set_instance_assignment -name POST_FIT_CONNECT_TO_SLD_NODE_ENTITY_PORT crc[24] -to auto_signaltap_0|gnd -section_id auto_signaltap_0
	set_instance_assignment -name POST_FIT_CONNECT_TO_SLD_NODE_ENTITY_PORT crc[25] -to auto_signaltap_0|gnd -section_id auto_signaltap_0
	set_instance_assignment -name POST_FIT_CONNECT_TO_SLD_NODE_ENTITY_PORT crc[27] -to auto_signaltap_0|vcc -section_id auto_signaltap_0
	set_instance_assignment -name POST_FIT_CONNECT_TO_SLD_NODE_ENTITY_PORT crc[28] -to auto_signaltap_0|vcc -section_id auto_signaltap_0
	set_instance_assignment -name POST_FIT_CONNECT_TO_SLD_NODE_ENTITY_PORT crc[29] -to auto_signaltap_0|gnd -section_id auto_signaltap_0
	set_instance_assignment -name POST_FIT_CONNECT_TO_SLD_NODE_ENTITY_PORT crc[30] -to auto_signaltap_0|gnd -section_id auto_signaltap_0
	set_instance_assignment -name POST_FIT_CONNECT_TO_SLD_NODE_ENTITY_PORT crc[31] -to auto_signaltap_0|vcc -section_id auto_signaltap_0
	set_instance_assignment -name PARTITION_HIERARCHY root_partition -to | -section_id Top

	# Commit assignments
	export_assignments
	
	execute_flow -compile

	# Close project
	project_close
	
}
