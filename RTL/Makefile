###########################################################################
## Xilinx ISE Makefile
##
## To the extent possible under law, the author(s) have dedicated all copyright
## and related and neighboring rights to this software to the public domain
## worldwide. This software is distributed without any warranty.
###########################################################################

include project.cfg


###########################################################################
# Default values
###########################################################################

ifndef XILINX
    $(error XILINX must be defined)
endif

ifndef PROJECT
    $(error PROJECT must be defined)
endif

ifndef TARGET_PART
    $(error TARGET_PART must be defined)
endif

TOPLEVEL        ?= $(PROJECT)
CONSTRAINTS     ?= $(PROJECT).ucf

COMMON_OPTS     ?= -intstyle xflow
XST_OPTS        ?=
NGDBUILD_OPTS   ?=

TEST_POSTFIX	?= _tb

XC3SPROG_EXE    ?= xc3sprog
XC3SPROG_CABLE  ?= JTAGHS2
XC3SPROG_OPTS   ?= -v -e -p 0 #-J 150000

###########################################################################
# Internal variables, platform-specific definitions, and macros
###########################################################################

ifeq ($(OS),Windows_NT)
    XILINX := $(shell cygpath -m $(XILINX))
    CYG_XILINX := $(shell cygpath $(XILINX))
    EXE := .exe
    XILINX_PLATFORM ?= nt64
    PATH := $(PATH):$(CYG_XILINX)/bin/$(XILINX_PLATFORM)
else
    EXE :=
    XILINX_PLATFORM ?= lin64
    PATH := $(PATH):$(XILINX)/bin/$(XILINX_PLATFORM)
endif


#VTEST = $(foreach file,$(wildcard *$(TEST_POSTFIX).v),$(file))
#VHDTEST = $(foreach file,$(wildcard *$(TEST_POSTFIX).vhd),$(file))
TEST_NAMES = $(foreach file,$(VTEST) $(VHDTEST),$(basename $(file)))
TEST_EXES = $(foreach test,$(TEST_NAMES),build/isim_$(test)$(EXE))


RUN = @echo "\n\e[1;33m$(shell date +"%Y-%m-%d %T"): ======== $(1) ========\e[m\n"; \
	cd build && $(XILINX)/bin/$(XILINX_PLATFORM)/$(1)

# isim executables don't work without this
export XILINX


###########################################################################
# Default build
###########################################################################

default: clean cpld

all: clean cpld prog

clean:
	rm -rf build

build/$(PROJECT).prj: project.cfg
	@echo "Updating $@"
	@mkdir -p build
	@rm -f $@
	@$(foreach file,$(VSOURCE),echo "verilog work \"../$(file)\"" >> $@;)
	@$(foreach file,$(VHDSOURCE),echo "vhdl work \"../$(file)\"" >> $@;)

build/$(PROJECT).scr: project.cfg
	@echo "Updating $@"
	@mkdir -p build
	@rm -f $@
	@echo "run" \
	    "-ifn $(PROJECT).prj" \
	    "-ofn $(PROJECT).ngc" \
	    "-ifmt mixed" \
	    "$(XST_OPTS)" \
	    "-top $(TOPLEVEL)" \
	    "-ofmt NGC" \
	    "-p $(TARGET_PART)" \
	    > build/$(PROJECT).scr

build/$(PROJECT)_sim.prj: build/$(PROJECT).prj
	@cp build/$(PROJECT).prj $@
	@$(foreach file,$(VTEST),echo "verilog work \"../$(file)\"" >> $@;)
	@$(foreach file,$(VHDTEST),echo "vhdl work \"../$(file)\"" >> $@;)
	@echo "verilog work $(XILINX)/verilog/src/glbl.v" >> $@
	
# make CPLD: xst -> ngdbuild -> cpldfit -> hprep6
cpld: project.cfg $(VSOURCE) $(CONSTRAINTS) build/$(PROJECT).prj build/$(PROJECT).scr
	@mkdir -p  build/  build/xst/  build/ngdbuild/  build/cpldfit/  build/hprep6/

# input the HDL sources, output an NGC; move all files to xst/
	$(call RUN,xst) $(COMMON_OPTS) $(XST_OPTS) \
	    -ifn $(PROJECT).scr
	@find build/ -maxdepth 1 -type f -print0 | xargs -0 mv -t build/xst/

# input the NGC and the UCF, output a NGD
	$(call RUN,ngdbuild) $(COMMON_OPTS) $(NGDBUILD_OPTS) -p $(TARGET_PART) \
		-uc ../$(CONSTRAINTS) \
	    xst/$(PROJECT).ngc \
		ngdbuild/$(PROJECT).ngd
	@find build/ -maxdepth 1 -type f -print0 | xargs -0 mv -t build/ngdbuild/
	@mv -f build/xlnx_auto_0_xdb/ build/ngdbuild/

# input the NGD, output a VM6 (UG628 p.277)
	$(call RUN,cpldfit) $(COMMON_OPTS) $(CPLDFITFLAGS) \
	    -p $(TARGET_PART) \
	    ngdbuild/$(PROJECT).ngd
	
	@find build/ -maxdepth 1 -type f -print0 | xargs -0 mv -t build/cpldfit/

# input the VM6, output a JED (UG628 p.291)
	$(call RUN,hprep6) -i cpldfit/$(PROJECT).vm6
	@find build/ -maxdepth 1 -type f -print0 | xargs -0 mv -t build/hprep6/
#	@echo "\e[1;32m======== OK ========\e[m\n"
	@cp build/hprep6/$(PROJECT).jed ./build/$(PROJECT).jed
	@echo "\n\e[1;32m$(shell date +"%Y-%m-%d %T"): ======== OK ========\e[m"
	@echo "CPLD build output at ./build/$(PROJECT).jed \n"

##########################################################################
# Testing (work in progress)
###########################################################################

trace: project.cfg $(BITFILE)
	$(call RUN,trce) $(COMMON_OPTS) $(TRACE_OPTS) \
	    $(PROJECT).ncd $(PROJECT).pcf

test: buildtest runtest

runtest: ${TEST_NAMES}

${TEST_NAMES}:
	@grep --no-filename --no-messages 'ISIM:' $@.{v,vhd} | cut -d: -f2 > build/isim_$@.cmd
	@echo "run all" >> build/isim_$@.cmd
	cd build ; ./isim_$@$(EXE) -tclbatch isim_$@.cmd ;
	if grep -q ERROR build/$@.error; then vcd build/$@.vcd ; exit 1; fi

buildtest: ${TEST_EXES}

build/isim_%$(EXE): build/$(PROJECT)_sim.prj $(VSOURCE) $(VHDSOURCE) ${VTEST} $(VHDTEST)
	$(call RUN,fuse) $(COMMON_OPTS) $(FUSE_OPTS) \
	    -prj $(PROJECT)_sim.prj \
	    -d test=$* -d vcd=$*.vcd \
	    -o isim_$*$(EXE) \
	    work.$* work.glbl

###########################################################################
# Programming
###########################################################################

prog:
	$(XC3SPROG_EXE) -c $(XC3SPROG_CABLE) $(XC3SPROG_OPTS) ./build/$(PROJECT).jed 

###########################################################################

# vim: set filetype=make: #
