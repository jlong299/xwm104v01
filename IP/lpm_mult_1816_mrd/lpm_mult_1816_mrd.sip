set_global_assignment -entity "lpm_mult_1816_mrd" -library "lib_lpm_mult_1816_mrd" -name IP_TOOL_NAME "Qsys"
set_global_assignment -entity "lpm_mult_1816_mrd" -library "lib_lpm_mult_1816_mrd" -name IP_TOOL_VERSION "15.1"
set_global_assignment -entity "lpm_mult_1816_mrd" -library "lib_lpm_mult_1816_mrd" -name IP_TOOL_ENV "Qsys"
set_global_assignment -library "lib_lpm_mult_1816_mrd" -name SPD_FILE [file join $::quartus(sip_path) "lpm_mult_1816_mrd.spd"]
set_global_assignment -library "lib_lpm_mult_1816_mrd" -name MISC_FILE [file join $::quartus(sip_path) "../lpm_mult_1816_mrd.qsys"]

set_global_assignment -library "lib_lpm_mult_1816_mrd" -name MISC_FILE [file join $::quartus(sip_path) "sim/lpm_mult_1816_mrd.v"]
set_global_assignment -library "lib_lpm_mult_1816_mrd" -name MISC_FILE [file join $::quartus(sip_path) "lpm_mult_151/sim/lpm_mult_1816_mrd_lpm_mult_151_lsm6l5i.v"]
