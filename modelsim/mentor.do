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
vlog -sv ../RTL/radix/*

# elab
# vmap       work     ./libraries/work/
vsim -t ns  -L work $TOP_LEVEL_NAME

# radix signal sim:/....  unsigned
add wave -radix unsigned sim:/top_tb/*
add wave -radix unsigned sim:/top_tb/top_inst/*
add wave -radix unsigned sim:/top_tb/top_inst/ctrl_fsm/*
# add wave -radix unsigned sim:/top_tb/top_inst/mem0/*
# add wave -radix unsigned sim:/top_tb/top_inst/mem0/in_data/*
# add wave -radix unsigned sim:/top_tb/top_inst/mem0/ctrl/*
# add wave -radix unsigned sim:/top_tb/top_inst/mem0/stat_to_ctrl/*
# add wave -radix unsigned sim:/top_tb/top_inst/mem0/out_rdx2345_data/*
add wave -radix unsigned sim:/top_tb/top_inst/mem1/out_rdx2345_data/*
add wave -radix unsigned sim:/top_tb/top_inst/mem1/out_rdx2345_data/d_real
add wave -radix unsigned sim:/top_tb/top_inst/mem1/in_rdx2345_data/*
add wave -radix unsigned sim:/top_tb/top_inst/mem1/out_data/*
add wave -radix unsigned sim:/top_tb/top_inst/mem1/*
add wave -radix unsigned sim:/top_tb/top_inst/mem1/ctrl/*
add wave -radix unsigned sim:/top_tb/top_inst/mem1/stat_to_ctrl/*

add wave -radix decimal sim:/top_tb/top_inst/rdx2345_twdl/*
add wave -radix decimal sim:/top_tb/top_inst/rdx2345_twdl/dft_rdx4/*
add wave -radix decimal sim:/top_tb/top_inst/rdx2345_twdl/dft_rdx5/*
add wave -radix decimal sim:/top_tb/top_inst/rdx2345_twdl/dft_rdx3/*
add wave -radix decimal sim:/top_tb/top_inst/rdx2345_twdl/twdl/*
add wave -radix decimal sim:/top_tb/top_inst/rdx2345_twdl/twdl/dout_imag_t
add wave -radix decimal sim:/top_tb/top_inst/rdx2345_twdl/from_mem/*


view structure
view signals
run 50us