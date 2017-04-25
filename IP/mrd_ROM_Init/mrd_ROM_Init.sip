set_global_assignment -entity "mrd_ROM_Init" -library "lib_mrd_ROM_Init" -name IP_TOOL_NAME "Qsys"
set_global_assignment -entity "mrd_ROM_Init" -library "lib_mrd_ROM_Init" -name IP_TOOL_VERSION "15.1"
set_global_assignment -entity "mrd_ROM_Init" -library "lib_mrd_ROM_Init" -name IP_TOOL_ENV "Qsys"
set_global_assignment -library "lib_mrd_ROM_Init" -name SPD_FILE [file join $::quartus(sip_path) "mrd_ROM_Init.spd"]
set_global_assignment -library "lib_mrd_ROM_Init" -name MISC_FILE [file join $::quartus(sip_path) "../mrd_ROM_Init.qsys"]

set_global_assignment -library "lib_mrd_ROM_Init" -name MISC_FILE [file join $::quartus(sip_path) "sim/mrd_ROM_Init.v"]
set_global_assignment -library "lib_mrd_ROM_Init" -name MISC_FILE [file join $::quartus(sip_path) "rom_1port_151/sim/mrd_ROM_Init_rom_1port_151_bgifz3i.v"]
