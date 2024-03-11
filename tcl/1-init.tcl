# Create some build variables
set outdir ../build
set outfile $outdir/top.bit
set part xc7z010clg400-1

# Load files to memory
read_vhdl -vhdl2008 ../src/vhdl/top.vhd
read_vhdl -vhdl2008 ../src/vhdl/utils.vhd
read_xdc ../src/constraints/Zybo-Z7-Master.xdc

