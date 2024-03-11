@REM
@REM Behaviour simulation
@REM 

@ECHO OFF

@REM  Configure the path to run the Vivado Design Suite
CALL C:\Xilinx\Vivado\2020.2\settings64.bat

@REM Define Xilinx Vivado environment variable
SET XILINX_VIVADO=C:\Xilinx\Vivado\2020.2

CALL xvhdl --nolog -prj top-tb.prj 
CALL xelab xil_defaultlib.top_tb -prj top-tb.prj -debug all --nolog
CALL xsim --nolog -g -view xil_defaultlib.top_tb.wcfg xil_defaultlib.top_tb
