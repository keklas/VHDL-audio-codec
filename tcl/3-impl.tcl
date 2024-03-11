## Run implementation steps
opt_design
place_design
phys_opt_design
write_checkpoint -force $outdir/post_place
# Create simulation sources
write_vhdl -mode funcsim -force $outdir/top_funcsim_post_impl.vhd
write_verilog -mode timesim -force $outdir/top_timesim_post_impl.v

