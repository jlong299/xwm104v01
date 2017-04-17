set_global_assignment -entity "altmult_complex_18_mrd" -library "lib_altmult_complex_18_mrd" -name IP_TOOL_NAME "Qsys"
set_global_assignment -entity "altmult_complex_18_mrd" -library "lib_altmult_complex_18_mrd" -name IP_TOOL_VERSION "15.1"
set_global_assignment -entity "altmult_complex_18_mrd" -library "lib_altmult_complex_18_mrd" -name IP_TOOL_ENV "Qsys"
set_global_assignment -library "lib_altmult_complex_18_mrd" -name SPD_FILE [file join $::quartus(sip_path) "altmult_complex_18_mrd.spd"]
set_global_assignment -library "lib_altmult_complex_18_mrd" -name MISC_FILE [file join $::quartus(sip_path) "../altmult_complex_18_mrd.qsys"]

set_global_assignment -library "lib_altmult_complex_18_mrd" -name MISC_FILE [file join $::quartus(sip_path) "sim/altmult_complex_18_mrd.v"]
set_global_assignment -library "lib_altmult_complex_18_mrd" -name MISC_FILE [file join $::quartus(sip_path) "altmult_complex_151/sim/altmult_complex_18_mrd_altmult_complex_151_id3q2ma.v"]
