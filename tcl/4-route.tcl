## Run router
route_design
write_checkpoint -force $outdir/post_route
# Create simulation sources
write_vhdl -mode funcsim -force $outdir/top_funcsim_post_route.vhd
write_verilog -mode timesim -force $outdir/top_timesim_post_route.v

write_xdc -no_fixed_only -force $outdir/top_impl.xdx


## Generate the bitstream
write_bitstream -force $outfile

