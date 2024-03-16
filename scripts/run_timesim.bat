@REM
@REM Post synthesis timing simulation
@REM 

@ECHO OFF

@REM  Configure the path to run the Vivado Design Suite
CALL C:\Xilinx\Vivado\2020.2\settings64.bat

@REM Define Xilinx Vivado environment variable
SET XILINX_VIVADO=C:\Xilinx\Vivado\2020.2

CALL xvhdl -prj top-tb.prj --nolog
CALL xvlog -L xil_defaultlib "../build/top_timesim_post_synth.v"
CALL xelab xil_defaultlib.top_tb glbl -debug all --nolog -s top_timesim_post_synth
CALL xsim --nolog -g -view xil_defaultlib.top_tb.wcfg xil_defaultlib.top_tb