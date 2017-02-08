set TOP_LEVEL_NAME top_tb
# set TOP_LEVEL_NAME divider_pipe0_tb
# set TOP_LEVEL_NAME mrd_twdl_tb

vlib work
#  com
vlog -sv ../RTL/tb/*
vlog -sv ../RTL/addr_gen/*
vlog -sv ../RTL/top/*
vlog -sv ../RTL/ctrl/*
vlog -sv ../RTL/mem/*
vlog -sv ../RTL/switch/*
vlog -sv ../RTL/radix/*
vlog -sv ../RTL/twiddle/*

# elab
# vmap       work     ./libraries/work/
vsim -t ns  -L work $TOP_LEVEL_NAME

# radix signal sim:/....  unsigned

add wave -radix signed {sim:/top_tb/*}
# add wave -radix unsigned sim:/top_tb/top_inst/*
# add wave -radix unsigned sim:/top_tb/top_inst/ctrl_fsm/*

# add wave -radix signed {sim:/top_tb/top_inst/mem0/*}

# # Sink --> RAMs 
# add wave -radix signed {sim:/top_tb/top_inst/mem0/din_real_RAM}
# add wave -radix signed {sim:/top_tb/top_inst/mem0/din_imag_RAM}
# add wave -radix signed {sim:/top_tb/top_inst/mem0/wren}
# add wave -radix signed {sim:/top_tb/top_inst/mem0/wraddr_RAM}

# Read from RAMs
add wave -radix unsigned {sim:/top_tb/top_inst/mem0/rden}
add wave -radix unsigned {sim:/top_tb/top_inst/mem0/dout_real_RAM}
add wave -radix unsigned {sim:/top_tb/top_inst/mem0/dout_imag_RAM}
add wave -radix unsigned {sim:/top_tb/top_inst/mem0/rdaddr_RAM}
add wave -radix unsigned {sim:/top_tb/top_inst/mem0/twdl_numrtr}

add wave -radix unsigned {sim:/top_tb/top_inst/mem0/out_rdx2345_data/*}
add wave -radix unsigned {sim:/top_tb/top_inst/mem0/out_rdx2345_data/d_real}
add wave -radix unsigned {sim:/top_tb/top_inst/mem0/out_rdx2345_data/d_imag}
add wave -radix unsigned {sim:/top_tb/top_inst/mem0/ctrl/state}
add wave -radix unsigned {sim:/top_tb/top_inst/mem0/ctrl/current_stage}

# Source from RAMs
# add wave -radix unsigned {sim:/top_tb/top_inst/mem1/rden}
# add wave -radix unsigned {sim:/top_tb/top_inst/mem1/dout_real_RAM}
# add wave -radix unsigned {sim:/top_tb/top_inst/mem1/dout_imag_RAM}
# add wave -radix unsigned {sim:/top_tb/top_inst/mem1/rdaddr_RAM}
# add wave -radix unsigned {sim:/top_tb/top_inst/mem1/addr_source_CTA}
# add wave -radix unsigned {sim:/top_tb/top_inst/mem1/bank_addr_source}
# add wave -radix unsigned {sim:/top_tb/top_inst/mem1/bank_index_source}
# add wave -radix unsigned {sim:/top_tb/top_inst/mem1/out_data/*}

add wave -radix signed {sim:/top_tb/top_inst/rdx2345_twdl/dft_rdx5/in_val}
add wave -radix signed {sim:/top_tb/top_inst/rdx2345_twdl/dft_rdx5/din_real}
add wave -radix signed {sim:/top_tb/top_inst/rdx2345_twdl/dft_rdx5/din_imag}
add wave -radix signed {sim:/top_tb/top_inst/rdx2345_twdl/dft_rdx5/out_val}
add wave -radix signed {sim:/top_tb/top_inst/rdx2345_twdl/dft_rdx5/dout_real}
add wave -radix signed {sim:/top_tb/top_inst/rdx2345_twdl/dft_rdx5/dout_imag}

add wave -radix signed {sim:/top_tb/top_inst/rdx2345_twdl/twdl/*}
add wave -radix signed {sim:/top_tb/top_inst/rdx2345_twdl/twdl/d_real_r[0][21]}
add wave -radix signed {sim:/top_tb/top_inst/rdx2345_twdl/twdl/d_imag_r[0][21]}
add wave -radix signed {sim:/top_tb/top_inst/rdx2345_twdl/twdl/tw_real}
add wave -radix signed {sim:/top_tb/top_inst/rdx2345_twdl/twdl/tw_imag}
add wave -radix signed {sim:/top_tb/top_inst/rdx2345_twdl/twdl/dout_real_t}
add wave -radix signed {sim:/top_tb/top_inst/rdx2345_twdl/twdl/dout_imag_t}

add wave -radix signed {sim:/top_tb/top_inst/rdx2345_twdl/to_mem/*}
add wave -radix signed {sim:/top_tb/top_inst/rdx2345_twdl/to_mem/d_real}
add wave -radix signed {sim:/top_tb/top_inst/rdx2345_twdl/to_mem/d_imag}


# add wave -radix unsigned sim:/top_tb/top_inst/mem0/in_data/*
# add wave -radix unsigned sim:/top_tb/top_inst/mem0/ctrl/*
# add wave -radix unsigned sim:/top_tb/top_inst/mem0/stat_to_ctrl/*
# add wave -radix unsigned sim:/top_tb/top_inst/mem0/out_rdx2345_data/*

# add wave -radix unsigned sim:/top_tb/top_inst/mem1/out_rdx2345_data/*
# add wave -radix unsigned sim:/top_tb/top_inst/mem1/out_rdx2345_data/d_real
# add wave -radix unsigned sim:/top_tb/top_inst/mem1/in_rdx2345_data/*
# add wave -radix decimal sim:/top_tb/top_inst/mem1/in_rdx2345_data/d_real
# add wave -radix decimal sim:/top_tb/top_inst/mem1/in_rdx2345_data/d_imag
# add wave -radix unsigned sim:/top_tb/top_inst/mem1/out_data/*
# add wave -radix unsigned sim:/top_tb/top_inst/mem1/*
# add wave -radix unsigned sim:/top_tb/top_inst/mem1/ctrl/*
# add wave -radix unsigned sim:/top_tb/top_inst/mem1/stat_to_ctrl/*

# add wave -radix decimal sim:/top_tb/top_inst/rdx2345_twdl/*
# add wave -radix decimal sim:/top_tb/top_inst/rdx2345_twdl/dft_rdx4/*
# add wave -radix decimal sim:/top_tb/top_inst/rdx2345_twdl/dft_rdx5/*
# add wave -radix decimal sim:/top_tb/top_inst/rdx2345_twdl/dft_rdx3/*
# add wave -radix decimal sim:/top_tb/top_inst/rdx2345_twdl/twdl/*
# add wave -radix decimal sim:/top_tb/top_inst/rdx2345_twdl/twdl/dout_imag_t
# add wave -radix decimal sim:/top_tb/top_inst/rdx2345_twdl/from_mem/*

# # divider_pipe0_tb
# add wave -radix unsigned sim:/divider_pipe0_tb/divider_pipe0_inst/*
# add wave -radix unsigned sim:/divider_pipe0_tb/divider_pipe0_inst/divider_inst_0/*
# add wave -radix unsigned {sim:/divider_pipe0_tb/divider_pipe0_inst/div_gen[1]/divider_inst/*}

# # mrd_twdl_tb
# add wave -radix signed {sim:/mrd_twdl_tb/mrd_twdl_inst/*}

view structure
view signals
# run 200us
run 50us