
# (C) 2001-2017 Altera Corporation. All rights reserved.
# Your use of Altera Corporation's design tools, logic functions and 
# other software and tools, and its AMPP partner logic functions, and 
# any output files any of the foregoing (including device programming 
# or simulation files), and any associated documentation or information 
# are expressly subject to the terms and conditions of the Altera 
# Program License Subscription Agreement, Altera MegaCore Function 
# License Agreement, or other applicable license agreement, including, 
# without limitation, that your use is for the sole purpose of 
# programming logic devices manufactured by Altera and sold by Altera 
# or its authorized distributors. Please refer to the applicable 
# agreement for further details.

# ----------------------------------------
# Auto-generated simulation script msim_setup.tcl
# ----------------------------------------
# This script can be used to simulate the following IP:
#     mrd_RAM_IP
# To create a top-level simulation script which compiles other
# IP, and manages other system issues, copy the following template
# and adapt it to your needs:
# 
# # Start of template
# # If the copied and modified template file is "mentor.do", run it as:
# #   vsim -c -do mentor.do
# #
# # Source the generated sim script
# source msim_setup.tcl
# # Compile eda/sim_lib contents first
# dev_com
# # Override the top-level name (so that elab is useful)
# set TOP_LEVEL_NAME top
# # Compile the standalone IP.
# com
# # Compile the user top-level
# vlog -sv ../../top.sv
# # Elaborate the design.
# elab
# # Run the simulation
# run -a
# # Report success to the shell
# exit -code 0
# # End of template
# ----------------------------------------
# If mrd_RAM_IP is one of several IP cores in your
# Quartus project, you can generate a simulation script
# suitable for inclusion in your top-level simulation
# script by running the following command line:
# 
# ip-setup-simulation --quartus-project=<quartus project>
# 
# ip-setup-simulation will discover the Altera IP
# within the Quartus project, and generate a unified
# script which supports all the Altera IP within the design.
# ----------------------------------------
# ACDS 15.1 193 win32 2017.02.27.14:33:26

# ----------------------------------------
# Initialize variables
if ![info exists SYSTEM_INSTANCE_NAME] { 
  set SYSTEM_INSTANCE_NAME ""
} elseif { ![ string match "" $SYSTEM_INSTANCE_NAME ] } { 
  set SYSTEM_INSTANCE_NAME "/$SYSTEM_INSTANCE_NAME"
}

if ![info exists TOP_LEVEL_NAME] { 
  set TOP_LEVEL_NAME "mrd_RAM_IP"
}

if ![info exists QSYS_SIMDIR] { 
  set QSYS_SIMDIR "../IP"
}

if ![info exists QUARTUS_INSTALL_DIR] { 
  set QUARTUS_INSTALL_DIR "C:/altera_pro/15.1/quartus/"
}

if ![info exists USER_DEFINED_COMPILE_OPTIONS] { 
  set USER_DEFINED_COMPILE_OPTIONS ""
}
if ![info exists USER_DEFINED_ELAB_OPTIONS] { 
  set USER_DEFINED_ELAB_OPTIONS ""
}

# ----------------------------------------
# Initialize simulation properties - DO NOT MODIFY!
set ELAB_OPTIONS ""
set SIM_OPTIONS ""
if ![ string match "*-64 vsim*" [ vsim -version ] ] {
} else {
}

# ----------------------------------------
# Copy ROM/RAM files to simulation directory
alias file_copy {
  echo "\[exec\] file_copy"
}

# ----------------------------------------
# Create compilation libraries
proc ensure_lib { lib } { if ![file isdirectory $lib] { vlib $lib } }
ensure_lib          ./libraries/     
ensure_lib          ./libraries/work/
vmap       work     ./libraries/work/
vmap       work_lib ./libraries/work/
if ![ string match "*ModelSim ALTERA*" [ vsim -version ] ] {
  ensure_lib                   ./libraries/altera_ver/       
  vmap       altera_ver        ./libraries/altera_ver/       
  ensure_lib                   ./libraries/lpm_ver/          
  vmap       lpm_ver           ./libraries/lpm_ver/          
  ensure_lib                   ./libraries/sgate_ver/        
  vmap       sgate_ver         ./libraries/sgate_ver/        
  ensure_lib                   ./libraries/altera_mf_ver/    
  vmap       altera_mf_ver     ./libraries/altera_mf_ver/    
  ensure_lib                   ./libraries/altera_lnsim_ver/ 
  vmap       altera_lnsim_ver  ./libraries/altera_lnsim_ver/ 
  ensure_lib                   ./libraries/twentynm_ver/     
  vmap       twentynm_ver      ./libraries/twentynm_ver/     
  ensure_lib                   ./libraries/twentynm_hssi_ver/
  vmap       twentynm_hssi_ver ./libraries/twentynm_hssi_ver/
  ensure_lib                   ./libraries/twentynm_hip_ver/ 
  vmap       twentynm_hip_ver  ./libraries/twentynm_hip_ver/ 
}
ensure_lib               ./libraries/ram_2port_151/
vmap       ram_2port_151 ./libraries/ram_2port_151/
# ensure_lib                      ./libraries/ff_rdx_data_fifo_151/
# vmap       ff_rdx_data_fifo_151 ./libraries/ff_rdx_data_fifo_151/

# ----------------------------------------
# Compile device library files
alias dev_com {
  echo "\[exec\] dev_com"
  if ![ string match "*ModelSim ALTERA*" [ vsim -version ] ] {
    eval  vlog $USER_DEFINED_COMPILE_OPTIONS     "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_primitives.v"                 -work altera_ver       
    eval  vlog $USER_DEFINED_COMPILE_OPTIONS     "$QUARTUS_INSTALL_DIR/eda/sim_lib/220model.v"                          -work lpm_ver          
    eval  vlog $USER_DEFINED_COMPILE_OPTIONS     "$QUARTUS_INSTALL_DIR/eda/sim_lib/sgate.v"                             -work sgate_ver        
    eval  vlog $USER_DEFINED_COMPILE_OPTIONS     "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_mf.v"                         -work altera_mf_ver    
    eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_lnsim.sv"                     -work altera_lnsim_ver 
    eval  vlog $USER_DEFINED_COMPILE_OPTIONS     "$QUARTUS_INSTALL_DIR/eda/sim_lib/twentynm_atoms.v"                    -work twentynm_ver     
    eval  vlog $USER_DEFINED_COMPILE_OPTIONS     "$QUARTUS_INSTALL_DIR/eda/sim_lib/mentor/twentynm_atoms_ncrypt.v"      -work twentynm_ver     
    eval  vlog $USER_DEFINED_COMPILE_OPTIONS     "$QUARTUS_INSTALL_DIR/eda/sim_lib/mentor/twentynm_hssi_atoms_ncrypt.v" -work twentynm_hssi_ver
    eval  vlog $USER_DEFINED_COMPILE_OPTIONS     "$QUARTUS_INSTALL_DIR/eda/sim_lib/twentynm_hssi_atoms.v"               -work twentynm_hssi_ver
    eval  vlog $USER_DEFINED_COMPILE_OPTIONS     "$QUARTUS_INSTALL_DIR/eda/sim_lib/mentor/twentynm_hip_atoms_ncrypt.v"  -work twentynm_hip_ver 
    eval  vlog $USER_DEFINED_COMPILE_OPTIONS     "$QUARTUS_INSTALL_DIR/eda/sim_lib/twentynm_hip_atoms.v"                -work twentynm_hip_ver 
  }
}

# ----------------------------------------
# Compile the design files in correct order
alias com {
  echo "\[exec\] com"
  eval  vlog $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/mrd_RAM_IP/ram_2port_151/sim/mrd_RAM_IP_ram_2port_151_hhdwfsy.v" -work ram_2port_151
  eval  vlog $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/mrd_RAM_IP/sim/mrd_RAM_IP.v"                                                               
  eval  vlog $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/ff_rdx_data/fifo_151/sim/ff_rdx_data_fifo_151_efv2tfa.v" 
  eval  vlog $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/ff_rdx_data/sim/ff_rdx_data.v"                                                            
  eval  vlog $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/ff_rdx_index/fifo_151/sim/ff_rdx_index_fifo_151_dv6wpvq.v" 
  eval  vlog $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/ff_rdx_index/sim/ff_rdx_index.v"                                                            
  eval  vlog $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/mrd_ROM_Init/rom_1port_151/sim/mrd_ROM_Init_rom_1port_151_qacsi6a.v" 
  eval  vlog $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/mrd_ROM_Init/sim/mrd_ROM_Init.v"                                                            
  eval  vlog $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/lpm_mult_16_mrd/lpm_mult_151/sim/lpm_mult_16_mrd_lpm_mult_151_lx6omxy.v" 
  eval  vlog $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/lpm_mult_16_mrd/sim/lpm_mult_16_mrd.v"                                                            
  eval  vlog $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/lpm_mult_18_mrd/lpm_mult_151/sim/lpm_mult_18_mrd_lpm_mult_151_jtuoava.v" 
  eval  vlog $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/lpm_mult_18_mrd/sim/lpm_mult_18_mrd.v"                                                            
  eval  vlog $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altmult_complex_18_mrd/altmult_complex_151/sim/altmult_complex_18_mrd_altmult_complex_151_id3q2ma.v" 
  eval  vlog $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altmult_complex_18_mrd/sim/altmult_complex_18_mrd.v"                                                            
}

# ----------------------------------------
# Elaborate top level design
alias elab {
  echo "\[exec\] elab"
  eval vsim -t ps $ELAB_OPTIONS $USER_DEFINED_ELAB_OPTIONS -L work -L work_lib -L ram_2port_151 -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L twentynm_ver -L twentynm_hssi_ver -L twentynm_hip_ver $TOP_LEVEL_NAME
}

# ----------------------------------------
# Elaborate the top level design with novopt option
alias elab_debug {
  echo "\[exec\] elab_debug"
  eval vsim -novopt -t ps $ELAB_OPTIONS $USER_DEFINED_ELAB_OPTIONS -L work -L work_lib -L ram_2port_151 -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L twentynm_ver -L twentynm_hssi_ver -L twentynm_hip_ver $TOP_LEVEL_NAME
}

# ----------------------------------------
# Compile all the design files and elaborate the top level design
alias ld "
  dev_com
  com
  elab
"

# ----------------------------------------
# Compile all the design files and elaborate the top level design with -novopt
alias ld_debug "
  dev_com
  com
  elab_debug
"

# ----------------------------------------
# Print out user commmand line aliases
alias h {
  echo "List Of Command Line Aliases"
  echo
  echo "file_copy                     -- Copy ROM/RAM files to simulation directory"
  echo
  echo "dev_com                       -- Compile device library files"
  echo
  echo "com                           -- Compile the design files in correct order"
  echo
  echo "elab                          -- Elaborate top level design"
  echo
  echo "elab_debug                    -- Elaborate the top level design with novopt option"
  echo
  echo "ld                            -- Compile all the design files and elaborate the top level design"
  echo
  echo "ld_debug                      -- Compile all the design files and elaborate the top level design with -novopt"
  echo
  echo 
  echo
  echo "List Of Variables"
  echo
  echo "TOP_LEVEL_NAME                -- Top level module name."
  echo "                                 For most designs, this should be overridden"
  echo "                                 to enable the elab/elab_debug aliases."
  echo
  echo "SYSTEM_INSTANCE_NAME          -- Instantiated system module name inside top level module."
  echo
  echo "QSYS_SIMDIR                   -- Qsys base simulation directory."
  echo
  echo "QUARTUS_INSTALL_DIR           -- Quartus installation directory."
  echo
  echo "USER_DEFINED_COMPILE_OPTIONS  -- User-defined compile options, added to com/dev_com aliases."
  echo
  echo "USER_DEFINED_ELAB_OPTIONS     -- User-defined elaboration options, added to elab/elab_debug aliases."
}
file_copy
h
