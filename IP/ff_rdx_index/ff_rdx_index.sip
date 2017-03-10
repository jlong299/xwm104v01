set_global_assignment -entity "ff_rdx_index" -library "lib_ff_rdx_index" -name IP_TOOL_NAME "Qsys"
set_global_assignment -entity "ff_rdx_index" -library "lib_ff_rdx_index" -name IP_TOOL_VERSION "15.1"
set_global_assignment -entity "ff_rdx_index" -library "lib_ff_rdx_index" -name IP_TOOL_ENV "Qsys"
set_global_assignment -library "lib_ff_rdx_index" -name SPD_FILE [file join $::quartus(sip_path) "ff_rdx_index.spd"]
set_global_assignment -library "lib_ff_rdx_index" -name MISC_FILE [file join $::quartus(sip_path) "../ff_rdx_index.qsys"]

set_global_assignment -library "lib_ff_rdx_index" -name MISC_FILE [file join $::quartus(sip_path) "sim/ff_rdx_index.v"]
set_global_assignment -library "lib_ff_rdx_index" -name MISC_FILE [file join $::quartus(sip_path) "fifo_151/sim/ff_rdx_index_fifo_151_i22ugba.v"]
