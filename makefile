#!/usr/bin/make -f
# defaults
SIM ?= icarus
TOPLEVEL_LANG ?= verilog
PWD=$(shell pwd)
export PYTHONPATH := $(PWD)/RTL/cocotb:$(PYTHONPATH)
VERILOG_SOURCES += $(PWD)/RTL/FIFO/fifo_3bit_cntr.v
TOPLEVEL = fifo_3bit_cntr
MODULE = cocotb_fifo_3bit_cntr
include $(shell cocotb-config --makefiles)/Makefile.sim
