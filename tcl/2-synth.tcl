## Run synthesis
synth_design -top top -part $part -flatten_hierarchy rebuilt
write_checkpoint -force $outdir/post_synth
# Create simulation sources
write_vhdl -mode funcsim -force $outdir/top_funcsim_post_synth.vhd
write_verilog -mode timesim -force $outdir/top_timesim_post_synth.v

