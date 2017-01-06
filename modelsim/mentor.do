set TOP_LEVEL_NAME PFA_addr_tb

vlib work
#  com
vlog -sv ../RTL/tb/PFA_addr_tb.v
vlog -sv ../RTL/addr_gen/acc_type1.v
vlog -sv ../RTL/addr_gen/acc_mod_type1.v
vlog -sv ../RTL/addr_gen/PFA_addr_trans.v
vlog -sv ../RTL/addr_gen/divider_7.v

# elab
# vmap       work     ./libraries/work/
vsim -t ps  -L work $TOP_LEVEL_NAME

add wave sim:/PFA_addr_tb/*
add wave sim:/PFA_addr_tb/PFA_addr_trans_inst/*
# add wave sim:/PFA_addr_tb/PFA_addr_trans_inst/acc_type1_n3/*
# add wave sim:/PFA_addr_tb/PFA_addr_trans_inst/acc_type1_n2p/*
# add wave sim:/PFA_addr_tb/PFA_addr_trans_inst/acc_type1_n1p/*
add wave sim:/PFA_addr_tb/PFA_addr_trans_inst/acc_mod_type1_n3/*
add wave sim:/PFA_addr_tb/PFA_addr_trans_inst/acc_mod_type1_n2p/*
add wave sim:/PFA_addr_tb/divider_7_inst/*

view structure
view signals
run 25us