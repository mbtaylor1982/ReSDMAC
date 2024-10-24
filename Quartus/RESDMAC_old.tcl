# Copyright (C) 1991-2013 Altera Corporation
# Your use of Altera Corporation's design tools, logic functions 
# and other software and tools, and its AMPP partner logic 
# functions, and any output files from any of the foregoing 
# (including device programming or simulation files), and any 
# associated documentation or information are expressly subject 
# to the terms and conditions of the Altera Program License 
# Subscription Agreement, Altera MegaCore Function License 
# Agreement, or other applicable license agreement, including, 
# without limitation, that your use is for the sole purpose of 
# programming logic devices manufactured by Altera and sold by 
# Altera or its authorized distributors.  Please refer to the 
# applicable agreement for further details.

# Quartus II: Generate Tcl File for Project
# File: RESDMAC.tcl
# Generated on: Mon Aug 28 17:15:46 2023

# Load Quartus II Tcl Project package
package require ::quartus::project

set need_to_close_project 0
set make_assignments 1

# Check that the right project is open
if {[is_project_open]} {
	if {[string compare $quartus(project) "RESDMAC"]} {
		puts "Project RESDMAC is not open"
		set make_assignments 0
	}
} else {
	# Only open if not already open
	if {[project_exists RESDMAC]} {
		project_open -revision RESDMAC RESDMAC
	} else {
		project_new -revision RESDMAC RESDMAC
	}
	set need_to_close_project 1
}

# Make assignments
if {$make_assignments} {
	set_global_assignment -name FAMILY "Cyclone II"
	set_global_assignment -name DEVICE EP2C5T144C8
	set_global_assignment -name ORIGINAL_QUARTUS_VERSION "13.0 SP1"
	set_global_assignment -name PROJECT_CREATION_TIME_DATE "23:14:24  DECEMBER 29, 2022"
	set_global_assignment -name LAST_QUARTUS_VERSION "13.0 SP1"
	set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
	set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
	set_global_assignment -name MAX_CORE_JUNCTION_TEMP 85
	set_global_assignment -name DEVICE_FILTER_PACKAGE TQFP
	set_global_assignment -name DEVICE_FILTER_PIN_COUNT 144
	set_global_assignment -name DEVICE_FILTER_SPEED_GRADE 8
	set_global_assignment -name ERROR_CHECK_FREQUENCY_DIVISOR 1
	set_global_assignment -name EDA_SIMULATION_TOOL "ModelSim-Altera (Verilog)"
	set_global_assignment -name EDA_OUTPUT_DATA_FORMAT "VERILOG HDL" -section_id eda_simulation
	set_global_assignment -name STRATIX_DEVICE_IO_STANDARD "3.3-V LVTTL"
	set_global_assignment -name PARTITION_NETLIST_TYPE SOURCE -section_id Top
	set_global_assignment -name PARTITION_FITTER_PRESERVATION_LEVEL PLACEMENT_AND_ROUTING -section_id Top
	set_global_assignment -name PARTITION_COLOR 16764057 -section_id Top
	set_global_assignment -name SEARCH_PATH "c:\\users\\mbtay\\sdmac-replacement\\rtl\\cpu_sm"
	set_global_assignment -name SEARCH_PATH "c:\\users\\mbtay\\sdmac-replacement\\rtl\\datapath"
	set_global_assignment -name SEARCH_PATH "c:\\users\\mbtay\\sdmac-replacement\\rtl\\fifo"
	set_global_assignment -name SEARCH_PATH "c:\\users\\mbtay\\sdmac-replacement\\rtl\\registers"
	set_global_assignment -name SEARCH_PATH "c:\\users\\mbtay\\sdmac-replacement\\rtl\\scsi_sm"
	set_global_assignment -name USE_CONFIGURATION_DEVICE ON
	set_global_assignment -name STRATIX_CONFIGURATION_DEVICE EPCS4
	set_global_assignment -name RESERVE_ALL_UNUSED_PINS "AS INPUT TRI-STATED"
	set_global_assignment -name RESERVE_ALL_UNUSED_PINS_NO_OUTPUT_GND "AS INPUT TRI-STATED"
	set_global_assignment -name POWER_PRESET_COOLING_SOLUTION "23 MM HEAT SINK WITH 200 LFPM AIRFLOW"
	set_global_assignment -name POWER_BOARD_THERMAL_MODEL "NONE (CONSERVATIVE)"
	set_global_assignment -name REMOVE_REDUNDANT_LOGIC_CELLS ON
	set_global_assignment -name AUTO_SHIFT_REGISTER_RECOGNITION ALWAYS
	set_global_assignment -name ADV_NETLIST_OPT_SYNTH_WYSIWYG_REMAP ON
	set_global_assignment -name CYCLONEII_OPTIMIZATION_TECHNIQUE SPEED
	set_global_assignment -name MUX_RESTRUCTURE OFF
	set_global_assignment -name ALLOW_ANY_ROM_SIZE_FOR_RECOGNITION ON
	set_global_assignment -name ALLOW_ANY_RAM_SIZE_FOR_RECOGNITION ON
	set_global_assignment -name ALLOW_ANY_SHIFT_REGISTER_SIZE_FOR_RECOGNITION ON
	set_global_assignment -name ALLOW_SHIFT_REGISTER_MERGING_ACROSS_HIERARCHIES ALWAYS
	set_global_assignment -name PHYSICAL_SYNTHESIS_COMBO_LOGIC_FOR_AREA ON
	set_global_assignment -name PHYSICAL_SYNTHESIS_MAP_LOGIC_TO_MEMORY_FOR_AREA ON
	set_global_assignment -name AUTO_RAM_RECOGNITION ON
	set_global_assignment -name FITTER_EFFORT "STANDARD FIT"
	set_global_assignment -name OPTIMIZE_HOLD_TIMING "ALL PATHS"
	set_global_assignment -name OPTIMIZE_MULTI_CORNER_TIMING ON
	set_global_assignment -name PLACEMENT_EFFORT_MULTIPLIER 2.0
	set_global_assignment -name OPTIMIZE_TIMING "NORMAL COMPILATION"
	set_global_assignment -name SMART_RECOMPILE ON
	set_global_assignment -name ENABLE_DRC_SETTINGS ON
	set_global_assignment -name PHYSICAL_SYNTHESIS_COMBO_LOGIC ON
	set_global_assignment -name PHYSICAL_SYNTHESIS_REGISTER_DUPLICATION ON
	set_global_assignment -name PHYSICAL_SYNTHESIS_REGISTER_RETIMING ON
	set_global_assignment -name ROUTER_TIMING_OPTIMIZATION_LEVEL MAXIMUM
	set_global_assignment -name AUTO_PACKED_REGISTERS_STRATIXII NORMAL
	set_global_assignment -name SYNTH_TIMING_DRIVEN_SYNTHESIS ON
	set_global_assignment -name ENABLE_SIGNALTAP ON
	set_global_assignment -name USE_SIGNALTAP_FILE output_files/stp1.stp
	set_global_assignment -name SLD_FILE "C:/Users/mbtay/SDMAC-Replacement/Quartus/output_files/stp1_auto_stripped.stp"
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
	set_global_assignment -name VERILOG_FILE ../RTL/CPU_SM/cpudff5.v
	set_global_assignment -name VERILOG_FILE ../RTL/CPU_SM/cpudff4.v
	set_global_assignment -name VERILOG_FILE ../RTL/CPU_SM/cpudff3.v
	set_global_assignment -name VERILOG_FILE ../RTL/CPU_SM/cpudff2.v
	set_global_assignment -name VERILOG_FILE ../RTL/CPU_SM/cpudff1.v
	set_global_assignment -name VERILOG_FILE ../RTL/CPU_SM/CPU_SM_output.v
	set_global_assignment -name VERILOG_FILE ../RTL/CPU_SM/CPU_SM_inputs.v
	set_global_assignment -name VERILOG_FILE ../RTL/CPU_SM/CPU_SM.v
	set_global_assignment -name VERILOG_FILE ../RTL/RESDMAC.v
	set_global_assignment -name SDC_FILE RESDMAC.sdc
	set_global_assignment -name CDF_FILE output_files/RESDMAC.cdf
	set_global_assignment -name QIP_FILE atpll.qip
	set_global_assignment -name SIGNALTAP_FILE output_files/stp1.stp
	set_location_assignment PIN_27 -to DATA_IO[31]
	set_location_assignment PIN_137 -to DATA_IO[0]
	set_location_assignment PIN_139 -to DATA_IO[1]
	set_location_assignment PIN_24 -to DATA_IO[30]
	set_location_assignment PIN_25 -to DATA_IO[29]
	set_location_assignment PIN_58 -to DATA_IO[28]
	set_location_assignment PIN_52 -to DATA_IO[27]
	set_location_assignment PIN_57 -to DATA_IO[26]
	set_location_assignment PIN_8 -to DATA_IO[25]
	set_location_assignment PIN_4 -to DATA_IO[24]
	set_location_assignment PIN_103 -to DATA_IO[23]
	set_location_assignment PIN_104 -to DATA_IO[22]
	set_location_assignment PIN_113 -to DATA_IO[21]
	set_location_assignment PIN_112 -to DATA_IO[20]
	set_location_assignment PIN_115 -to DATA_IO[19]
	set_location_assignment PIN_141 -to DATA_IO[2]
	set_location_assignment PIN_142 -to DATA_IO[3]
	set_location_assignment PIN_143 -to DATA_IO[4]
	set_location_assignment PIN_136 -to DATA_IO[5]
	set_location_assignment PIN_134 -to DATA_IO[6]
	set_location_assignment PIN_135 -to DATA_IO[7]
	set_location_assignment PIN_133 -to DATA_IO[8]
	set_location_assignment PIN_132 -to DATA_IO[9]
	set_location_assignment PIN_126 -to DATA_IO[10]
	set_location_assignment PIN_122 -to DATA_IO[11]
	set_location_assignment PIN_129 -to DATA_IO[12]
	set_location_assignment PIN_121 -to DATA_IO[13]
	set_location_assignment PIN_125 -to DATA_IO[14]
	set_location_assignment PIN_120 -to DATA_IO[15]
	set_location_assignment PIN_118 -to DATA_IO[16]
	set_location_assignment PIN_119 -to DATA_IO[17]
	set_location_assignment PIN_114 -to DATA_IO[18]
	set_location_assignment PIN_17 -to SCLK
	set_location_assignment PIN_97 -to ADDR[2]
	set_location_assignment PIN_100 -to ADDR[3]
	set_location_assignment PIN_93 -to ADDR[4]
	set_location_assignment PIN_99 -to ADDR[5]
	set_location_assignment PIN_96 -to ADDR[6]
	set_location_assignment PIN_42 -to PD_PORT[7]
	set_location_assignment PIN_40 -to PD_PORT[6]
	set_location_assignment PIN_43 -to PD_PORT[5]
	set_location_assignment PIN_44 -to PD_PORT[4]
	set_location_assignment PIN_45 -to PD_PORT[3]
	set_location_assignment PIN_47 -to PD_PORT[2]
	set_location_assignment PIN_48 -to PD_PORT[1]
	set_location_assignment PIN_51 -to PD_PORT[0]
	set_location_assignment PIN_3 -to _LED_DMA
	set_location_assignment PIN_7 -to _LED_RD
	set_location_assignment PIN_9 -to _LED_WR
	set_location_assignment PIN_63 -to PDATA_OE_
	set_location_assignment PIN_26 -to PD_PORT[15]
	set_location_assignment PIN_65 -to PD_PORT[14]
	set_location_assignment PIN_67 -to PD_PORT[13]
	set_location_assignment PIN_30 -to PD_PORT[12]
	set_location_assignment PIN_28 -to PD_PORT[11]
	set_location_assignment PIN_32 -to PD_PORT[10]
	set_location_assignment PIN_31 -to PD_PORT[9]
	set_location_assignment PIN_41 -to PD_PORT[8]
	set_location_assignment PIN_73 -to _RST
	set_location_assignment PIN_91 -to _STERM
	set_location_assignment PIN_69 -to R_W_IO
	set_location_assignment PIN_55 -to DATA_OE_
	set_location_assignment PIN_94 -to INTA
	set_location_assignment PIN_72 -to _AS_IO
	set_location_assignment PIN_53 -to _BERR
	set_location_assignment PIN_101 -to _BG
	set_location_assignment PIN_75 -to _BGACK_IO
	set_location_assignment PIN_92 -to _CS
	set_location_assignment PIN_80 -to _CSS
	set_location_assignment PIN_79 -to _DACK
	set_location_assignment PIN_60 -to _DMAEN
	set_location_assignment PIN_88 -to _DREQ
	set_location_assignment PIN_74 -to _DSACK_IO[1]
	set_location_assignment PIN_144 -to _DSACK_IO[0]
	set_location_assignment PIN_71 -to _DS_IO
	set_location_assignment PIN_86 -to _IOR
	set_location_assignment PIN_81 -to _IOW
	set_location_assignment PIN_64 -to INT
	set_location_assignment PIN_87 -to BR
	set_location_assignment PIN_70 -to OWN
	set_location_assignment PIN_59 -to _SIZ1
	set_instance_assignment -name OUTPUT_PIN_LOAD 8 -to BR
	set_instance_assignment -name OUTPUT_PIN_LOAD 8 -to DATA_OE_
	set_instance_assignment -name OUTPUT_PIN_LOAD 8 -to INT
	set_instance_assignment -name OUTPUT_PIN_LOAD 8 -to OWN
	set_instance_assignment -name OUTPUT_PIN_LOAD 8 -to PDATA_OE_
	set_instance_assignment -name OUTPUT_PIN_LOAD 8 -to _CSS
	set_instance_assignment -name OUTPUT_PIN_LOAD 8 -to _DACK
	set_instance_assignment -name OUTPUT_PIN_LOAD 8 -to _DMAEN
	set_instance_assignment -name OUTPUT_PIN_LOAD 8 -to _IOR
	set_instance_assignment -name OUTPUT_PIN_LOAD 8 -to _IOW
	set_instance_assignment -name OUTPUT_PIN_LOAD 8 -to _LED_DMA
	set_instance_assignment -name OUTPUT_PIN_LOAD 8 -to _LED_RD
	set_instance_assignment -name OUTPUT_PIN_LOAD 8 -to _LED_WR
	set_instance_assignment -name OUTPUT_PIN_LOAD 8 -to _SIZ1
	set_instance_assignment -name OUTPUT_PIN_LOAD 80 -to DATA_IO[0]
	set_instance_assignment -name OUTPUT_PIN_LOAD 80 -to DATA_IO[1]
	set_instance_assignment -name OUTPUT_PIN_LOAD 80 -to DATA_IO[2]
	set_instance_assignment -name OUTPUT_PIN_LOAD 80 -to DATA_IO[3]
	set_instance_assignment -name OUTPUT_PIN_LOAD 80 -to DATA_IO[4]
	set_instance_assignment -name OUTPUT_PIN_LOAD 80 -to DATA_IO[5]
	set_instance_assignment -name OUTPUT_PIN_LOAD 80 -to DATA_IO[6]
	set_instance_assignment -name OUTPUT_PIN_LOAD 80 -to DATA_IO[7]
	set_instance_assignment -name OUTPUT_PIN_LOAD 80 -to DATA_IO[8]
	set_instance_assignment -name OUTPUT_PIN_LOAD 80 -to DATA_IO[9]
	set_instance_assignment -name OUTPUT_PIN_LOAD 80 -to DATA_IO[10]
	set_instance_assignment -name OUTPUT_PIN_LOAD 80 -to DATA_IO[11]
	set_instance_assignment -name OUTPUT_PIN_LOAD 80 -to DATA_IO[12]
	set_instance_assignment -name OUTPUT_PIN_LOAD 80 -to DATA_IO[13]
	set_instance_assignment -name OUTPUT_PIN_LOAD 80 -to DATA_IO[14]
	set_instance_assignment -name OUTPUT_PIN_LOAD 80 -to DATA_IO[15]
	set_instance_assignment -name OUTPUT_PIN_LOAD 80 -to DATA_IO[16]
	set_instance_assignment -name OUTPUT_PIN_LOAD 80 -to DATA_IO[17]
	set_instance_assignment -name OUTPUT_PIN_LOAD 80 -to DATA_IO[18]
	set_instance_assignment -name OUTPUT_PIN_LOAD 80 -to DATA_IO[19]
	set_instance_assignment -name OUTPUT_PIN_LOAD 80 -to DATA_IO[20]
	set_instance_assignment -name OUTPUT_PIN_LOAD 80 -to DATA_IO[21]
	set_instance_assignment -name OUTPUT_PIN_LOAD 80 -to DATA_IO[22]
	set_instance_assignment -name OUTPUT_PIN_LOAD 80 -to DATA_IO[23]
	set_instance_assignment -name OUTPUT_PIN_LOAD 80 -to DATA_IO[24]
	set_instance_assignment -name OUTPUT_PIN_LOAD 80 -to DATA_IO[25]
	set_instance_assignment -name OUTPUT_PIN_LOAD 80 -to DATA_IO[26]
	set_instance_assignment -name OUTPUT_PIN_LOAD 80 -to DATA_IO[27]
	set_instance_assignment -name OUTPUT_PIN_LOAD 80 -to DATA_IO[28]
	set_instance_assignment -name OUTPUT_PIN_LOAD 80 -to DATA_IO[29]
	set_instance_assignment -name OUTPUT_PIN_LOAD 80 -to DATA_IO[30]
	set_instance_assignment -name OUTPUT_PIN_LOAD 80 -to DATA_IO[31]
	set_instance_assignment -name OUTPUT_PIN_LOAD 80 -to PD_PORT[0]
	set_instance_assignment -name OUTPUT_PIN_LOAD 80 -to PD_PORT[1]
	set_instance_assignment -name OUTPUT_PIN_LOAD 80 -to PD_PORT[2]
	set_instance_assignment -name OUTPUT_PIN_LOAD 80 -to PD_PORT[3]
	set_instance_assignment -name OUTPUT_PIN_LOAD 80 -to PD_PORT[4]
	set_instance_assignment -name OUTPUT_PIN_LOAD 80 -to PD_PORT[5]
	set_instance_assignment -name OUTPUT_PIN_LOAD 80 -to PD_PORT[6]
	set_instance_assignment -name OUTPUT_PIN_LOAD 80 -to PD_PORT[7]
	set_instance_assignment -name OUTPUT_PIN_LOAD 80 -to PD_PORT[8]
	set_instance_assignment -name OUTPUT_PIN_LOAD 80 -to PD_PORT[9]
	set_instance_assignment -name OUTPUT_PIN_LOAD 80 -to PD_PORT[10]
	set_instance_assignment -name OUTPUT_PIN_LOAD 80 -to PD_PORT[11]
	set_instance_assignment -name OUTPUT_PIN_LOAD 80 -to PD_PORT[12]
	set_instance_assignment -name OUTPUT_PIN_LOAD 80 -to PD_PORT[13]
	set_instance_assignment -name OUTPUT_PIN_LOAD 80 -to PD_PORT[14]
	set_instance_assignment -name OUTPUT_PIN_LOAD 80 -to PD_PORT[15]
	set_instance_assignment -name OUTPUT_PIN_LOAD 80 -to R_W_IO
	set_instance_assignment -name OUTPUT_PIN_LOAD 80 -to _AS_IO
	set_instance_assignment -name OUTPUT_PIN_LOAD 80 -to _BGACK_IO
	set_instance_assignment -name OUTPUT_PIN_LOAD 80 -to _DSACK_IO[0]
	set_instance_assignment -name OUTPUT_PIN_LOAD 80 -to _DSACK_IO[1]
	set_instance_assignment -name OUTPUT_PIN_LOAD 80 -to _DS_IO
	set_instance_assignment -name PARTITION_HIERARCHY root_partition -to | -section_id Top

	# Commit assignments
	export_assignments

	# Close project
	if {$need_to_close_project} {
		project_close
	}
}
