set_global_assignment -entity "ff_rdx_data" -library "lib_ff_rdx_data" -name IP_TOOL_NAME "Qsys"
set_global_assignment -entity "ff_rdx_data" -library "lib_ff_rdx_data" -name IP_TOOL_VERSION "15.1"
set_global_assignment -entity "ff_rdx_data" -library "lib_ff_rdx_data" -name IP_TOOL_ENV "Qsys"
set_global_assignment -library "lib_ff_rdx_data" -name SPD_FILE [file join $::quartus(sip_path) "ff_rdx_data.spd"]
set_global_assignment -library "lib_ff_rdx_data" -name MISC_FILE [file join $::quartus(sip_path) "../ff_rdx_data.qsys"]

set_global_assignment -library "lib_ff_rdx_data" -name MISC_FILE [file join $::quartus(sip_path) "sim/ff_rdx_data.v"]
set_global_assignment -library "lib_ff_rdx_data" -name MISC_FILE [file join $::quartus(sip_path) "fifo_151/sim/ff_rdx_data_fifo_151_vbtzbya.v"]
