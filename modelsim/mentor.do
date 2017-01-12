set TOP_LEVEL_NAME top_tb
# set TOP_LEVEL_NAME PFA_addr_tb

vlib work
#  com
vlog -sv ../RTL/tb/*
vlog -sv ../RTL/addr_gen/*
vlog -sv ../RTL/top/*
vlog -sv ../RTL/ctrl/*
vlog -sv ../RTL/mem/*
vlog -sv ../RTL/switch/*

# elab
# vmap       work     ./libraries/work/
vsim -t ps  -L work $TOP_LEVEL_NAME

add wave sim:/top_tb/*
add wave sim:/top_tb/top_inst/*
add wave sim:/top_tb/top_inst/ctrl_fsm/*
add wave sim:/top_tb/top_inst/mem0/*
add wave sim:/top_tb/top_inst/mem0/in_data/*
add wave sim:/top_tb/top_inst/mem0/ctrl/*
add wave sim:/top_tb/top_inst/mem0/PFA_addr_trans_inst/*
add wave sim:/top_tb/top_inst/mem0/PFA_addr_trans_inst/acc_mod_type1_n3/*


view structure
view signals
run 25us