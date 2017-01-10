set TOP_LEVEL_NAME top_tb
# set TOP_LEVEL_NAME PFA_addr_tb

vlib work
#  com
vlog -sv ../RTL/tb/*
vlog -sv ../RTL/addr_gen/*
vlog -sv ../RTL/top/*
vlog -sv ../RTL/ctrl/*

# elab
# vmap       work     ./libraries/work/
vsim -t ps  -L work $TOP_LEVEL_NAME

add wave sim:/top_tb/*
add wave sim:/top_tb/top_mixed_radix_dft_0_inst/*


view structure
view signals
run 25us