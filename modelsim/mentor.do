set TOP_LEVEL_NAME top_tb
# set TOP_LEVEL_NAME divider_pipe0_tb
# set TOP_LEVEL_NAME mrd_twdl_tb
# set TOP_LEVEL_NAME mrd_rdx4_v2_tb

# ----------------------------------------
# Auto-generated simulation script msim_setup.tcl
# ----------------------------------------

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

# vlog -sv ../RTL/tb/*
# vlog -sv ../RTL/addr_gen/*
# vlog -sv ../RTL/top/*
# vlog -sv ../RTL/ctrl/*
# vlog -sv ../RTL/mem/*
# vlog -sv ../RTL/switch/*
# vlog -sv ../RTL/radix/*
# vlog -sv ../RTL/twiddle/*

# vsim -t ns  -L work $TOP_LEVEL_NAME

# elab
# vmap       work     ./libraries/work/

add wave -radix signed {sim:/top_tb/*}

add wave -radix unsigned sim:/top_tb/top_inst/ctrl_fsm/*

add wave -radix unsigned {sim:/top_tb/top_inst/mem0/fsm}
add wave -radix unsigned {sim:/top_tb/top_inst/mem0/cnt_stage}

add wave -radix unsigned {sim:/top_tb/top_inst/mem0/mrd_FSMrd_rd_inst/*}
add wave -radix unsigned {sim:/top_tb/top_inst/mem0/out_rdx2345_data/*}
add wave -radix signed {sim:/top_tb/top_inst/mem0/out_rdx2345_data/d_real}
add wave -radix signed {sim:/top_tb/top_inst/mem0/out_rdx2345_data/d_imag}
add wave -radix unsigned {sim:/top_tb/top_inst/mem0/in_rdx2345_data/*}
add wave -radix signed {sim:/top_tb/top_inst/mem0/in_rdx2345_data/d_real}
add wave -radix signed {sim:/top_tb/top_inst/mem0/in_rdx2345_data/d_imag}

add wave -radix unsigned {sim:/top_tb/top_inst/rdx2345_twdl/exp_in}
add wave -radix unsigned {sim:/top_tb/top_inst/rdx2345_twdl/exp_out}
add wave -radix unsigned {sim:/top_tb/top_inst/rdx2345_twdl/dft_val}
add wave -radix signed {sim:/top_tb/top_inst/rdx2345_twdl/abs_real}
add wave -radix signed {sim:/top_tb/top_inst/rdx2345_twdl/abs_imag}
add wave -radix unsigned {sim:/top_tb/top_inst/rdx2345_twdl/margin_real}
add wave -radix unsigned {sim:/top_tb/top_inst/rdx2345_twdl/margin_imag}
add wave -radix unsigned {sim:/top_tb/top_inst/rdx2345_twdl/min_margin}
add wave -radix unsigned {sim:/top_tb/top_inst/rdx2345_twdl/margin_out}
add wave -radix unsigned {sim:/top_tb/top_inst/rdx2345_twdl/margin_in}

# add wave -radix signed {sim:/top_tb/top_inst/rdx2345_twdl/rdx3_v2/*}


# add wave -radix signed {sim:/top_tb/top_inst/rdx2345_twdl/twdl/in_val}
# add wave -radix signed {sim:/top_tb/top_inst/rdx2345_twdl/twdl/valid_r[20]}
# add wave -radix signed {sim:/top_tb/top_inst/rdx2345_twdl/twdl/sclr}
# add wave -radix signed {sim:/top_tb/top_inst/rdx2345_twdl/twdl/d_real_r}
# add wave -radix signed {sim:/top_tb/top_inst/rdx2345_twdl/twdl/d_imag_r}
# add wave -radix signed {sim:/top_tb/top_inst/rdx2345_twdl/twdl/tw_real[1]}
# add wave -radix signed {sim:/top_tb/top_inst/rdx2345_twdl/twdl/tw_imag[1]}

# add wave -radix signed {sim:/mrd_rdx4_v2_tb/in_val}
# add wave -radix signed {sim:/mrd_rdx4_v2_tb/din_real}
# add wave -radix signed {sim:/mrd_rdx4_v2_tb/din_imag}

# add wave -radix signed {sim:/mrd_rdx4_v2_tb/mrd_rdx4_2_v2_inst/p3_x0_r}
# add wave -radix signed {sim:/mrd_rdx4_v2_tb/mrd_rdx4_2_v2_inst/p3_x1_r}
# add wave -radix signed {sim:/mrd_rdx4_v2_tb/mrd_rdx4_2_v2_inst/p3_x2_r}
# add wave -radix signed {sim:/mrd_rdx4_v2_tb/mrd_rdx4_2_v2_inst/p3_x3_r}


# add wave -radix signed {sim:/mrd_rdx4_v2_tb/out_val}
# add wave -radix signed {sim:/mrd_rdx4_v2_tb/dout_real}
# add wave -radix signed {sim:/mrd_rdx4_v2_tb/dout_imag}
# add wave -radix signed {sim:/mrd_rdx4_v2_tb/exp_out}
# add wave -radix signed {sim:/mrd_rdx4_v2_tb/din_real_2}
# add wave -radix signed {sim:/mrd_rdx4_v2_tb/din_imag_2}
# add wave -radix signed {sim:/mrd_rdx4_v2_tb/out_val_2}
# add wave -radix signed {sim:/mrd_rdx4_v2_tb/dout_real_2}
# add wave -radix signed {sim:/mrd_rdx4_v2_tb/dout_imag_2}


view structure
view signals

run 800us
# run 300us