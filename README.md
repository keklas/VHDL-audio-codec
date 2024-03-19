# Development:
- Use vscode
- Install "VHDL" syntax highlighting extension


# Running simulation on windows
- Open PowerShell in the git repo
- `cd scripts`
- `.\run_csim.bat`, this opens the GUI
  - `top-tb.prj` defines the components of the testbench
  - Later on we can make a variable out of this so that its easy to select which testbench to run
- Once the GUI loads, open `Window/Waveform` to see the waveform

# TODO
The template contains reference to the following missing files, which I think we need to implement in this assignment:
- `src/vhdl/ac_audio.vhd`
- `src/vhdl/ac_control.vhd`
- `src/vhdl/mclk_gen.vhd`

