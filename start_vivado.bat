@REM 
@REM Configure settings and start Vivado 
@REM 

@ECHO OFF

CALL C:\Xilinx\Vivado\2020.2\settings64.bat
CALL vivado -mode tcl -nolog -nojournal
