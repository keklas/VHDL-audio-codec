## Run synthesis
synth_design -top top -part $part -flatten_hierarchy rebuilt
write_checkpoint -force $outdir/post_synth
write_vhdl -mode funcsim -force $outdir/top_funcsim_post_synth.vhd
write_verilog -mode timesim -force $outdir/top_timesim_post_synth.v

## Run implementation steps
opt_design
place_design
phys_opt_design
write_checkpoint -force $outdir/post_place
write_vhdl -mode funcsim -force $outdir/top_funcsim_post_impl.vhd
write_verilog -mode timesim -force $outdir/top_timesim_post_impl.v

## Run router
route_design
write_checkpoint -force $outdir/post_route
write_vhdl -mode funcsim -force $outdir/top_funcsim_post_route.vhd
write_verilog -mode timesim -force $outdir/top_timesim_post_route.v

write_xdc -no_fixed_only -force $outdir/top_impl.xdx


## Generate the bitstream
write_bitstream -force $outfile
