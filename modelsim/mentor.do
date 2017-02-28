set TOP_LEVEL_NAME top_tb
# set TOP_LEVEL_NAME divider_pipe0_tb
# set TOP_LEVEL_NAME mrd_twdl_tb

# ----------------------------------------
# Auto-generated simulation script msim_setup.tcl
# ----------------------------------------
# This script can be used to simulate the following IP:
#     mrd_RAM_IP
# To create a top-level simulation script which compiles other
# IP, and manages other system issues, copy the following template
# and adapt it to your needs:
# 
# Start of template
# If the copied and modified template file is "mentor.do", run it as:
#   vsim -c -do mentor.do
#
# Source the generated sim script
source msim_setup.tcl

vlog -sv ../RTL/tb/*
vlog -sv ../RTL/addr_gen/*
vlog -sv ../RTL/top/*
vlog -sv ../RTL/ctrl/*
vlog -sv ../RTL/mem/*
vlog -sv ../RTL/switch/*
vlog -sv ../RTL/radix/*
vlog -sv ../RTL/twiddle/*

# Compile eda/sim_lib contents first
dev_com
# Override the top-level name (so that elab is useful)
# set TOP_LEVEL_NAME top
# Compile the standalone IP.
com
# Compile the user top-level
# vlog -sv ../../top.sv
# Elaborate the design.
elab
# Run the simulation
# run -a
# Report success to the shell
# exit -code 0
# End of template
# ----------------------------------------

# vlib work
#  com
# vlog -sv ../RTL/tb/*
# vlog -sv ../RTL/addr_gen/*
# vlog -sv ../RTL/top/*
# vlog -sv ../RTL/ctrl/*
# vlog -sv ../RTL/mem/*
# vlog -sv ../RTL/switch/*
# vlog -sv ../RTL/radix/*
# vlog -sv ../RTL/twiddle/*

# elab
# vmap       work     ./libraries/work/
# vsim -t ns  -L work $TOP_LEVEL_NAME

# radix signal sim:/....  unsigned

add wave -radix signed {sim:/top_tb/*}

# add wave -radix unsigned sim:/top_tb/top_inst/*
add wave -radix unsigned sim:/top_tb/top_inst/ctrl_fsm/*

# add wave -radix signed {sim:/top_tb/top_inst/mem0/*}
add wave -radix unsigned {sim:/top_tb/top_inst/mem0/fsm}
add wave -radix unsigned {sim:/top_tb/top_inst/mem0/cnt_stage}

add wave -radix unsigned {sim:/top_tb/top_inst/mem0/mrd_FSMrd_rd_inst/*}
add wave -radix unsigned {sim:/top_tb/top_inst/mem0/out_rdx2345_data/*}
add wave -radix signed {sim:/top_tb/top_inst/mem0/out_rdx2345_data/d_real}
add wave -radix signed {sim:/top_tb/top_inst/mem0/out_rdx2345_data/d_imag}
add wave -radix unsigned {sim:/top_tb/top_inst/mem0/in_rdx2345_data/*}
add wave -radix signed {sim:/top_tb/top_inst/mem0/in_rdx2345_data/d_real}
add wave -radix signed {sim:/top_tb/top_inst/mem0/in_rdx2345_data/d_imag}

# add wave -radix unsigned {sim:/top_tb/top_inst/mem0/mrd_FSMrd_rd_inst/CTA_addr_trans_inst/*}

# twiddle part
# add wave -radix signed {sim:/top_tb/top_inst/rdx2345_twdl/from_mem/*}
# add wave -radix signed {sim:/top_tb/top_inst/rdx2345_twdl/from_mem/d_real}
# add wave -radix signed {sim:/top_tb/top_inst/rdx2345_twdl/from_mem/d_imag}
# add wave -radix signed {sim:/top_tb/top_inst/rdx2345_twdl/real_rdx4}
# add wave -radix signed {sim:/top_tb/top_inst/rdx2345_twdl/real_rdx3}
# add wave -radix signed {sim:/top_tb/top_inst/rdx2345_twdl/real_rdx5}
# add wave -radix signed {sim:/top_tb/top_inst/rdx2345_twdl/val_rdx4}
# add wave -radix signed {sim:/top_tb/top_inst/rdx2345_twdl/val_rdx3}
# add wave -radix signed {sim:/top_tb/top_inst/rdx2345_twdl/val_rdx5}

# add wave -radix signed {sim:/top_tb/top_inst/rdx2345_twdl/dft_rdx2/din_real}
# add wave -radix signed {sim:/top_tb/top_inst/rdx2345_twdl/dft_rdx2/din_imag}
# add wave -radix signed {sim:/top_tb/top_inst/rdx2345_twdl/dft_rdx2/dout_real}
# add wave -radix signed {sim:/top_tb/top_inst/rdx2345_twdl/dft_rdx2/dout_imag}

# add wave -radix signed {sim:/top_tb/top_inst/rdx2345_twdl/twdl/din_real}
# add wave -radix signed {sim:/top_tb/top_inst/rdx2345_twdl/twdl/din_imag}
add wave -radix signed {sim:/top_tb/top_inst/rdx2345_twdl/twdl/d_real_r[1][19]}
add wave -radix signed {sim:/top_tb/top_inst/rdx2345_twdl/twdl/d_imag_r[1][19]}
add wave -radix signed {sim:/top_tb/top_inst/rdx2345_twdl/twdl/tw_real[1]}
add wave -radix signed {sim:/top_tb/top_inst/rdx2345_twdl/twdl/tw_imag[1]}
add wave -radix signed {sim:/top_tb/top_inst/rdx2345_twdl/twdl/dout_real_t_p0[1]}
add wave -radix signed {sim:/top_tb/top_inst/rdx2345_twdl/twdl/dout_imag_t_p0[1]}
add wave -radix signed {sim:/top_tb/top_inst/rdx2345_twdl/twdl/dout_real_t_p1[1]}
add wave -radix signed {sim:/top_tb/top_inst/rdx2345_twdl/twdl/dout_imag_t_p1[1]}

# add wave -radix signed {sim:/top_tb/top_inst/rdx2345_twdl/to_mem/*}
# add wave -radix signed {sim:/top_tb/top_inst/rdx2345_twdl/to_mem/d_real}
# add wave -radix signed {sim:/top_tb/top_inst/rdx2345_twdl/to_mem/d_imag}

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

# add wave -radix unsigned {sim:/top_tb/top_inst/mem0/mrd_FSMrd_rd_inst/CTA_addr_trans_inst/*}

view structure
view signals

# run 800us
run 100us