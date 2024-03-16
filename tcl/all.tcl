# Synthesis, implementation, bitstream tcl superscript
# Inspiration taken from UG892 Non-Project Mode Tcl Script Example

## in any step you may run DRC by
# report_drc

## Load Tcl customization
source tcl/init.tcl

## Load variables
source tcl/variables.tcl

## Read source files
source tcl/load_sources.tcl

## Run synthesis, implementation, router and bitstream generation
source tcl/basic_run.tcl

## Upload the bitstream to the Zybo
source tcl/upload.tcl
