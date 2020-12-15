# Create output directory
set output_dir ./outputs
file mkdir $output_dir

# Read Source files
read_verilog -sv ../../../CH1/hdl/logic_ex.sv
read_xdc ../../../CH1/build/xdc/Nexys-A7-100T-Master.xdc

# Run Synthesis
synth_design -top logic_ex -part xc7a100tcsg324-1

write_checkpoint -force $output_dir/post_synth

#report_timing_summary
#report_power

# Run post synthesis optimization
opt_design
write_checkpoint -force $output_dir/post_synth_opt

# Run placement
place_design
write_checkpoint -force $output_dir/post_place

# Run post placement optimization -- This can be run as many times
# as it makes sense
phys_opt_design
write_checkpoint -force $output_dir/post_physopt

# Route the design
route_design
write_checkpoint -force $output_dir/post_route

# Post route physical optimization -- Can be looped
#phys_opt_design -placement_opt -routing_opt -rewire -critical_cell_opt -clock_opt -retime

# run reports
#report_timing_summary
#report_timing

# write out verilog netlist as desired
write_verilog -force $output_dir/logic_ex_post.v
write_xdc -no_fixed_only -force $output_dir/logic_ex_post.xdc

# Generate bitstream
write_bitstream -force $output_dir/logic_ex.bit
