transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/mbtay/SDMAC-Replacement/RTL {C:/Users/mbtay/SDMAC-Replacement/RTL/PLL.v}
vlog -vlog01compat -work work +incdir+C:/Users/mbtay/SDMAC-Replacement/RTL/SCSI_SM {C:/Users/mbtay/SDMAC-Replacement/RTL/SCSI_SM/scsi_sm_outputs.v}
vlog -vlog01compat -work work +incdir+C:/Users/mbtay/SDMAC-Replacement/RTL/SCSI_SM {C:/Users/mbtay/SDMAC-Replacement/RTL/SCSI_SM/scsi_sm_inputs.v}
vlog -vlog01compat -work work +incdir+C:/Users/mbtay/SDMAC-Replacement/RTL/SCSI_SM {C:/Users/mbtay/SDMAC-Replacement/RTL/SCSI_SM/SCSI_SM.v}
vlog -vlog01compat -work work +incdir+C:/Users/mbtay/SDMAC-Replacement/RTL/Registers {C:/Users/mbtay/SDMAC-Replacement/RTL/Registers/registers_term.v}
vlog -vlog01compat -work work +incdir+C:/Users/mbtay/SDMAC-Replacement/RTL/Registers {C:/Users/mbtay/SDMAC-Replacement/RTL/Registers/registers_istr.v}
vlog -vlog01compat -work work +incdir+C:/Users/mbtay/SDMAC-Replacement/RTL/Registers {C:/Users/mbtay/SDMAC-Replacement/RTL/Registers/registers_cntr.v}
vlog -vlog01compat -work work +incdir+C:/Users/mbtay/SDMAC-Replacement/RTL/Registers {C:/Users/mbtay/SDMAC-Replacement/RTL/Registers/registers.v}
vlog -vlog01compat -work work +incdir+C:/Users/mbtay/SDMAC-Replacement/RTL/Registers {C:/Users/mbtay/SDMAC-Replacement/RTL/Registers/addr_decoder.v}
vlog -vlog01compat -work work +incdir+C:/Users/mbtay/SDMAC-Replacement/RTL/FIFO {C:/Users/mbtay/SDMAC-Replacement/RTL/FIFO/fifo_write_strobes.v}
vlog -vlog01compat -work work +incdir+C:/Users/mbtay/SDMAC-Replacement/RTL/FIFO {C:/Users/mbtay/SDMAC-Replacement/RTL/FIFO/fifo_full_empty_ctr.v}
vlog -vlog01compat -work work +incdir+C:/Users/mbtay/SDMAC-Replacement/RTL/FIFO {C:/Users/mbtay/SDMAC-Replacement/RTL/FIFO/fifo_byte_ptr.v}
vlog -vlog01compat -work work +incdir+C:/Users/mbtay/SDMAC-Replacement/RTL/FIFO {C:/Users/mbtay/SDMAC-Replacement/RTL/FIFO/fifo_3bit_cntr.v}
vlog -vlog01compat -work work +incdir+C:/Users/mbtay/SDMAC-Replacement/RTL/FIFO {C:/Users/mbtay/SDMAC-Replacement/RTL/FIFO/fifo.v}
vlog -vlog01compat -work work +incdir+C:/Users/mbtay/SDMAC-Replacement/RTL/datapath {C:/Users/mbtay/SDMAC-Replacement/RTL/datapath/datapath_scsi.v}
vlog -vlog01compat -work work +incdir+C:/Users/mbtay/SDMAC-Replacement/RTL/datapath {C:/Users/mbtay/SDMAC-Replacement/RTL/datapath/datapath_output.v}
vlog -vlog01compat -work work +incdir+C:/Users/mbtay/SDMAC-Replacement/RTL/datapath {C:/Users/mbtay/SDMAC-Replacement/RTL/datapath/datapath_input.v}
vlog -vlog01compat -work work +incdir+C:/Users/mbtay/SDMAC-Replacement/RTL/datapath {C:/Users/mbtay/SDMAC-Replacement/RTL/datapath/datapath_24dec.v}
vlog -vlog01compat -work work +incdir+C:/Users/mbtay/SDMAC-Replacement/RTL/datapath {C:/Users/mbtay/SDMAC-Replacement/RTL/datapath/datapath_8b_MUX.v}
vlog -vlog01compat -work work +incdir+C:/Users/mbtay/SDMAC-Replacement/RTL/datapath {C:/Users/mbtay/SDMAC-Replacement/RTL/datapath/datapath.v}
vlog -vlog01compat -work work +incdir+C:/Users/mbtay/SDMAC-Replacement/RTL/CPU_SM {C:/Users/mbtay/SDMAC-Replacement/RTL/CPU_SM/cpudff5.v}
vlog -vlog01compat -work work +incdir+C:/Users/mbtay/SDMAC-Replacement/RTL/CPU_SM {C:/Users/mbtay/SDMAC-Replacement/RTL/CPU_SM/cpudff4.v}
vlog -vlog01compat -work work +incdir+C:/Users/mbtay/SDMAC-Replacement/RTL/CPU_SM {C:/Users/mbtay/SDMAC-Replacement/RTL/CPU_SM/cpudff3.v}
vlog -vlog01compat -work work +incdir+C:/Users/mbtay/SDMAC-Replacement/RTL/CPU_SM {C:/Users/mbtay/SDMAC-Replacement/RTL/CPU_SM/cpudff2.v}
vlog -vlog01compat -work work +incdir+C:/Users/mbtay/SDMAC-Replacement/RTL/CPU_SM {C:/Users/mbtay/SDMAC-Replacement/RTL/CPU_SM/cpudff1.v}
vlog -vlog01compat -work work +incdir+C:/Users/mbtay/SDMAC-Replacement/RTL/CPU_SM {C:/Users/mbtay/SDMAC-Replacement/RTL/CPU_SM/CPU_SM_output.v}
vlog -vlog01compat -work work +incdir+C:/Users/mbtay/SDMAC-Replacement/RTL/CPU_SM {C:/Users/mbtay/SDMAC-Replacement/RTL/CPU_SM/CPU_SM_inputs.v}
vlog -vlog01compat -work work +incdir+C:/Users/mbtay/SDMAC-Replacement/RTL/CPU_SM {C:/Users/mbtay/SDMAC-Replacement/RTL/CPU_SM/CPU_SM.v}
vlog -vlog01compat -work work +incdir+C:/Users/mbtay/SDMAC-Replacement/RTL {C:/Users/mbtay/SDMAC-Replacement/RTL/RESDMAC.v}
vlog -vlog01compat -work work +incdir+C:/Users/mbtay/SDMAC-Replacement/Quartus {C:/Users/mbtay/SDMAC-Replacement/Quartus/atpll.v}

