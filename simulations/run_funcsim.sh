#!/bin/zsh
PATH=$PATH:/tools/Xilinx/Vivado/2021.2/bin/
xvhdl --nolog -prj top-tb.prj
xelab xil_defaultlib.top_tb -prj top-tb.prj -debug all --nolog
#xsim --nolog -g -view xil_defaultlib.top_tb.wcfg xil_defaultlib.top_tb
xsim --nolog -g  xil_defaultlib.top_tb
