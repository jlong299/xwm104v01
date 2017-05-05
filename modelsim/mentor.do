set TOP_LEVEL_NAME top_tb_p4
# set TOP_LEVEL_NAME divider_pipe0_tb
# set TOP_LEVEL_NAME mrd_twdl_tb
# set TOP_LEVEL_NAME mrd_rdx2345_v2_tb

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

# add wave -radix signed {sim:/top_tb/*}
add wave -radix signed {sim:/top_tb_p4/*}
add wave -radix signed {sim:/top_tb_p4/sink_real_p4}
add wave -radix signed {sim:/top_tb_p4/sink_imag_p4}

add wave -radix signed {sim:/top_tb_p4/top_p4/mem0_p4/wrRAM/wren}
add wave -radix signed {sim:/top_tb_p4/top_p4/mem0_p4/wrRAM/wraddr}
add wave -radix signed {sim:/top_tb_p4/top_p4/mem0_p4/wrRAM/din_real}
add wave -radix signed {sim:/top_tb_p4/top_p4/mem0_p4/wrRAM/din_imag}
add wave -radix signed {sim:/top_tb_p4/top_p4/mem0_p4/fsm}
add wave -radix signed {sim:/top_tb_p4/top_p4/mem0_p4/sink_end}


# add wave -radix signed {sim:/top_tb/top_inst/rst_n_sync}
# add wave -radix signed {sim:/top_tb/top_inst/sink_ready}

# add wave -radix unsigned sim:/top_tb/top_inst/ctrl_fsm/*
# add wave -radix unsigned sim:/top_tb/top_inst/ctrl_fsm/ctrl_to_mem/*

# add wave -radix unsigned {sim:/top_tb/top_inst/mem0/fsm}
# add wave -radix unsigned {sim:/top_tb/top_inst/mem0/cnt_stage}
# add wave -radix unsigned {sim:/top_tb/top_inst/mem0/fsm_lastRd_source}
# add wave -radix unsigned {sim:/top_tb/top_inst/mem0/cnt_twdlStage}

# add wave -radix signed {sim:/top_tb/top_inst/mem0/out_data/dout_real}
# add wave -radix signed {sim:/top_tb/top_inst/mem0/in_rdx2345_data/d_real[0]}


# add wave -radix unsigned {sim:/top_tb/top_inst/mem0/mrd_FSMrd_rd_inst/*}
# add wave -radix unsigned {sim:/top_tb/top_inst/mem0/out_rdx2345_data/*}
# add wave -radix signed {sim:/top_tb/top_inst/mem0/out_rdx2345_data/d_real}
# add wave -radix signed {sim:/top_tb/top_inst/mem0/out_rdx2345_data/d_imag}

# add wave -radix signed {sim:/top_tb/top_inst/rdx2345_twdl/twdl/*}
# add wave -radix signed {sim:/top_tb/top_inst/rdx2345_twdl/twdl/din_real}
# add wave -radix signed {sim:/top_tb/top_inst/rdx2345_twdl/twdl/dout_real}

# add wave -radix unsigned {sim:/top_tb/top_inst/mem0/in_rdx2345_data/*}
# add wave -radix signed {sim:/top_tb/top_inst/mem0/in_rdx2345_data/d_real}
# add wave -radix signed {sim:/top_tb/top_inst/mem0/in_rdx2345_data/d_imag}

# add wave -radix unsigned {sim:/top_tb/top_inst/rdx2345_twdl/exp_in}
# add wave -radix unsigned {sim:/top_tb/top_inst/rdx2345_twdl/exp_out}
# add wave -radix unsigned {sim:/top_tb/top_inst/rdx2345_twdl/dft_val}

# add wave -radix unsigned {sim:/top_tb/top_inst/rdx2345_twdl/rdx5_3_4_2_v2/worst_case_growth}
# add wave -radix unsigned {sim:/top_tb/top_inst/rdx2345_twdl/rdx5_3_4_2_v2/margin_in}


# add wave -radix signed {sim:/top_tb/top_inst/rdx2345_twdl/abs_real}
# add wave -radix signed {sim:/top_tb/top_inst/rdx2345_twdl/abs_imag}
# add wave -radix unsigned {sim:/top_tb/top_inst/rdx2345_twdl/margin_real}
# add wave -radix unsigned {sim:/top_tb/top_inst/rdx2345_twdl/margin_imag}
# add wave -radix unsigned {sim:/top_tb/top_inst/rdx2345_twdl/min_margin}
# add wave -radix unsigned {sim:/top_tb/top_inst/rdx2345_twdl/margin_out}
# add wave -radix unsigned {sim:/top_tb/top_inst/rdx2345_twdl/margin_in}


view structure
view signals

run 20us